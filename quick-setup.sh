#!/bin/bash
#
# クイックセットアップスクリプト (非インタラクティブ版)
# Usage: curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/quick-setup.sh | bash
# または環境変数で設定:
# DOCS_DIR=documents PHASE=all curl -fsSL ... | bash
#

set -e

# デフォルト設定
DOCS_DIR="${DOCS_DIR:-docs}"
PHASE="${PHASE:-all}"
REPO_URL="https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main"

echo "🚀 設計書テンプレートをセットアップ中..."
echo "📂 ディレクトリ: ${DOCS_DIR}"
echo "📋 フェーズ: ${PHASE}"
echo ""

# ディレクトリ作成
mkdir -p "$DOCS_DIR"

# ダウンロード関数
download() {
    local url=$1
    local dest=$2
    mkdir -p "$(dirname "$dest")"
    curl -fsSL "$url" -o "$dest" 2>/dev/null || true
}

# フェーズ別ダウンロード
download_planning() {
    echo "📝 計画フェーズのテンプレートをダウンロード..."
    download "$REPO_URL/templates/01_planning/README.md" "$DOCS_DIR/01_planning/README.md"
    download "$REPO_URL/templates/01_planning/project_overview.md" "$DOCS_DIR/01_planning/project_overview.md"
    download "$REPO_URL/templates/01_planning/requirements_specification.md" "$DOCS_DIR/01_planning/requirements_specification.md"
    download "$REPO_URL/templates/01_planning/use_case_document.md" "$DOCS_DIR/01_planning/use_case_document.md"
}

download_design() {
    echo "🎨 設計フェーズのテンプレートをダウンロード..."
    download "$REPO_URL/templates/02_design/README.md" "$DOCS_DIR/02_design/README.md"
    download "$REPO_URL/templates/02_design/system_design.md" "$DOCS_DIR/02_design/system_design.md"
    download "$REPO_URL/templates/02_design/database_design.md" "$DOCS_DIR/02_design/database_design.md"
    download "$REPO_URL/templates/02_design/api_specification.md" "$DOCS_DIR/02_design/api_specification.md"
    download "$REPO_URL/templates/02_design/screen_design.md" "$DOCS_DIR/02_design/screen_design.md"
}

download_development() {
    echo "💻 開発フェーズのテンプレートをダウンロード..."
    download "$REPO_URL/templates/03_development/README.md" "$DOCS_DIR/03_development/README.md"
    download "$REPO_URL/templates/03_development/coding_standards.md" "$DOCS_DIR/03_development/coding_standards.md"
    download "$REPO_URL/templates/03_development/development_setup.md" "$DOCS_DIR/03_development/development_setup.md"
    download "$REPO_URL/templates/03_development/technical_specification.md" "$DOCS_DIR/03_development/technical_specification.md"
}

download_testing() {
    echo "🧪 テストフェーズのテンプレートをダウンロード..."
    download "$REPO_URL/templates/04_testing/README.md" "$DOCS_DIR/04_testing/README.md"
    download "$REPO_URL/templates/04_testing/test_plan.md" "$DOCS_DIR/04_testing/test_plan.md"
    download "$REPO_URL/templates/04_testing/test_case_specification.md" "$DOCS_DIR/04_testing/test_case_specification.md"
    download "$REPO_URL/templates/04_testing/test_report.md" "$DOCS_DIR/04_testing/test_report.md"
}

download_operation() {
    echo "⚙️  運用フェーズのテンプレートをダウンロード..."
    download "$REPO_URL/templates/05_operation/README.md" "$DOCS_DIR/05_operation/README.md"
    download "$REPO_URL/templates/05_operation/operation_manual.md" "$DOCS_DIR/05_operation/operation_manual.md"
    download "$REPO_URL/templates/05_operation/incident_response.md" "$DOCS_DIR/05_operation/incident_response.md"
    download "$REPO_URL/templates/05_operation/maintenance_plan.md" "$DOCS_DIR/05_operation/maintenance_plan.md"
}

download_common() {
    echo "📚 共通ドキュメントをダウンロード..."
    download "$REPO_URL/templates/06_common/README.md" "$DOCS_DIR/06_common/README.md"
    download "$REPO_URL/templates/06_common/document_format.md" "$DOCS_DIR/06_common/document_format.md"
    download "$REPO_URL/templates/06_common/template_base.md" "$DOCS_DIR/06_common/template_base.md"
    download "$REPO_URL/templates/06_common/README_template.md" "$DOCS_DIR/06_common/README_template.md"
    download "$REPO_URL/templates/06_common/CHANGELOG_template.md" "$DOCS_DIR/06_common/CHANGELOG_template.md"
    download "$REPO_URL/templates/06_common/ADR_template.md" "$DOCS_DIR/06_common/ADR_template.md"
    download "$REPO_URL/templates/06_common/security_design.md" "$DOCS_DIR/06_common/security_design.md"
    download "$REPO_URL/templates/06_common/performance_design.md" "$DOCS_DIR/06_common/performance_design.md"
}

# フェーズ選択に応じてダウンロード
case $PHASE in
    all)
        download_planning
        download_design
        download_development
        download_testing
        download_operation
        download_common
        ;;
    planning|01)
        download_planning
        ;;
    design|02)
        download_design
        ;;
    development|dev|03)
        download_development
        ;;
    testing|test|04)
        download_testing
        ;;
    operation|ops|05)
        download_operation
        ;;
    common|06)
        download_common
        ;;
    *)
        echo "❌ 不明なフェーズ: $PHASE"
        echo "利用可能: all, planning, design, development, testing, operation, common"
        exit 1
        ;;
esac

# メインREADME
download "$REPO_URL/README.md" "$DOCS_DIR/README.md"

echo ""
echo "✅ セットアップ完了！"
echo "📂 ${DOCS_DIR}/ を確認してください"
echo ""
echo "使い方:"
echo "  cd ${DOCS_DIR}"
echo "  # Claude Code でテンプレートを編集"
echo ""
