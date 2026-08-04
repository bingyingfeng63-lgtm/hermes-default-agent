#!/bin/bash
# ============================================
# Git 自动备份 — 工作流B：日常迭代更新
# 用途：每次修改 agent 文件后，一键同步到远程
# 用法：bash git-update.sh
# ============================================

set -e  # 任何一步失败就停止

REPO_DIR="/home/anna/.hermes"
REMOTE_URL="https://git.uozi.com/annafby/hermes-default-agent.git"
USER_NAME="annafby"
USER_EMAIL="annafby@qq.com"
BRANCH="main"

# ── 颜色定义 ──
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 无色

echo ""
echo "================================================"
echo "   🔄 Git 自动备份 — 日常迭代更新"
echo "================================================"
echo ""

# ── 步骤 1：进入工作目录 ──
echo -e "${BLUE}[1/7]${NC} 进入工作目录..."
cd "$REPO_DIR"
echo -e "  ${GREEN}✅${NC} 当前目录：$(pwd)"

# ── 步骤 2：校验远程仓库 ──
echo ""
echo -e "${BLUE}[2/7]${NC} 校验远程仓库绑定..."

CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
if [ "$CURRENT_REMOTE" != "$REMOTE_URL" ]; then
    echo -e "  ${YELLOW}⚠️${NC}  远程地址不匹配，正在重新绑定..."
    git remote remove origin 2>/dev/null || true
    git remote add origin "$REMOTE_URL"
    echo -e "  ${GREEN}✅${NC} 远程仓库已重新绑定"
else
    echo -e "  ${GREEN}✅${NC} 远程仓库绑定正确"
fi

# ── 步骤 3：配置用户信息 ──
echo ""
echo -e "${BLUE}[3/7]${NC} 配置提交身份..."

git config user.name "$USER_NAME"
git config user.email "$USER_EMAIL"
echo -e "  ${GREEN}✅${NC} 提交者：$USER_NAME <$USER_EMAIL>"

# 确保凭证缓存（避免每次输密码）
git config credential.helper store

# ── 步骤 4：拉取远程最新代码 ──
echo ""
echo -e "${BLUE}[4/7]${NC} 拉取远程最新代码..."

if git pull origin "$BRANCH" 2>/dev/null; then
    echo -e "  ${GREEN}✅${NC} 远程代码已同步"
else
    echo -e "  ${YELLOW}⚠️${NC}  拉取失败（可能远程无新内容），继续..."
fi

# ── 步骤 5：展示变更文件 ──
echo ""
echo -e "${BLUE}[5/7]${NC} 当前变更文件清单："
echo "  ─────────────────────────────────────"

CHANGES=$(git status --short 2>/dev/null)
if [ -z "$CHANGES" ]; then
    echo -e "  ${YELLOW}📭 没有需要提交的变更，无需推送。${NC}"
    echo ""
    exit 0
fi

echo "$CHANGES" | while read line; do
    STATUS="${line:0:2}"
    FILE="${line:3}"
    case "$STATUS" in
        "M "|" M") echo -e "  ✏️  修改：$FILE" ;;
        "A "|"AM") echo -e "  ➕ 新增：$FILE" ;;
        "D "|" D") echo -e "  🗑️  删除：$FILE" ;;
        "??")     echo -e "  ❓ 未追踪：$FILE" ;;
        *)        echo -e "  📄 $STATUS $FILE" ;;
    esac
done

echo "  ─────────────────────────────────────"

# ── 步骤 6：交互式输入提交信息 ──
echo ""
echo -e "${BLUE}[6/7]${NC} 提交信息"
echo ""
echo "  📝 这次改了什么？"
echo ""
echo "  示例："
echo "    · 优化签单提醒规则"
echo "    · 新增客户索引自动更新"
echo "    · 修复缴费海报生成bug"
echo "    · 批量更新SKILL文档"
echo "    · 日常配置微调"
echo ""
read -p "  👉 请输入提交信息（回车使用默认）：" COMMIT_MSG

if [ -z "$COMMIT_MSG" ]; then
    COMMIT_MSG="日常迭代更新 — $(date '+%Y-%m-%d %H:%M')"
    echo ""
    echo -e "  ${YELLOW}ℹ️${NC}  使用默认信息：$COMMIT_MSG"
fi

# ── 确认 ──
echo ""
echo "  ─────────────────────────────────────"
echo -e "  ${YELLOW}即将执行：${NC}"
echo "    git add ."
echo "    git commit -m \"$COMMIT_MSG\""
echo "    git push origin $BRANCH"
echo "  ─────────────────────────────────────"
echo ""
read -p "  ✅ 确认推送？[Y/n] " CONFIRM

if [ "$CONFIRM" = "n" ] || [ "$CONFIRM" = "N" ]; then
    echo ""
    echo -e "  ${YELLOW}🚫 已取消推送。${NC}"
    exit 0
fi

# ── 步骤 7：执行推送 ──
echo ""
echo -e "${BLUE}[7/7]${NC} 执行推送..."

git add .
echo -e "  ${GREEN}✅${NC} git add 完成"

git commit -m "$COMMIT_MSG"
echo -e "  ${GREEN}✅${NC} git commit 完成"

git push origin "$BRANCH"
echo -e "  ${GREEN}✅${NC} git push 完成"

# ── 完成 ──
echo ""
echo "================================================"
echo -e "  ${GREEN}🎉 推送成功！${NC}"
echo ""
echo "  仓库地址：https://git.uozi.com/annafby/hermes-default-agent"
echo ""
echo "  💡 下次更新直接对我说「帮我备份」即可～"
echo "================================================"
echo ""
