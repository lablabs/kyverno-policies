# Contributing

When contributing to this repository, please first create an issue and link the PR with it.

Please note we have a code of conduct, please follow it in all your interactions with the project.

## Pull Request Process

1. Document your changes in the chart's README.md.gotmpl. The README.md will be generated from it by the pre-commit hook in the next step.
2. Run pre-commit hooks `pre-commit run -a`.
3. Once all outstanding comments and checklist items have been addressed, your contribution will be merged! Merged PRs will be included in the next release.

## Checklists for contributions

- [ ] Add [semantics prefix](#semantic-pull-requests) to your PR or Commits.
- [ ] CI tests are passing
- [ ] README.md has been updated after any changes. The variables and outputs in the README.md has been generated (using the `helm-docs` pre-commit hook)
- [ ] Run pre-commit hooks `pre-commit run -a`

## Semantic Pull Requests

Pull Requests or Commits must follow conventional specs below:

- `ci:` Changes to our CI configuration files and scripts (example scopes: GitHub Actions)
- `docs:` Documentation only changes
- `feat:` A new feature
- `fix:` A bug fix
- `refactor:` A code change that neither fixes a bug nor adds a feature
- `style:` Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- `test:` Adding missing tests or correcting existing tests
