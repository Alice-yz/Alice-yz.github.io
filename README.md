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

## Acknowledgements

- AcadHomepage incorporates Font Awesome, distributed under the SIL OFL 1.1 and MIT License.
- AcadHomepage is influenced by [mmistakes/minimal-mistakes](https://github.com/mmistakes/minimal-mistakes).
- AcadHomepage is influenced by [academicpages/academicpages.github.io](https://github.com/academicpages/academicpages.github.io).
