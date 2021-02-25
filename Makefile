NAME                     := AWS S3 Blueprint
DESCRIPTION              := The '$(NAME)' describes the deployment on an AWS Simple Storage Service (S3) bucket.
VERSION                  := $(shell cat ./VERSION | tr -d [:space:])

GIT_REMOTE_ORIGIN_URI    := $(shell git remote get-url origin)
GIT_REMOTE_UPSTREAM_NAME := upstream
GIT_REMOTE_UPSTREAM_URI  := ssh://git@bitbucket.biscrum.com:7999/infiaas/blueprint-aws-skeleton.git

RELEASE_EMAIL_FROM       := zzITINFCoEforCloudComputing@boehringer-ingelheim.com
RELEASE_EMAIL_TO         := cb4f6d49.boehringer.onmicrosoft.com@emea.teams.ms

PWD                      := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
GEMS_HOME                ?= $(PWD)/vendor/bundle
TEST_REPORT_HOME         := ./reports/test


default: test

all: init test

.PHONY: init
# Initialize project.
init: install-dev-deps install-test-deps

.PHONY: merge-upstream
# Merge the upstream remote's master branch into this repository's current branch.
merge-upstream:
	$(call git_add_remote,$(GIT_REMOTE_UPSTREAM_NAME),$(GIT_REMOTE_UPSTREAM_URI))
	git fetch $(GIT_REMOTE_UPSTREAM_NAME)
	git merge $(GIT_REMOTE_UPSTREAM_NAME)/master

merge-upstream011:
	$(call git_add_remote,$(GIT_REMOTE_UPSTREAM_NAME),$(GIT_REMOTE_UPSTREAM_URI))
	git fetch $(GIT_REMOTE_UPSTREAM_NAME)
	git merge $(GIT_REMOTE_UPSTREAM_NAME)/terraform011

.PHONY: test
## Run blueprint integration tests.
test: install-test-deps
	$(call check_defined,AWS_ACCESS_KEY_ID)
	$(call check_defined,AWS_SECRET_ACCESS_KEY)
	$(call check_defined,AWS_DEFAULT_REGION)

	# Remove any previously created Terraform test artefacts.
	for dir in .terraform terraform.tfstate.d; do \
		find test/fixtures -name $$dir -print0 | xargs -0 rm -rf; \
	done \

	inspec_profiles=$$(ls -1 ./test/integration); \
	for fdir in $$inspec_profiles; do \
		mkdir -p test/integration/$$fdir/files ; \
		./.venv/bin/python3 ./.venv/bin/hcl2tojson test/fixtures/$$fdir/main.tf  test/integration/$$fdir/files/main.json; \
	done \

	# See https://github.com/hashicorp/terraform/issues/17655 for TF_WARN_OUTPUT_ERRORS=1.
	# See https://github.com/test-kitchen/test-kitchen/issues/1436 for why a simple `bundle exec kitchen test` is not an option.
	for suite in $$(bundle exec kitchen list --bare); do \
		TF_WARN_OUTPUT_ERRORS=1 bundle exec kitchen verify $$suite || { bundle exec kitchen destroy $$suite; exit 1; }; \
		bundle exec kitchen destroy $$suite; \
	done

.PHONY: test-report
test-report: test
	$(call create_report,$(TEST_REPORT_HOME))

.PHONY: release
# Create and push a release branch and tag for VERSION.
release: test
	$(call exit_if_release_exists,$(VERSION))

	$(call git_create_branch,release-v$(VERSION))
		$(call create_report,$(TEST_REPORT_HOME))
		$(call add_report_to_git_branch,$(TEST_REPORT_HOME),$(VERSION))
		$(call git_push,release-v$(VERSION))

		$(call git_create_tag,$(VERSION))
		$(call git_push,v$(VERSION))
		git checkout master
	$(call send_release_email)

.PHONY: install-dev-deps
# Install development dependencies.
install-dev-deps: install-git-pre-commit-hooks

.PHONY: install-git-pre-commit-hooks
## Install Git pre-commit hooks.
install-git-pre-commit-hooks:
	pre-commit install --overwrite

.PHONY: install-ruby-gems
# Install Ruby gems specified in Gemfile.
install-ruby-gems:
	BUNDLE_SILENCE_ROOT_WARNING=true bundle config --local path $(GEMS_HOME)
	BUNDLE_SILENCE_ROOT_WARNING=true bundle install --jobs=8

.PHONY: install-python-env
# Install python virtual environment based on Pipfile
install-python-env:
	CI=true PIPENV_VENV_IN_PROJECT=true pipenv install

