# Git 上传完整性审计（签单助手项目）

> 背景：2026-08-04 大ice 要求确认签单助手项目上传到 `git.uozi.com/annafby/hermes-default-agent` 的完整性，重点核查图片生成部分。仓库位于 `/home/anna/.hermes`，由 `profiles/code/` 下的 git-backup skill 管理（小c）。

## 图片生成资产状态（已全部在仓库）

| 资产 | 路径 | 状态 |
|------|------|------|
| 实现文档 | `references/image-designer-details.md`（501行） | ✅ 已追踪 |
| 海报模板 | `templates/itinerary-poster-clean-template.html`（1080×1920） | ✅ 已追踪 |
| 交互测试脚本 | `scripts/test-optimized-interaction.sh` | ✅ 已追踪 |
| 背景经验 | `references/itinerary-poster-background-lessons.md` | ✅ 已追踪 |
| 视觉清单 | `references/itinerary-poster-visual-checklist.md` | ✅ 已追踪 |
| 素材确认 | `references/background-asset-confirmation.md` | ✅ 已追踪 |
| 测试模式 | `references/test-mode-procedures.md`、`test-mode-and-client-handling.md` | ✅ 已追踪 |

## image-designer 合并状态（重要）

- image-designer 曾是独立 skill，后**并入 signing-workflow-system**（见本 SKILL.md "Source Skills" 列表）。
- 实际出图方式：HTML 模板 + Hermes 内置 `browser_navigate`/`browser_vision` 截图，**无独立 Python 渲染脚本**。
- **SOUL.md 曾残留旧路径** `skills/business/image-designer/scripts/render-poster.py`（目录已不存在）。2026-08-04 已修正为实际位置（image-designer-details.md + clean 模板）。
- 审计时检查：`grep -n "image-designer\|render-poster" SOUL.md`，发现即修正。

## 未上传但用户要求上传的资产

- **测试案例 PNG**：`cache/outputs/png/` 25 个海报 ~197MB（测试客户、REMINDER测试、李明、GUO_JIAQI-integration、王永生-integration、陈太-integration、王永生-heavy 等）。
  - `cache/` 被 `.gitignore` 排除，**不能直接 push 原图**（git 不适合大二进制）。
  - 方案：挑选 6-8 个代表性样例 → 压缩至 ~500KB → 复制到 skill 的 `examples/` 目录 → 随仓库上传。
- **背景素材**：`images/` 下 `clip_` 前缀 PNG，其中 `clip_20260519_232342_4.png` 恰为 1080×1920 海报背景尺寸，另有 3072×1800 大图素材。
  - 确认为素材资产后复制到 `examples/` 或 `assets/` 再上传，不直接传原目录。

## 项目上传分类清单（业务 vs 框架）

| 类别 | 内容 | 上传 |
|------|------|------|
| 业务核心 | SOUL.md、config.yaml、`skills/business/signing-workflow-system/`、`profiles/code/skills/business/git-backup/`、cron/jobs.json、data/ARCHIVE-INDEX.md | ✅ |
| 客户隐私 | `data/active/`、`data/archive/`（客户姓名、证件、海报） | ❌ .gitignore 排除 |
| 框架运行时 | node/、hermes-agent/、bin/、images/、cache/、profiles/*/lsp/、框架自带 skills | ❌ |
| 敏感凭证 | auth.json、*.db、*.log | ❌ .gitignore 排除 |

## 审计命令（快速复用）

```bash
cd /home/anna/.hermes
# 未追踪文件分类统计
git status --short | grep "^??" | awk '{print $2}' | awk -F/ '{print $1}' | sort | uniq -c | sort -rn
# 已追踪的 skill 文件
git ls-files skills/business/signing-workflow-system/
# skill 目录未追踪文件
git status --short -- skills/business/
# 关键文件追踪状态
for f in SOUL.md config.yaml README.md LICENSE; do git ls-files --error-unmatch $f >/dev/null 2>&1 && echo "✓ $f" || echo "✗ $f"; done
```

## 提交纪律

- **只 add 明确清单，不用 `git add .`**：避免把框架文件混进提交。
- add 后用 `git diff --cached --stat` 复核暂存区。
- 提交信息示例：`feat: 补充课程报告交接文档、git备份skill、定时任务、归档索引；修正图片生成工具路径`。
