#!/usr/bin/env bash
set -euo pipefail

# ===========================================================
# Keycloak Realm Export Script
# 公式CLI (kcadm.sh) を使用してRealm構成を一括バックアップ
# ===========================================================

# === 設定 ===
KEYCLOAK_URL="http://localhost:8080"
ADMIN_REALM="master"
ADMIN_USER="admin"
ADMIN_PASSWORD="admin"
TARGET_REALM="microservice-app"
EXPORT_DIR="/opt/keycloak/exports/${TARGET_REALM}_export_$(date +%Y%m%d_%H%M%S)"

# === 初期化 ===
mkdir -p "${EXPORT_DIR}"

cd /opt/keycloak/bin

echo "🔐 Keycloak にログイン中..."
./kcadm.sh config credentials \
  --server "$KEYCLOAK_URL" \
  --realm "$ADMIN_REALM" \
  --user "$ADMIN_USER" \
  --password "$ADMIN_PASSWORD"

echo "✅ ログイン成功"

# === 1️⃣ Realm 全体情報 ===
echo "📦 Realm情報をエクスポート中..."
./kcadm.sh get realms/${TARGET_REALM} > "${EXPORT_DIR}/realm.json"

# === 2️⃣ Clients ===
echo "📦 Clientsをエクスポート中..."
./kcadm.sh get clients -r ${TARGET_REALM} > "${EXPORT_DIR}/clients.json"

# === 3️⃣ Roles ===
echo "📦 Rolesをエクスポート中..."
./kcadm.sh get roles -r ${TARGET_REALM} > "${EXPORT_DIR}/roles.json"

# === 4️⃣ Groups ===
echo "📦 Groupsをエクスポート中..."
./kcadm.sh get groups -r ${TARGET_REALM} > "${EXPORT_DIR}/groups.json"

# === 5️⃣ Users ===（ユーザーも含めたい場合）
echo "📦 Usersをエクスポート中..."
./kcadm.sh get users -r ${TARGET_REALM} > "${EXPORT_DIR}/users.json"

# === 6️⃣ Identity Providers ===
echo "📦 Identity Providersをエクスポート中..."
./kcadm.sh get identity-provider/instances -r ${TARGET_REALM} > "${EXPORT_DIR}/idp.json"

# === 7️⃣ IdP Mappers ===
echo "📦 Identity Provider Mappersをエクスポート中..."
mkdir -p "${EXPORT_DIR}/idp-mappers"
for idp in $(jq -r '.[].alias' "${EXPORT_DIR}/idp.json"); do
  echo "    ↳ ${idp}"
  ./kcadm.sh get identity-provider/instances/${idp}/mappers -r ${TARGET_REALM} \
    > "${EXPORT_DIR}/idp-mappers/${idp}-mappers.json"
done

# === 完了 ===
echo "✅ エクスポート完了: ${EXPORT_DIR}/"
