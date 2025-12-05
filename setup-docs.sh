#!/bin/bash
#
# 設計書テンプレートセットアップスクリプト
# Usage: curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/setup-docs.sh | bash
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
║   設計書テンプレートセットアップ                          ║
║   Design Document Templates Setup                         ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# 設定
REPO_URL="https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main"
DOCS_DIR="docs"

# 現在のディレクトリを確認
echo -e "${BLUE}📁 現在のディレクトリ:${NC} $(pwd)"
echo ""

# インタラクティブモードかどうかを判定
if [ -t 0 ]; then
    INTERACTIVE=true
else
    INTERACTIVE=false
fi

# ドキュメントディレクトリ名の入力
if [ "$INTERACTIVE" = true ]; then
    echo -e "${YELLOW}ドキュメントを配置するディレクトリ名を入力してください (デフォルト: docs):${NC}"
    read -r input_dir
    if [ -n "$input_dir" ]; then
        DOCS_DIR="$input_dir"
    fi
fi

echo -e "${BLUE}📂 ドキュメントディレクトリ:${NC} ${DOCS_DIR}"
echo ""

# テンプレートの選択
echo -e "${YELLOW}必要なテンプレートを選択してください:${NC}"
echo ""
echo "  1) すべてのテンプレート (推奨)"
echo "  2) 計画フェーズのみ (01_planning)"
echo "  3) 設計フェーズのみ (02_design)"
echo "  4) 開発フェーズのみ (03_development)"
echo "  5) テストフェーズのみ (04_testing)"
echo "  6) 運用フェーズのみ (05_operation)"
echo "  7) 共通ドキュメントのみ (06_common)"
echo "  8) カスタム選択 (複数選択可能)"
echo ""

if [ "$INTERACTIVE" = true ]; then
    read -p "選択してください [1-8] (デフォルト: 1): " choice
    choice=${choice:-1}
else
    choice=1
fi

# ディレクトリの作成
mkdir -p "$DOCS_DIR"

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

# フェーズごとのテンプレートをダウンロード
download_phase() {
    local phase=$1
    local phase_name=$2

    echo -e "\n${BLUE}━━━ ${phase_name} ━━━${NC}"

    case $phase in
        "01_planning")
            download_file "$REPO_URL/templates/01_planning/README.md" "$DOCS_DIR/01_planning/README.md" "README"
            download_file "$REPO_URL/templates/01_planning/project_overview.md" "$DOCS_DIR/01_planning/project_overview.md" "プロジェクト概要書"
            download_file "$REPO_URL/templates/01_planning/requirements_specification.md" "$DOCS_DIR/01_planning/requirements_specification.md" "要件定義書"
            download_file "$REPO_URL/templates/01_planning/use_case_document.md" "$DOCS_DIR/01_planning/use_case_document.md" "ユースケース記述書"
            ;;
        "02_design")
            download_file "$REPO_URL/templates/02_design/README.md" "$DOCS_DIR/02_design/README.md" "README"
            download_file "$REPO_URL/templates/02_design/system_design.md" "$DOCS_DIR/02_design/system_design.md" "システム設計書"
            download_file "$REPO_URL/templates/02_design/database_design.md" "$DOCS_DIR/02_design/database_design.md" "データベース設計書"
            download_file "$REPO_URL/templates/02_design/api_specification.md" "$DOCS_DIR/02_design/api_specification.md" "API仕様書"
            download_file "$REPO_URL/templates/02_design/screen_design.md" "$DOCS_DIR/02_design/screen_design.md" "画面設計書"
            ;;
        "03_development")
            download_file "$REPO_URL/templates/03_development/README.md" "$DOCS_DIR/03_development/README.md" "README"
            download_file "$REPO_URL/templates/03_development/coding_standards.md" "$DOCS_DIR/03_development/coding_standards.md" "コーディング規約"
            download_file "$REPO_URL/templates/03_development/development_setup.md" "$DOCS_DIR/03_development/development_setup.md" "開発環境構築手順"
            download_file "$REPO_URL/templates/03_development/technical_specification.md" "$DOCS_DIR/03_development/technical_specification.md" "技術仕様書"
            ;;
        "04_testing")
            download_file "$REPO_URL/templates/04_testing/README.md" "$DOCS_DIR/04_testing/README.md" "README"
            download_file "$REPO_URL/templates/04_testing/test_plan.md" "$DOCS_DIR/04_testing/test_plan.md" "テスト計画書"
            download_file "$REPO_URL/templates/04_testing/test_case_specification.md" "$DOCS_DIR/04_testing/test_case_specification.md" "テストケース仕様書"
            download_file "$REPO_URL/templates/04_testing/test_report.md" "$DOCS_DIR/04_testing/test_report.md" "テスト報告書"
            ;;
        "05_operation")
            download_file "$REPO_URL/templates/05_operation/README.md" "$DOCS_DIR/05_operation/README.md" "README"
            download_file "$REPO_URL/templates/05_operation/operation_manual.md" "$DOCS_DIR/05_operation/operation_manual.md" "運用手順書"
            download_file "$REPO_URL/templates/05_operation/incident_response.md" "$DOCS_DIR/05_operation/incident_response.md" "障害対応手順書"
            download_file "$REPO_URL/templates/05_operation/maintenance_plan.md" "$DOCS_DIR/05_operation/maintenance_plan.md" "保守・メンテナンス計画書"
            ;;
        "06_common")
            download_file "$REPO_URL/templates/06_common/README.md" "$DOCS_DIR/06_common/README.md" "README"
            download_file "$REPO_URL/templates/06_common/document_format.md" "$DOCS_DIR/06_common/document_format.md" "ドキュメント共通フォーマット"
            download_file "$REPO_URL/templates/06_common/template_base.md" "$DOCS_DIR/06_common/template_base.md" "テンプレートベース"
            download_file "$REPO_URL/templates/06_common/README_template.md" "$DOCS_DIR/06_common/README_template.md" "READMEテンプレート"
            download_file "$REPO_URL/templates/06_common/CHANGELOG_template.md" "$DOCS_DIR/06_common/CHANGELOG_template.md" "CHANGELOGテンプレート"
            download_file "$REPO_URL/templates/06_common/ADR_template.md" "$DOCS_DIR/06_common/ADR_template.md" "ADRテンプレート"
            download_file "$REPO_URL/templates/06_common/security_design.md" "$DOCS_DIR/06_common/security_design.md" "セキュリティ設計書"
            download_file "$REPO_URL/templates/06_common/performance_design.md" "$DOCS_DIR/06_common/performance_design.md" "パフォーマンス設計書"
            ;;
    esac
}

