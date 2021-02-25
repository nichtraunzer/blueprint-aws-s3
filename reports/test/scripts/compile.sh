#!/bin/bash
set -e

ROOT_DIR="$1"
NAME="$2"
VERSION="$3"
DESCRIPTION="$4"
GIT_URI="$5"
DATE_CREATED="$6"

FILE_META_DATA=./data/metadata.json
FILE_TERRAFORM_DOCS_DATA=./data/terraform-docs.json
FILE_INSPEC_TEST_REPORTS_DATA=./data/inspec.json

function combine_inspec_test_reports() {
  jq '.profiles += [inputs.profiles[]]' ./data/inspec/*.json
}

function create_meta_data() {
  URL=$(git_uri_to_url ${GIT_URI}/tags/v${VERSION})
  echo "{ \"metadata\": { \"date_created\": \"${DATE_CREATED}\", \"description\": \"${DESCRIPTION}\", \"name\": \"${NAME}\", \"git_uri\": \"${GIT_URI}\", \"url\": \"${URL}\", \"version\": \"${VERSION}\" } }"
}

function create_terraform_docs_data() {
  terraform-docs json "${ROOT_DIR}"
}

function git_uri_to_url() {
  local GIT_URI="$1"
  GIT_URL=`echo "${GIT_URI}" | sed 's/:/\//g'`
  GIT_URL=`echo "${GIT_URL}" | sed 's/^git@/https:\/\//'`
  GIT_URL=`echo "${GIT_URL}" | sed 's/.git$//'`
  echo "${GIT_URL}"
}


# Create various report metadata in data/metadata.json
create_meta_data > "${FILE_META_DATA}"

# Combine InSpec test reports into a single data/inspec.json
combine_inspec_test_reports > "${FILE_INSPEC_TEST_REPORTS_DATA}"

# Create terraform-docs data in data/terraform-docs.json
create_terraform_docs_data > "${FILE_TERRAFORM_DOCS_DATA}"

# Combine data sources into a single document in ./report.json
jq -s '.[0] * { "inspec": .[1] } * { "terraform_docs": .[2] }' \
  "${FILE_META_DATA}" \
  "${FILE_INSPEC_TEST_REPORTS_DATA}" \
  "${FILE_TERRAFORM_DOCS_DATA}" \
  > ./report.json

# Render the report from template and combined data
mustache ./report.json ./template/header.inc.html.tmpl > ./template/header.inc.html
mustache ./report.json ./template/report.html.tmpl > ./report.html
wkhtmltopdf \
  -T 40 -R 25 -B 25 -L 25 \
  --encoding UTF-8 \
  --no-outline \
  --print-media-type \
  --header-html template/header.inc.html \
  --footer-html template/footer.inc.html \
  ./report.html ./report.pdf
