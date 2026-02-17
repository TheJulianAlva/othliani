# Contributing to OhtliAni

First off, thank you for taking the time to contribute! 🎉

To maintain code quality and ensure a smooth collaboration, all team members are expected to follow this workflow, which is centered around **Pull Requests (PRs)**.

---

## 📋 Table of Contents
*   [The Golden Rules](#-the-golden-rules)
*   [Commit Message Convention](#-commit-message-convention)
*   [Contribution Process](#-contribution-process)
    *   [1. Syncing your Repository](#1-syncing-your-repository)
    *   [2. Branching Strategy](#2-branching-strategy)
    *   [3. Development and Commits](#3-development-and-commits)
    *   [4. Pushing and Pull Requests](#4-pushing-and-pull-requests)
    *   [5. Code Review and Merging](#5-code-review-and-merging)

---

## ⚖️ The Golden Rules

1.  **Protected Main:** The `main` branch is protected. Direct pushes are disabled.
2.  **Atomic Branches:** Every feature or fix **must** be developed in a separate branch.
3.  **Peer Review:** All code must be reviewed and approved by at least **one (1)** other team member before merging.
4.  **Local Validation:** Run `flutter analyze` before committing to ensure no linting issues are introduced.

---

## 💬 Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/). This helps in generating automated changelogs.

*   `feat:` A new feature.
*   `fix:` A bug fix.
*   `docs:` Documentation only changes.
*   `style:` Changes that do not affect the meaning of the code (white-space, formatting).
*   `refactor:` A code change that neither fixes a bug nor adds a feature.
*   `test:` Adding missing tests or correcting existing tests.

**Example:** `feat: add login validation for tourist app`

---

## 🔄 Contribution Process

### 1. Syncing your Repository
Before starting any task, ensure you have the latest code.

*   **Terminal:**
    ```bash
    git checkout main
    git pull origin main
    ```
*   **VS Code (GUI)::** Click the branch name (bottom left corner), select `main`, and click the **"Sync Changes"** icon (refresh/cloud icon).

### 2. Branching Strategy
Create a descriptive branch for your task using appropriate prefixes: `feature/`, `bugfix/`, or `docs/`.

*   **Terminal:**
    ```bash
    git checkout -b feature/your-feature-name
    ```
*   **VS Code (GUI)::** Click the branch name -> Select `+ Create new branch...` -> Type the name and press Enter.

### 3. Development and Commits
*   Work on your changes following the **Clean Architecture** patterns defined in `docs/`.
*   Make small, frequent commits with clear messages.

*   **Terminal:**
    ```bash
    git add .
    git commit -m "feat: implement logic for X"
    ```
*   **VS Code (GUI)::** Use the **Source Control** panel (Ctrl+Shift+G), stage your changes with `+`, and type your commit message.

### 4. Pushing and Pull Requests
Once ready or when finishing your day, push your changes.

*   **Terminal:**
    ```bash
    git push -u origin your-branch-name
    ```
*   **VS Code (GUI)::** Click the **"Publish Branch"** button.

**Create the PR on GitHub:**
1.  Go to the repository on GitHub.
2.  Click "Compare & pull request".
3.  **Description:** Explain *what* you changed and *how* to test it.
4.  **Reviewers:** Assign at least one teammate.

### 5. Code Review and Merging
*   **Address Feedback:** If reviewers request changes, commit them to the same branch.
*   **Merge Policy:** Use **"Squash and merge"** on GitHub to keep a clean commit history in `main`.
*   **Clean Up:** After merging, switch to `main`, sync changes, and delete your local branch.

---

## 🛡️ Style Guide Reference
Please refer to the detailed documentation in the `docs/` folder for specific patterns:
- [Frontend Architecture](docs/03-ARQUITECTURA_FRONTEND.md)
- [Coding Standards](docs/06-ESTANDARES_DE_CODIGO.md)
