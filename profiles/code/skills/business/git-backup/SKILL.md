---
name: git-backup
description: 签单助手 default agent 自动备份到 Gitea — 首次上传、日常更新、版本打标，内置知识库
category: business
tags: [git, backup, gitea, 备份, 版本管理]
---

# Git 自动备份助手

签单跟进助手（default agent）的 Git 版本备份工具。内置固定配置、三大工作流、配套知识库。

---

## 内置固定配置

| 配置项 | 值 |
|--------|-----|
| 用户名 | `annafby` |
| 邮箱 | `annafby@qq.com` |
| 远程仓库 | `https://git.uozi.com/annafby/hermes-default-agent.git` |
| 本地目录 | `/home/anna/.hermes` |
| 默认分支 | `main` |
| 令牌 | ⚠️ 已嵌入本地 git remote URL，不写入文件 |

---

## 三大工作流

### 工作流 A：首次初始化上传

> **适用场景**：首次将 default agent 代码上传到远程仓库（远程已有 README/LICENSE 等初始化文件）

**手动步骤（共 9 步）：**

```
1. cd /home/anna/.hermes
2. git init（如未初始化）
3. 清除旧 remote → git remote remove origin（如有）
4. git remote add origin https://annafby:令牌@git.uozi.com/annafby/hermes-default-agent.git
5. git config user.name "annafby" && git config user.email "annafby@qq.com"
6. git config credential.helper store（永久缓存令牌）
7. git pull origin main --allow-unrelated-histories
8. git add .
9. git commit -m "你的提交信息"
10. git push -u origin main
```

**一键脚本：**
```bash
bash ~/.hermes/skills/business/git-backup/scripts/git-init.sh
```

---

### 工作流 B：日常迭代更新 ⭐（最常用）

> **适用场景**：每次修改了 SOUL.md、config.yaml、skills 等文件后，把改动同步到远程

**这是你最常用的工作流！** 我（小code）会一步步引导你完成。

#### 方式一：一键脚本（推荐，有交互引导）

```bash
bash ~/.hermes/skills/business/git-backup/scripts/git-update.sh
```

脚本会：
1. 🔍 自动展示你改了什么文件
2. ❓ 问你「这次改了什么？」（一句话描述）
3. 📋 展示即将提交的文件清单，等你确认
4. 🚀 自动 add → commit → push
5. ✅ 输出结果

#### 方式二：对小 code 说「帮我备份」

直接对我说以下任意一句：
- 「帮我备份」
- 「上传到 git」
- 「git 更新」
- 「推送代码」

我会自动：
1. 展示当前变更（`git status`）
2. 问你这次改了什么
3. 等你确认后一键执行 add → commit → push
4. 汇报结果

#### 方式三：手动三步（你记住就行）

```bash
cd /home/anna/.hermes
git add .
git commit -m "优化：XXX"
git push
```

---

### 工作流 C：版本标签发布

> **适用场景**：完成一个重要版本迭代后，打一个版本标签（如 v1.0.0、v2.1.0）

**一键脚本：**
```bash
bash ~/.hermes/skills/business/git-backup/scripts/git-tag.sh
```

脚本会引导你输入版本号（如 `v1.2.0`），然后自动打标签并推送到远程。

**手动步骤：**
```bash
cd /home/anna/.hermes
git tag -a v1.0.0 -m "第一个正式版本"
git push origin v1.0.0
```

---

## 使用指南（给大ice）

### 🟢 日常更新（你每次改完 agent 后做）

**最简单的方式**：对小 code 说「帮我备份」

我会自动检查改了什么 → 问你描述 → 帮你推送。

### 🟡 偶尔操作

| 你想做什么 | 怎么说 |
|-----------|--------|
| 看改了啥还没传 | 「git状态」或「看看改了啥」 |
| 回到旧版本 | 「我想回退到之前的版本」 |
| 查看提交历史 | 「git历史」 |
| 解决推送失败 | 「推送失败了帮我看看」 |

### 🔵 知识库查询

| 你想知道 | 怎么说 |
|---------|--------|
| 完整操作手册 | 「git知识库」或「git帮助」 |
| 报错怎么解决 | 「常见报错」 |
| 版本号怎么定 | 「版本规范」 |

---

## 安全规则

- ✅ 令牌已嵌入 git remote URL，skill 文件中不写
- ✅ `.gitignore` 永久排除 `.env`、`data/active/`、`data/archive/`
- ✅ 每次推送前展示变更清单
- ✅ 脚本异常自动停止

---

## 快速参考

| 命令 | 作用 |
|------|------|
| `git status` | 查看改了什么 |
| `git add .` | 暂存所有改动 |
| `git commit -m "..."` | 提交 |
| `git push` | 推送到远程 |
| `git log --oneline` | 看提交历史 |
| `git diff` | 看具体改了什么内容 |
