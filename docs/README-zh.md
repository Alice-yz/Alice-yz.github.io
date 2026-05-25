# Jianing Yin 个人主页

这个仓库是 <https://jianing-yin.com/> 的 Jekyll 源码。

项目最初基于 [AcadHomepage](https://github.com/RayeRen/acad-homepage.github.io)，但当前 fork 使用本地预构建部署流程：`main` 分支保存 Jekyll 源码，`gh-pages` 分支保存构建后的静态网页文件。

## 日常修改

常改的内容主要在：

- `_pages/about.md`：主页正文
- `_config.yml`：网站标题、作者信息、联系方式、侧边栏链接、Analytics 等配置
- `images/`：头像、favicon、论文图片等
- `_sass/`、`assets/css/`、`assets/js/`：样式和脚本

Google Scholar 个人主页链接仍保留在 `_config.yml` 的 `author.googlescholar` 中。引用数自动同步功能已经移除，因此不再需要 GitHub Actions，也不需要配置 Scholar crawler secret。

## 本地预览

先安装 Ruby 和 Bundler，然后在仓库根目录运行：

```powershell
.\scripts\serve.ps1
```

浏览器打开 <http://127.0.0.1:4000/>。

这个脚本会把 Bundler 相关文件放在仓库内部的 `.bundle/` 和 `vendor/bundle/`，避免写入全局用户目录。

## 部署

现在不依赖 GitHub Actions 部署。改完内容后，在本地构建静态文件并发布到 `gh-pages` 分支：

```powershell
.\scripts\deploy-gh-pages.ps1
```

如果想先做本地 dry run，只构建并提交本地 `gh-pages` worktree、不 push 到 GitHub：

```powershell
.\scripts\deploy-gh-pages.ps1 -NoPush
```

GitHub Pages 里应使用以下设置：

- Source：`Deploy from a branch`
- Branch：`gh-pages`
- Folder：`/ (root)`
- Custom domain：`jianing-yin.com`

部署脚本会把 `CNAME` 复制到构建产物里，并添加 `.nojekyll`，让 GitHub Pages 直接发布已经构建好的静态文件。

## 致谢

- 本项目基于 AcadHomepage。
- AcadHomepage 使用 Font Awesome，遵循 SIL OFL 1.1 和 MIT License。
- AcadHomepage 受到 [mmistakes/minimal-mistakes](https://github.com/mmistakes/minimal-mistakes) 与 [academicpages/academicpages.github.io](https://github.com/academicpages/academicpages.github.io) 启发。
