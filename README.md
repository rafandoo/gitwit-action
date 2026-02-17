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

---

## 📦 Supported Commands

| Command     | Description                             |
|-------------|-----------------------------------------|
| `lint`      | Validates commit messages               |
| `changelog` | Generates changelog from commit history |

Only these commands are allowed.

---

## 🛠 Usage

### Basic Example

```yaml
name: GitWit CI

on:
  pull_request:
  push:
    branches: [ main ]

jobs:
  gitwit:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Required for commit range detection

      - name: Run GitWit Lint
        uses: rafandoo/gitwit-action@v1
        with:
          command: lint
```

## License 🔑

This project is licensed under the [Apache License 2.0](https://github.com/rafandoo/gitwit-action/blob/7aed724d12444c6a02351e83c271fd1294dcac21/LICENSE)

Copyright :copyright: 2025-present - Rafael Camargo