.PHONY: install-test-deps
# Install testing dependencies.
install-test-deps: install-ruby-gems install-python-env

.PHONY: tf012upgrade
# Migrate to terraform 0.12, upgrade from skeleton, precheck and run the upgrade command
# https://www.terraform.io/upgrade-guides/0-12.html
tf012upgrade:
	for suite in $$(ls -d . test/fixtures/*); do \
		rm -Rf $$suite/.terraform ; \
		/usr/local/bin/terraform11 init $$suite ; \
		/usr/local/bin/terraform11 0.12checklist $$suite || exit 1 ; \
	done

	for suite in $$(ls -d . test/fixtures/*); do \
		rm -Rf $$suite/.terraform ; \
		/usr/local/bin/terraform12 init $$suite ; \
		/usr/local/bin/terraform12 0.12upgrade -yes $$suite || exit 1 ; \
	done

	git status


.PHONY: tf013upgrade
# Migrate to terraform 0.13, upgrade from skeleton, precheck and run the upgrade command
# https://www.terraform.io/upgrade-guides/0-13.html
tf013upgrade:
	for suite in $$(ls -d . test/fixtures/*); do \
		rm -Rf $$suite/.terraform ; \
		terraform init $$suite ; \
		terraform 0.13upgrade -yes $$suite || exit 1 ; \
	done

	git status

.PHONY: cinc-auditor-test
# run cinc-auditor without use of kitchen-terraform and create yaml for mapping terraform outputs to inspec inputs.
cinc-auditor-test:
	./lib/scripts/createo2yml.sh
	bundle exec cinc-auditor exec test/integration/default --no-create-lockfile --input-file test/integration/default/files/inputs-from-tfo.yml --target aws://


# Checks if a variable is defined and produces a fatal error if not.
check_defined = \
	$(strip $(foreach 1,$1, \
		$(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
	$(if $(value $1),, \
		$(error Undefined $1$(if $2, ($2))$(if $(value @), \
			required by target `$@')))

# Adds a previously created report to the current Git branch.
add_report_to_git_branch = \
	git add -f $(1)/report.* && \
	git commit -n -m "Add test report for v$(2)."

# Creates a new report in the given reports directory.
create_report = \
	$(shell cd $(1) && \
		bash ./scripts/clean.sh && \
		bash ./scripts/compile.sh "$(PWD)" "$(NAME)" "$(VERSION)" "$(DESCRIPTION)" "$(GIT_REMOTE_ORIGIN_URI)" "$(call rfc3339_datetime)")

# Exits with an error if a given release already exists.
exit_if_release_exists = \
	if git branch -a | grep -q -e release-v$(1); then \
		echo "Error: a release with version $(1) already exists.";  \
		exit 1;  \
	fi

# Adds a Git remote if it doesn't exist already.
git_add_remote = \
	if ! git remote -v | grep -q -e $(1); then \
		git remote add $(1) $(2); \
	fi

# Creates and switches to a new Git branch.
git_create_branch = \
	git checkout -b $(1)

# Creates an annotated Git tag.
git_create_tag = \
	git tag -a v$(1) -m v$(1)

# Updates the origin remote with local changes.
git_push = \
	git push origin $(1)

# Computes a URL from a Git URI.
git_uri_to_url = \
	$(shell \
		GIT_URL=`echo "$(1)" | sed 's/:/\//g'`; \
		GIT_URL=`echo "$${GIT_URL}" | sed 's/^git@/https:\/\//'`; \
		GIT_URL=`echo "$${GIT_URL}" | sed 's/.git$$//'`; \
		echo "$${GIT_URL}")

# Creates an RFC3339 date and time string. Example: 2018-11-01T11:12:13+01:00.
rfc3339_datetime = \
	$(shell \
		DATETIME=`date +"%Y-%m-%dT%H:%M:%S"`; \
		TIME_OFFSET_HOURS=`date +"%z" | cut -c 1-3`; \
		TIME_OFFSET_MINUTES=`date +"%z" | cut -c 4-5`; \
		echo "$${DATETIME}$${TIME_OFFSET_HOURS}:$${TIME_OFFSET_MINUTES}")

# Sends an email to announce a new release.
send_release_email = \
	$(shell \
		FROM="$(RELEASE_EMAIL_FROM)"; \
		TO="$(RELEASE_EMAIL_TO)"; \
		SUBJECT="New Release: $(NAME) v$(VERSION)"; \
		BODY="Available at $(call git_uri_to_url,$(GIT_REMOTE_ORIGIN_URI))."; \
		mail -s "$${SUBJECT}" -r "$${FROM}" "$${TO}" <<< "$${BODY}")