# 選択に応じてダウンロード
echo -e "\n${GREEN}▶ テンプレートをダウンロード中...${NC}"

case $choice in
    1)
        # すべて
        download_phase "01_planning" "計画フェーズ"
        download_phase "02_design" "設計フェーズ"
        download_phase "03_development" "開発フェーズ"
        download_phase "04_testing" "テストフェーズ"
        download_phase "05_operation" "運用フェーズ"
        download_phase "06_common" "共通ドキュメント"
        ;;
    2)
        download_phase "01_planning" "計画フェーズ"
        ;;
    3)
        download_phase "02_design" "設計フェーズ"
        ;;
    4)
        download_phase "03_development" "開発フェーズ"
        ;;
    5)
        download_phase "04_testing" "テストフェーズ"
        ;;
    6)
        download_phase "05_operation" "運用フェーズ"
        ;;
    7)
        download_phase "06_common" "共通ドキュメント"
        ;;
    8)
        if [ "$INTERACTIVE" = true ]; then
            echo -e "\n${YELLOW}ダウンロードしたいフェーズを選択してください (スペース区切り):${NC}"
            echo "  1: 計画  2: 設計  3: 開発  4: テスト  5: 運用  6: 共通"
            read -p "例) 1 2 6: " phases

            for phase in $phases; do
                case $phase in
                    1) download_phase "01_planning" "計画フェーズ" ;;
                    2) download_phase "02_design" "設計フェーズ" ;;
                    3) download_phase "03_development" "開発フェーズ" ;;
                    4) download_phase "04_testing" "テストフェーズ" ;;
                    5) download_phase "05_operation" "運用フェーズ" ;;
                    6) download_phase "06_common" "共通ドキュメント" ;;
                esac
            done
        else
            echo -e "${RED}エラー: カスタム選択はインタラクティブモードでのみ使用可能です${NC}"
            exit 1
        fi
        ;;
    *)
        echo -e "${RED}無効な選択です${NC}"
        exit 1
        ;;
esac

# メインREADMEのダウンロード
echo -e "\n${BLUE}━━━ プロジェクトREADME ━━━${NC}"
download_file "$REPO_URL/README.md" "$DOCS_DIR/README.md" "README.md"

# Claude Code設定のセットアップを提案
echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}💡 Claude Code設定ファイルもセットアップしますか？${NC}"
echo ""
echo "Claude Code設定をセットアップすると、以下が可能になります："
echo "  • /update-doc でドキュメント更新（メタデータ自動更新）"
echo "  • /check-doc でドキュメント品質チェック"
echo "  • /new-phase-doc で新規ドキュメント作成"
echo ""

if [ "$INTERACTIVE" = true ]; then
    read -p "Claude Code設定もセットアップしますか？ [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        echo -e "\n${GREEN}▶ Claude Code設定をセットアップ中...${NC}"
        curl -fsSL "$REPO_URL/setup-claude-config.sh" | bash
    else
        echo -e "${BLUE}スキップしました。後でセットアップする場合は以下を実行してください:${NC}"
        echo "  curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/setup-claude-config.sh | bash"
    fi
fi

# 完了メッセージ
echo -e "\n${GREEN}✨ セットアップが完了しました！${NC}"
echo -e "\n${BLUE}📂 ドキュメントの場所:${NC} ${DOCS_DIR}/"
echo ""
echo -e "${YELLOW}次のステップ:${NC}"
echo "  1. ${DOCS_DIR}/ ディレクトリ内のテンプレートを確認"
echo "  2. プロジェクトの要件に応じてテンプレートを編集"
echo "  3. Claude Code にテンプレートの更新を依頼"
echo ""
echo -e "${BLUE}例:${NC}"
echo "  cd ${DOCS_DIR}/01_planning"
echo "  # Claude Code で project_overview.md を編集"
echo ""
echo -e "${GREEN}詳細は ${DOCS_DIR}/README.md を参照してください${NC}"
echo ""
