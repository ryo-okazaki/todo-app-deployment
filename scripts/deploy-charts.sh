#!/bin/bash

# k8s/charts ディレクトリ内のすべてのChart（ローカル環境用）をインストールするスクリプト
# helmfileは使用せず、helm installコマンドを使用します

# エラーが発生した場合に停止
set -e

# プロジェクトのルートディレクトリを取得（スクリプトはscripts/deploy-charts.shとして実行される前提）
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# チャートディレクトリへのパス
CHARTS_DIR="${PROJECT_ROOT}/k8s/charts"

# ローカル環境用の値ファイル
LOCAL_VALUES="${PROJECT_ROOT}/k8s/environments/local/values.yaml"

NAMESPACE="default"

# ネームスペースの存在確認と作成
if ! kubectl get namespace "${NAMESPACE}" &> /dev/null; then
  echo "ネームスペース ${NAMESPACE} を作成します"
  kubectl create namespace "${NAMESPACE}"
fi

# 依存関係の順序を定義（helmfileを参考に）
declare -A DEPENDENCIES
DEPENDENCIES["postgresql"]="logging"
DEPENDENCIES["minio"]="logging"
DEPENDENCIES["mailhog"]="logging"
DEPENDENCIES["monitoring"]="logging"
DEPENDENCIES["express"]="postgresql minio"
DEPENDENCIES["next"]="express"

# インストール済みチャートを追跡
declare -A INSTALLED_CHARTS

# 指定されたチャートの依存関係がすべてインストールされているか確認
function dependencies_installed() {
  local chart_name=$1
  local deps=${DEPENDENCIES[$chart_name]}

  if [ -z "$deps" ]; then
    return 0 # 依存関係がない場合はOK
  fi

  for dep in $deps; do
    if [ -z "${INSTALLED_CHARTS[$dep]}" ]; then
      return 1 # 依存関係が未インストールの場合はNG
    fi
  done

  return 0 # すべての依存関係がインストール済み
}

# 全チャートのリストを取得
CHART_LIST=()
for CHART_DIR in "${CHARTS_DIR}"/*; do
  if [ -d "${CHART_DIR}" ] && [ -f "${CHART_DIR}/Chart.yaml" ]; then
    CHART_NAME=$(basename "${CHART_DIR}")
    # umbrellaチャートは最後にインストール
    if [ "${CHART_NAME}" != "umbrella" ]; then
      CHART_LIST+=("${CHART_NAME}")
    fi
  fi
done

echo "インストール対象のチャート："
for chart in "${CHART_LIST[@]}"; do
  echo "- ${chart}"
done

echo ""
echo "ローカル環境用のHelmチャートをインストールします..."
echo "ネームスペース: ${NAMESPACE}"
echo ""

# まずloggingをインストール（他のチャートの依存関係）
if [[ " ${CHART_LIST[@]} " =~ " logging " ]]; then
  echo "基盤サービス: logging をインストール中..."

  helm upgrade --install logging "${CHARTS_DIR}/logging" \
    --namespace "${NAMESPACE}" \
    --values "${LOCAL_VALUES}" \
    --create-namespace \
    --wait

  INSTALLED_CHARTS["logging"]=1
  echo "logging のインストールが完了しました"
  echo ""
fi

# 依存関係を考慮して残りのチャートをインストール
# すべてのチャートがインストールされるまで繰り返す
while [ ${#INSTALLED_CHARTS[@]} -lt ${#CHART_LIST[@]} ]; do
  installed_something=false

  for chart in "${CHART_LIST[@]}"; do
    # 既にインストール済みの場合はスキップ
    if [ -n "${INSTALLED_CHARTS[$chart]}" ]; then
      continue
    fi

    # 依存関係がすべてインストールされているか確認
    if dependencies_installed "$chart"; then
      echo "チャート ${chart} をインストール中..."

      helm upgrade --install ${chart} "${CHARTS_DIR}/${chart}" \
        --namespace "${NAMESPACE}" \
        --values "${LOCAL_VALUES}" \
        --create-namespace \
        --wait

      INSTALLED_CHARTS["$chart"]=1
      installed_something=true
      echo "${chart} のインストールが完了しました"
      echo ""
    fi
  done

  # この反復で何もインストールされなかった場合、依存関係の問題がある可能性がある
  if [ "$installed_something" = false ]; then
    echo "警告: 依存関係の問題により、以下のチャートをインストールできませんでした:"
    for chart in "${CHART_LIST[@]}"; do
      if [ -z "${INSTALLED_CHARTS[$chart]}" ]; then
        echo "- ${chart} (依存: ${DEPENDENCIES[$chart]})"
      fi
    done
    break
  fi
done

# アンブレラチャートを最後にインストール（存在する場合）
#UMBRELLA_CHART="${CHARTS_DIR}/umbrella"
#if [ -d "${UMBRELLA_CHART}" ] && [ -f "${UMBRELLA_CHART}/Chart.yaml" ]; then
#  echo "アンブレラチャートをインストール中..."
#
#  helm upgrade --install umbrella "${UMBRELLA_CHART}" \
#    --namespace "${NAMESPACE}" \
#    --values "${LOCAL_VALUES}" \
#    --create-namespace \
#    --wait
#
#  echo "アンブレラチャートのインストールが完了しました"
#fi

echo ""
echo "すべてのローカルチャートのインストールが完了しました！"
