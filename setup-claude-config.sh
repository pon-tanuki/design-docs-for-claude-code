#!/bin/bash
#
# Claude Code設定ファイルセットアップスクリプト
# Usage: curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/setup-claude-config.sh | bash
#

set -e

# 色の定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ロゴ表示
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║   Claude Code 設定ファイルセットアップ                    ║
║   Claude Code Configuration Setup                         ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# 設定
REPO_URL="https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main"
CLAUDE_DIR=".claude"

# 現在のディレクトリを確認
echo -e "${BLUE}📁 現在のディレクトリ:${NC} $(pwd)"
echo ""

# インタラクティブモードかどうかを判定
if [ -t 0 ]; then
    INTERACTIVE=true
else
    INTERACTIVE=false
fi

# ダウンロード関数
download_file() {
    local url=$1
    local dest=$2
    local desc=$3

    echo -ne "  📄 ${desc}... "

    # ディレクトリが存在しない場合は作成
    mkdir -p "$(dirname "$dest")"

    if curl -fsSL "$url" -o "$dest" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗ (スキップ)${NC}"
        return 1
    fi
}

echo -e "${YELLOW}Claude Code設定ファイルをセットアップします${NC}"
echo ""
echo "この設定により、以下が可能になります："
echo "  • /update-doc でドキュメント更新（メタデータ自動更新）"
echo "  • /check-doc でドキュメント品質チェック"
echo "  • /new-phase-doc で新規ドキュメント作成"
echo ""

if [ "$INTERACTIVE" = true ]; then
    read -p "続行しますか？ [Y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ -n $REPLY ]]; then
        echo "セットアップをキャンセルしました"
        exit 0
    fi
fi

# ディレクトリ作成
mkdir -p "$CLAUDE_DIR/commands"

echo -e "\n${GREEN}▶ Claude Code設定ファイルをダウンロード中...${NC}"

# 設定ファイルのダウンロード
echo -e "\n${BLUE}━━━ 基本設定ファイル ━━━${NC}"
download_file "$REPO_URL/examples/.claude/settings.json" "$CLAUDE_DIR/settings.json" "settings.json"
download_file "$REPO_URL/examples/.claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md" "CLAUDE.md"

# カスタムコマンドのダウンロード
echo -e "\n${BLUE}━━━ カスタムコマンド ━━━${NC}"
download_file "$REPO_URL/examples/.claude/commands/update-doc.md" "$CLAUDE_DIR/commands/update-doc.md" "update-doc.md"
download_file "$REPO_URL/examples/.claude/commands/check-doc.md" "$CLAUDE_DIR/commands/check-doc.md" "check-doc.md"
download_file "$REPO_URL/examples/.claude/commands/new-phase-doc.md" "$CLAUDE_DIR/commands/new-phase-doc.md" "new-phase-doc.md"

# 完了メッセージ
echo -e "\n${GREEN}✨ Claude Code設定のセットアップが完了しました！${NC}"
echo -e "\n${BLUE}📂 設定ファイルの場所:${NC}"
echo "  .claude/settings.json          - Claude Code設定"
echo "  .claude/CLAUDE.md              - プロジェクトルール"
echo "  .claude/commands/update-doc.md - ドキュメント更新コマンド"
echo "  .claude/commands/check-doc.md  - 品質チェックコマンド"
echo "  .claude/commands/new-phase-doc.md - 新規作成コマンド"
echo ""
echo -e "${YELLOW}使用可能なカスタムコマンド:${NC}"
echo "  /update-doc <ファイル> <変更内容>     - ドキュメント更新"
echo "  /check-doc <ファイル>                 - 品質チェック"
echo "  /new-phase-doc <フェーズ> <種類>      - 新規作成"
echo ""
echo -e "${BLUE}例:${NC}"
echo "  claude"
echo "  /new-phase-doc planning project_overview"
echo "  /update-doc docs/01_planning/project_overview.md 予算を変更"
echo "  /check-doc docs/01_planning/project_overview.md"
echo ""
echo -e "${GREEN}詳細は .claude/CLAUDE.md を参照してください${NC}"
echo ""

# .gitignoreの確認と追加
if [ -f ".gitignore" ]; then
    if ! grep -q "^.claude/settings.local.json" .gitignore 2>/dev/null; then
        echo -e "${YELLOW}💡 Tips:${NC} .gitignore に以下を追加することを推奨します："
        echo "  .claude/settings.local.json  # 個人設定"
    fi
else
    echo -e "${YELLOW}💡 Tips:${NC} .gitignore ファイルを作成して以下を追加することを推奨します："
    echo "  .claude/settings.local.json  # 個人設定"
fi
echo ""
