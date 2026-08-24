# Personal Wallpaper Collection

This repository is my personal collection of wallpapers. The images are kept
in a separate repository so they can be shared, updated, and used by my
desktop setup independently from the main Chezmoi repository.

The collection is intentionally simple: image files live at the repository
root, and the main repository tracks this project as a Git submodule.

## Image requirements

The pre-commit hook checks staged image files before each commit:

- JPEG, PNG, and WebP images are accepted.
- Minimum dimensions: `1280x720` pixels.
- Maximum file size: `20 MiB`.
- Files that cannot be decoded as images are rejected.

The hook blocks a commit and reports the reason; it does not delete files.

## Enable the local hook

Git does not activate versioned hooks automatically. After cloning, enable the
repository hook path once:

```bash
git config core.hooksPath hooks
```

The checks can also be run manually:

```bash
./scripts/check-images.sh
```
