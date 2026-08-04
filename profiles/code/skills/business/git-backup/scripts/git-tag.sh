#!/bin/bash
# ============================================
# Git 自动备份 — 工作流C：版本标签发布
# 用途：大版本迭代后打版本标签
# 用法：bash git-tag.sh
# ============================================

set -e

REPO_DIR="/home/anna/.hermes"
REMOTE_URL="https://git.uozi.com/annafby/hermes-default-agent.git"
BRANCH="main"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "================================================"
echo "   🏷️  Git 版本标签发布"
echo "================================================"
echo ""

# 步骤 1
echo -e "${BLUE}[1/5]${NC} 进入工作目录..."
cd "$REPO_DIR"
echo -e "  ${GREEN}✅${NC} $(pwd)"

# 步骤 2：展示当前版本历史
echo ""
echo -e "${BLUE}[2/5]${NC} 已有版本标签："
EXISTING_TAGS=$(git tag -l 2>/dev/null)
if [ -z "$EXISTING_TAGS" ]; then
    echo -e "  ${YELLOW}📭 暂无版本标签${NC}"
else
    echo "$EXISTING_TAGS" | while read tag; do
        echo -e "  🏷️  $tag"
    done
fi

# 步骤 3：显示最近提交
echo ""
echo -e "${BLUE}[3/5]${NC} 最近 5 次提交："
git log --oneline -5 2>/dev/null
echo ""

# 步骤 4：输入版本号
echo ""
echo -e "${BLUE}[4/5]${NC} 版本信息"
echo ""
echo "  📐 语义化版本规范：v主版本.次版本.补丁版本"
echo "     例：v1.0.0（首个正式版）"
echo "         v1.1.0（新增功能）"
echo "         v1.1.1（修复bug）"
echo "         v2.0.0（重大更新）"
echo ""
read -p "  👉 请输入版本号（如 v1.0.0）：" VERSION

if [ -z "$VERSION" ]; then
    echo -e "  ${RED}❌ 版本号不能为空，已取消。${NC}"
    exit 1
fi

# 检查版本号格式
if ! echo "$VERSION" | grep -qE '^v[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo -e "  ${RED}❌ 版本号格式错误！应为 v主版本.次版本.补丁版本（如 v1.0.0）${NC}"
    exit 1
fi

read -p "  👉 版本说明（如「首个正式版本」）：" TAG_MSG
if [ -z "$TAG_MSG" ]; then
    TAG_MSG="版本 $VERSION"
fi

# 步骤 5：创建并推送标签
echo ""
echo -e "${BLUE}[5/5]${NC} 创建并推送标签..."

git tag -a "$VERSION" -m "$TAG_MSG"
echo -e "  ${GREEN}✅${NC} 本地标签 $VERSION 已创建"

git push origin "$VERSION"
echo -e "  ${GREEN}✅${NC} 标签已推送到远程"

# 完成
echo ""
echo "================================================"
echo -e "  ${GREEN}🎉 版本发布成功！${NC}"
echo ""
echo "  版本号：$VERSION"
echo "  说明：$TAG_MSG"
echo ""
echo "  查看 Releases："
echo "  https://git.uozi.com/annafby/hermes-default-agent/releases"
echo "================================================"
echo ""
