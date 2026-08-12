# Jianing Yin Homepage

This repository contains the Jekyll source for <https://jianing-yin.com/>.

The site is based on [AcadHomepage](https://github.com/RayeRen/acad-homepage.github.io), but this fork is maintained with a local prebuilt deployment flow: `main` keeps the Jekyll source, and `gh-pages` keeps the generated static site.

## Daily Editing

Most content lives in:

- `_pages/about.md`: homepage body
- `_config.yml`: site metadata, author profile, analytics, and social links
- `images/`: avatar, favicon, and publication images
- `_sass/`, `assets/css/`, `assets/js/`: styles and scripts

The Google Scholar profile link is kept in `_config.yml` as `author.googlescholar`. Citation count synchronization has been removed, so this repository no longer needs GitHub Actions or a Scholar crawler secret.

## Local Preview

Install Ruby and Bundler first. Then run:

```powershell
.\scripts\serve.ps1
```

Open <http://127.0.0.1:4000/>.

The script keeps Bundler files inside this repository (`.bundle/` and `vendor/bundle/`) instead of writing project dependency settings into your global user directory.

After dependencies are already installed, use the faster form for normal content edits:

```powershell
.\scripts\serve.ps1 -SkipInstall
```

## Routine Workflow

For normal edits to `_pages/about.md`, `_config.yml`, images, styles, or scripts:

```powershell
# Preview locally
.\scripts\serve.ps1 -SkipInstall

# Optional dry run: build the deploy output without pushing
.\scripts\deploy-gh-pages.ps1 -NoPush -AllowDirty -SkipInstall

# Save source changes to main (git branch --show-current 确认当前分支是 main)
git add .
git commit -m "Update homepage"
git push origin main

# Publish the prebuilt site to gh-pages
.\scripts\deploy-gh-pages.ps1 -SkipInstall
```

`main` is the source branch. `gh-pages` is the generated static site branch. The final deploy command builds `_site`, writes `CNAME` and `.nojekyll`, commits the generated files to `gh-pages`, and pushes that branch to GitHub.

## When To Install Dependencies

`bundle install` installs or updates Ruby dependencies. It does not publish the site; publishing is handled by `scripts/deploy-gh-pages.ps1`.

Run dependency installation when:

- setting up this repository for the first time on a machine
- `Gemfile` or `Gemfile.lock` changes
- `vendor/bundle/` is deleted
- Ruby is upgraded or changed
- pulling source changes that include dependency updates
- Bundler or Jekyll reports a missing gem

The scripts run Bundler automatically when `-SkipInstall` is omitted:

```powershell
.\scripts\serve.ps1
.\scripts\deploy-gh-pages.ps1
```

For day-to-day homepage content changes, dependencies usually do not change, so `-SkipInstall` is fine.

## Deploy

GitHub Actions is not required for deployment. Build locally and publish the generated static site to `gh-pages`:

```powershell
.\scripts\deploy-gh-pages.ps1
```

For a local dry run that builds and commits the `gh-pages` worktree without pushing:

```powershell
.\scripts\deploy-gh-pages.ps1 -NoPush
```

Expected GitHub Pages settings:

- Source: `Deploy from a branch`
- Branch: `gh-pages`
- Folder: `/ (root)`
- Custom domain: `jianing-yin.com`

The deploy script copies `CNAME` into the generated site and adds `.nojekyll`, so GitHub Pages can publish the prebuilt static files directly.

On Windows, the deploy script automatically prefers GitHub Desktop's bundled Git when it is installed, then falls back to the `git` command on `PATH`. A specific Git executable can be selected when needed:

```powershell
.\scripts\deploy-gh-pages.ps1 -SkipInstall -GitExecutable "C:\path\to\git.exe"
```

## Acknowledgements

- AcadHomepage incorporates Font Awesome, distributed under the SIL OFL 1.1 and MIT License.
- AcadHomepage is influenced by [mmistakes/minimal-mistakes](https://github.com/mmistakes/minimal-mistakes).
- AcadHomepage is influenced by [academicpages/academicpages.github.io](https://github.com/academicpages/academicpages.github.io).
