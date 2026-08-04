# Git 知识库 — 签单助手备份手册

给大ice的 Git 速查手册，4 个板块覆盖所有常见问题。

---

## 板块 ①：首次上传冲突解决

### 问题：push 被拒，提示「远程已有内容」

```
! [rejected] main -> main (fetch first)
```

**原因**：创建仓库时勾选了 README/LICENSE，远程不是空的。

**解决方法**（3 步）：

```bash
cd /home/anna/.hermes

# 1. 拉取远程内容并合并（允许无关联历史）
git pull origin main --allow-unrelated-histories

# 2. 如果有冲突，解决后提交
git add .
git commit -m "合并远程初始化文件"

# 3. 推送
git push origin main
```

> 💡 工作流A 的脚本（git-init.sh）已内置此处理逻辑，直接运行即可。

---

## 板块 ②：日常更新标准流程

### 完整四步法

```bash
# ① 看看改了什么
cd /home/anna/.hermes
git status

# ② 暂存所有改动
git add .

# ③ 提交（写清楚改了什么）
git commit -m "优化：XXX"

# ④ 推送到远程
git push
```

### 状态图标解读

| git status 输出 | 含义 |
|----------------|------|
| `M 文件名` | 文件被修改了 |
| `?? 文件名` | 新文件，还没被 Git 追踪 |
| `A 文件名` | 新文件，已暂存 |
| `D 文件名` | 文件被删除了 |

### commit 信息怎么写

| 改动类型 | 示例 |
|---------|------|
| 新增功能 | `新增：客户索引自动更新` |
| 优化改进 | `优化：签单提醒规则` |
| 修复问题 | `修复：缴费海报生成bug` |
| 文档更新 | `文档：更新 SOUL.md 业务规则` |
| 日常微调 | `日常配置微调` |

---

## 板块 ③：语义化版本规范

### 版本号格式

```
v主版本.次版本.补丁版本
```

### 什么时候升级哪个数字

| 改动类型 | 升级 | 示例 |
|---------|------|------|
| 修复 bug | 补丁版本 +1 | v1.0.0 → v1.0.1 |
| 新增功能（兼容旧版） | 次版本 +1 | v1.0.1 → v1.1.0 |
| 重大改动（不兼容旧版） | 主版本 +1 | v1.1.0 → v2.0.0 |

### 版本历史示例

```
v0.1.0  — 初始开发版
v1.0.0  — 首个正式版
v1.1.0  — 新增客户索引系统
v1.1.1  — 修复海报背景图bug
v1.2.0  — 新增缴费逐项引导
v2.0.0  — 重构工作流架构
```

---

## 板块 ④：常见报错排查

### 报错 1：401 Unauthorized（令牌失效）

```
remote: Invalid username or password.
fatal: Authentication failed
```

**原因**：令牌过期或被撤销。

**解决**：
1. 去 git.uozi.com → 设置 → 应用 → 生成新令牌
2. 更新本地 remote URL：
```bash
git remote set-url origin https://annafby:新令牌@git.uozi.com/annafby/hermes-default-agent.git
```

---

### 报错 2：push 被拒绝

```
! [rejected] main -> main (non-fast-forward)
```

**原因**：远程有本地没有的新提交。

**解决**：
```bash
git pull origin main
# 解决冲突后
git push origin main
```

---

### 报错 3：文件冲突（CONFLICT）

```
CONFLICT (content): Merge conflict in SOUL.md
```

**原因**：本地和远程同时改了同一个文件。

**解决**：
1. 打开冲突文件，找到 `<<<<<<<` `=======` `>>>>>>>` 标记
2. 手动选择保留哪部分
3. 删除冲突标记
4. 保存后：
```bash
git add SOUL.md
git commit -m "解决冲突"
git push
```

---

### 报错 4：远程地址错误

```
fatal: repository '...' not found
```

**原因**：URL 写错了或仓库被删除。

**解决**：
```bash
# 查看当前地址
git remote -v

# 重新设置
git remote set-url origin https://git.uozi.com/annafby/hermes-default-agent.git
```

---

### 报错 5：凭证缓存异常

```
fatal: Authentication failed (反复提示输入密码)
```

**解决**：
```bash
# 清除旧缓存
git config --unset credential.helper
git credential-cache exit

# 重新缓存
git config credential.helper store
```

---

## 快速命令速查

| 命令 | 作用 |
|------|------|
| `git status` | 查看改了什么 |
| `git diff` | 查看具体改了什么内容 |
| `git log --oneline` | 查看提交历史 |
| `git log --oneline -5` | 查看最近 5 次提交 |
| `git remote -v` | 查看远程仓库地址 |
| `git tag -l` | 查看所有版本标签 |
| `git show v1.0.0` | 查看某个标签的详情 |
| `git reset --hard HEAD~1` | ⚠️ 回退到上一个版本（慎用） |

---

## 安全提醒

| ❌ 不要做 | ✅ 应该做 |
|----------|---------|
| 把令牌写在文件里 | 令牌只在 git remote URL 中 |
| 上传 .env 文件 | .gitignore 已排除 |
| 上传客户数据 | data/active/ 已排除 |
| 上传 sessions/ | 已排除 |
