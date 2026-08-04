#!/bin/bash
# ============================================
# Git 自动备份 — 工作流A：首次初始化上传
# 用途：首次将 default agent 上传到远程仓库
# 用法：bash git-init.sh
# ============================================

set -e

REPO_DIR="/home/anna/.hermes"
REMOTE_URL="https://git.uozi.com/annafby/hermes-default-agent.git"
USER_NAME="annafby"
USER_EMAIL="annafby@qq.com"
BRANCH="main"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "================================================"
echo "   🚀 Git 自动备份 — 首次初始化上传"
echo "================================================"
echo ""

# 步骤 1
echo -e "${BLUE}[1/9]${NC} 进入工作目录..."
cd "$REPO_DIR"
echo -e "  ${GREEN}✅${NC} $(pwd)"

# 步骤 2：初始化仓库（如未初始化）
echo ""
echo -e "${BLUE}[2/9]${NC} 检查 Git 仓库..."
if [ -d ".git" ]; then
    echo -e "  ${GREEN}✅${NC} 仓库已初始化"
else
    git init
    echo -e "  ${GREEN}✅${NC} 仓库已初始化"
fi

# 步骤 3：清除旧 remote + 绑定新 remote
echo ""
echo -e "${BLUE}[3/9]${NC} 绑定远程仓库..."
git remote remove origin 2>/dev/null || true
git remote add origin "$REMOTE_URL"
echo -e "  ${GREEN}✅${NC} 远程仓库已绑定：$REMOTE_URL"

# 步骤 4：配置用户信息
echo ""
echo -e "${BLUE}[4/9]${NC} 配置提交身份..."
git config user.name "$USER_NAME"
git config user.email "$USER_EMAIL"
echo -e "  ${GREEN}✅${NC} $USER_NAME <$USER_EMAIL>"

# 步骤 5：凭证缓存
echo ""
echo -e "${BLUE}[5/9]${NC} 配置凭证缓存..."
git config credential.helper store
echo -e "  ${GREEN}✅${NC} 令牌已缓存，后续无需重复输入"

# 步骤 6：拉取远程代码
echo ""
echo -e "${BLUE}[6/9]${NC} 拉取远程代码（兼容已有文件）..."
if git pull origin "$BRANCH" --allow-unrelated-histories 2>/dev/null; then
    echo -e "  ${GREEN}✅${NC} 远程代码已合并"
else
    echo -e "  ${YELLOW}⚠️${NC}  拉取失败，尝试直接推送..."
fi

# 步骤 7：暂存文件
echo ""
echo -e "${BLUE}[7/9]${NC} 暂存所有文件..."
git add .
echo -e "  ${GREEN}✅${NC} git add 完成"

echo ""
echo "  变更文件："
git status --short
echo ""

# 步骤 8：提交
echo -e "${BLUE}[8/9]${NC} 提交信息"
read -p "  👉 请输入提交信息（回车使用默认）：" COMMIT_MSG
if [ -z "$COMMIT_MSG" ]; then
    COMMIT_MSG="项目初始化完整代码上传 — $(date '+%Y-%m-%d %H:%M')"
fi

git commit -m "$COMMIT_MSG"
echo -e "  ${GREEN}✅${NC} 提交完成：$COMMIT_MSG"

# 步骤 9：推送
echo ""
echo -e "${BLUE}[9/9]${NC} 推送到远程..."
git push -u origin "$BRANCH"
echo -e "  ${GREEN}✅${NC} 推送完成"

# 完成
echo ""
echo "================================================"
echo -e "  ${GREEN}🎉 首次上传完成！${NC}"
echo ""
echo "  仓库地址：https://git.uozi.com/annafby/hermes-default-agent"
echo ""
echo "  💡 以后每次修改后，运行："
echo "     bash ~/.hermes/skills/business/git-backup/scripts/git-update.sh"
echo "  或直接对小code说「帮我备份」"
echo "================================================"
echo ""
