# 上传前深度审计清单

> 配套 skill：`git-backup` 工作流 D。
> 当用户问「还有什么没传」「全面检查」时执行。

## 完整命令集

```bash
# === 阶段 1：发现未追踪文件 ===
cd /home/anna/.hermes

# 1.1 列出目标 skill 目录的全部磁盘文件
find skills/business/signing-workflow-system/ -type f | sort > /tmp/disk-files.txt

# 1.2 列出 git 已追踪文件
git ls-files skills/business/signing-workflow-system/ | sort > /tmp/git-files.txt

# 1.3 找差异
diff /tmp/disk-files.txt /tmp/git-files.txt

# 1.4 或直接找未追踪文件
git ls-files --others --exclude-standard skills/business/signing-workflow-system/

# === 阶段 2：交叉引用 SKILL.md 路径 ===

# 2.1 提取所有文件引用
grep -oP '`[^`]+`' skills/business/signing-workflow-system/SKILL.md \
  | grep -E "\.(md|html|sh|py|json)" \
  | sort -u

# 2.2 SOUL.md 中的路径引用
grep -oP '`[^`]+`' SOUL.md \
  | grep -E "\.(md|html|sh|py|json|/)" \
  | sort -u

# === 阶段 3：检查 .gitignore 是否排除关键引用 ===

# 3.1 逐个检查可疑路径
git check-ignore -v cache/outputs/html/王永生-itinerary.html
git check-ignore -v cache/outputs/png/测试客户-itinerary.png
git check-ignore -v images/

# === 阶段 4：汇总缺失文件 ===

# 4.1 检查 SKILL.md 中引用但磁盘不存在的文件
for f in $(grep -oP '`references/[^`]+\.md`' SKILL.md | tr -d '`'); do
  if [ ! -f "skills/business/signing-workflow-system/$f" ]; then
    echo "缺失: $f"
  fi
done

# 4.2 全项目未追踪文件分类统计
git status --short | grep "^??" | awk '{print $2}' | awk -F/ '{print $1}' | sort | uniq -c | sort -rn
```

## 已确认的安全清单

| 目录/规则 | 是否追踪 | 原因 |
|-----------|---------|------|
| `data/active/` | ❌ | .gitignore — 客户隐私 |
| `data/archive/` | ❌ | .gitignore — 客户隐私 |
| `cache/` | ❌ | .gitignore — 运行时缓存 |
| `images/` | ❌ | 用户剪贴板截图，非项目资产 |
| `auth.json` | ❌ | .gitignore — 凭证 |
| `*.db` / `*.db-shm` / `*.db-wal` | ❌ | .gitignore — 数据库 |
| `sessions/` | ❌ | .gitignore — 会话记录 |
| `logs/` | ❌ | .gitignore — 日志 |
| `node/` / `bin/` | ❌ | 框架运行时 |
| `hermes-agent/` | ❌ | 框架自身 |

## 常见处理模式

### 模式 A：cache/ 中有关键模板

```
发现问题：SKILL.md 引用了 cache/outputs/html/王永生-itinerary.html
         但 cache/ 被 .gitignore 排除，clone 后渲染失败

处理：
  1. 复制到 skill 的 templates/ 子目录
  2. 更新 SKILL.md 中的路径引用
  3. git add + commit
  4. （可选）更新 .gitignore 移除对 templates/ 的排除
```

### 模式 B：测试案例在排除目录

```
发现问题：cache/outputs/ 下有 测试客户/REMINDER测试 的 HTML+PNG
         但 cache/ 被排除

处理：
  1. 在 skill 目录创建 test-fixtures/ 子目录
  2. 复制测试 HTML、PNG、JSON 进去
  3. git add + commit
  4. 在 SKILL.md References 中添加 Test Fixtures 条目
```

### 模式 C：过时引用（文件不存在）

```
发现问题：SKILL.md 引用了 references/image-generation-approach.md
         但磁盘上不存在

处理：
  1. 确认功能是否已合并到其他文档
  2. 如果是：删除过时引用，指向实际文档
  3. 如果否：报告用户，询问是否重建
```

## 2026-08-04 审计结果摘要

完整审计结果见 `references/git-upload-audit.md`（在 signing-workflow-system skill 中）。

| 发现 | 处理 |
|------|------|
| SOUL.md 过时路径（image-designer） | ✅ 修正为实际文档路径 |
| SKILL.md 3 个过时 references | ✅ 删除并添加实际资产引用 |
| 王永生背景模板在 cache/ 中 | ✅ 复制到 templates/backgrounds/ |
| 测试案例在 cache/outputs/ 中 | ✅ 复制到 test-fixtures/ |
| course-report-handoff.md 未追踪 | ✅ git add |
| git-backup skill 未追踪 | ✅ git add (profiles/code/skills/business/git-backup/) |

## 2026-08-04 第二轮审计补充

用户要求「再次检查」后发现的额外遗漏：

| 发现 | 处理 |
|------|------|
| `upload-audit-checklist.md` 自身未追踪 | ✅ git add（递归陷阱：审计工具本身也在待上传列表中） |
| SKILL.md 重复标题（两个「工作流 D」） | ✅ 合并为单一章节 + 安全铁律 |
| images/ 中 1080×1920 PNG 为用户剪贴板 | ❌ 不追踪（非项目资产，无 SKILL.md 引用） |

### 审计自身的递归陷阱

```
发现模式：用户连续追问「再检查」→ 每次审计都只检查 signing-workflow-system 目录
         → 遗漏了审计 skill（git-backup）自身的未追踪文件

解决方案：用户说「再检查」时，扩大审计范围到与目标 skill 关联的所有 skill 目录，
        包括审计 skill 自身。命令：

# 扩展审计范围
git ls-files --others --exclude-standard \
  skills/business/signing-workflow-system/ \
  profiles/code/skills/business/git-backup/

# 二次确认：git-backup 的所有 references 是否都在 git 中
diff <(git ls-files profiles/code/skills/business/git-backup/) \
     <(find profiles/code/skills/business/git-backup/ -type f | sort)
