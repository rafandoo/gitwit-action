<p align="center">
  <picture>
    <img src="https://raw.githubusercontent.com/rafandoo/gitwit/ece2cac75290359adbace661b78a7d0b716db205/src/main/docs/public/banner.webp" alt="GitWit Logo" width="50%" style="background-color: rgba(255, 255, 255, 0.85); border-radius: 20px; display: inline-block; box-shadow: 0 2px 8px rgba(0,0,0,0.15);" />
  </picture>
</p>

<h1 align="center">GitWit Action</h1>

<p align="center">
  Structured commit linting and changelog automation for GitHub Actions.
</p>

<p align="center">
  <a href="https://github.com/rafandoo/gitwit-action/releases">
    <img src="https://img.shields.io/github/v/release/rafandoo/gitwit-action?include_prereleases&colorA=363a4f&colorB=f5a97f&style=for-the-badge" alt="Latest Release">
  </a>
  <img src="https://img.shields.io/badge/runtime-java%2021-blue?style=for-the-badge&colorA=363a4f&colorB=007ec6" alt="Runtime: Java 21" />
  <img src="https://img.shields.io/badge/docker-based-blue?style=for-the-badge&colorA=363a4f&colorB=007ec6" alt="Docker-based" />
</p>

---

## 🚀 Overview

The **GitWit Action** integrates the powerful [GitWit](https://github.com/rafandoo/gitwit) directly into your CI pipeline.

It enables:

- ✅ Lint commit messages
- 📝 Generate changelogs

Designed for teams that value structured commits and automated release workflows.

> The complete documentation can be viewed [here.](https://rafandoo.dev/gitwit/reference/actions/overview)

---

## 📦 Supported Commands

| Command     | Description                             |
|-------------|-----------------------------------------|
| `lint`      | Validates commit messages               |
| `changelog` | Generates changelog from commit history |

Only these commands are allowed.

---

## 🛠 Usage

### Basic example

```yaml
name: GitWit CI

on:
  pull_request:
    branches:
      - main

jobs:
  gitwit:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 0

      - name: Run GitWit Lint
        uses: rafandoo/gitwit-action@v1
        with:
          command: lint
```

### Inputs

| Input                           | Description                                                                                    | Required | Default |
|---------------------------------|------------------------------------------------------------------------------------------------|:--------:|:-------:|
| `command`                       | Define which GitWit command will be executed (`lint` or `changelog`)                           |    ✔     |    -    |
| `changelog_stdout`              | Sends the generated changelog to the default output (_stdout_) instead of saving it in a file. |    ✖     | `false` |
| `changelog_from_latest_release` | Generates the changelog only from commits since the latest release instead of all commits.     |    ✖     | `false` |
| `args`                          | Additional arguments passed directly to the command of GitWit.                                 |    ✖     |    -    |

### Outputs

| Output      | Description                                                               |
|-------------|---------------------------------------------------------------------------|
| `changelog` | Generated changelog content (available only when `changelog_stdout=true`) |

### Lint

The **lint** command validates commit messages using the rules configured in GitWit.

This validation helps maintain a consistent commit history, ensuring that all messages follow the project-defined pattern and remain compatible with features like automatic changelog generation.

#### Example of use

```yaml
name: GitWit CI

on:
  pull_request:
    branches:
      - main

jobs:
  gitwit:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 0

      - name: Run GitWit Lint
        uses: rafandoo/gitwit-action@v1
        with:
          command: lint
```

### Changelog

The **changelog** command automatically generates a changelog from the repository’s commit messages.

Depending on the configuration used in the workflow, the changelog can:

- update or create the `CHANGELOG.md` file;
- be sent to stdout for use in other steps;
- consider only commits since the last release.

#### Full release example

The example below demonstrates a workflow that generates changelog automatically when creating a tag and uses the result as a description of a **GitHub Release**.

```yaml
name: Release Deployment

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 0
          ref: main

      - name: Generate Changelog
        id: gitwit
        uses: rafandoo/gitwit-action@v1
        with:
          command: changelog
          changelog_stdout: true
          changelog_from_latest_release: true

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          body: |
            ${{ steps.gitwit.outputs.changelog }}
```

## License 🔑

This project is licensed under the [Apache License 2.0](https://github.com/rafandoo/gitwit-action/blob/7aed724d12444c6a02351e83c271fd1294dcac21/LICENSE)

Copyright :copyright: 2026-present - Rafael Camargo
