#!/bin/bash

echo "Importing environment variables from $1"

# ファイルが存在するかチェック
if [ ! -f "$1" ]; then
    echo "Error: File $1 not found"
    exit 1
fi

# .envファイルを1行ずつ読み込み
while IFS= read -r line || [ -n "$line" ]; do
    # 空行とコメント行をスキップ
    if [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*# ]]; then
        continue
    fi

    # 変数をエクスポート
    if [[ "$line" =~ ^[[:space:]]*([^=]+)=(.*)$ ]]; then
        export "$line"
    fi
done < "$1"
