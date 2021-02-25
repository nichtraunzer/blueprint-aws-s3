# Contributing

Thank you for your interest in this project!

You can make a contribution by:

1. Reporting bugs
2. Suggesting changes
3. Contributing source code (see below)

We use the [Atlassian Jira](https://www.atlassian.com/software/jira) for trackings bugs and change requests.

Before contributing a new feature, please discuss its suitability with the project maintainers in an issue first.

## Contribution Workflow

We enforce a so-called [Forking Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/forking-workflow). For more information, please refer to our more exhaustive documentation <sup>[1](#f1)</sup>.

1. Fork and clone

    1. Point your browser to the project’s official repository. Example: bitbucket.biscrum.com/projects/INFIAAS/repos/blueprint-aws-vpc
    2. Fork the project into your personal namespace. Example: bitbucket.biscrum.com/users/josef.hartmann_boehringer-ingelheim.com/repos/blueprint-aws-vpc
    3. Clone the project into your local workspace. Example:

``` bash
$> git clone ssh://git@bitbucket.biscrum.com:7999/~josef.hartmann_boehringer-ingelheim.com/blueprint-aws-vpc.git
Cloning into ‘blueprint-aws-vpc’...
```

2. Create a bugfix or feature branch

```
$> git checkout -b feature/item-x
Switched to a new branch ‘feature/item-x’
```

```
$> git push origin feature/item-x
To ssh://bitbucket.biscrum.com:7999/~josef.hartmann_boehringer-ingelheim.com/blueprint-aws-vpc.git
 * [new branch]   feature/item-x -> feature/item-x
```

3. Develop code

4. File merge request

    1. Point your browser to the project’s personal repository. Example: bitbucket.biscrum.com/users/josef.hartmann_boehringer-ingelheim.com/repos/blueprint-aws-vpc
    2. Create a *pull request* and follow the instructions in the pull request template.
    3. Perform a *code review* with the project maintainers who may suggest improvements or alternatives.
    4. Once approved, your code will be merged into `master` and you can safely purge your feature branch.

### Requirements

##### Small and focused commits

- Commits should be as small as possible and should come with a meaningful commit message.
- Commits should be focused and only introduce change where change is needed.

##### Code, tests, and documentation

Each commit should be self-contained in that any code change is accompanied by sufficient tests and up-to-date documentation.

## Additional Resources

- <a href="https://confluence.biscrum.com/display/MIGITINF/Development+Guidelines">Development Guidelines:</a> <a id="f1" href="https://confluence.biscrum.com/display/MIGITINF/Contribution">Contribution Guide</a> (Confluence)
