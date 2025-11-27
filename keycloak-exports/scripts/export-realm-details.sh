#!/usr/bin/env bash
set -euo pipefail

# ===========================================================
# Keycloak Realm Export Script + Authentication Flow Export
# ===========================================================

# === 設定 ===
KEYCLOAK_URL="http://auth-keycloak:8080"
ADMIN_REALM="master"
ADMIN_USER="admin"
ADMIN_PASSWORD="admin"
TARGET_REALM="microservice-app"
EXPORT_DIR="/opt/keycloak/exports/${TARGET_REALM}_export_$(date +%Y%m%d_%H%M%S)"

# === 初期化 ===
mkdir -p "${EXPORT_DIR}"

echo "🔐 Keycloak にログイン中..."
kcadm.sh config credentials \
  --server "$KEYCLOAK_URL" \
  --realm "$ADMIN_REALM" \
  --user "$ADMIN_USER" \
  --password "$ADMIN_PASSWORD"

echo "✅ ログイン成功"

# === 1. Realm 全体情報 ===
echo "📦 Realm情報をエクスポート中..."
kcadm.sh get realms/${TARGET_REALM} > "${EXPORT_DIR}/realm.json"

# === 2. Clients ===
echo "📦 Clientsをエクスポート中..."
kcadm.sh get clients -r ${TARGET_REALM} > "${EXPORT_DIR}/clients.json"

# === 3. Roles ===
echo "📦 Rolesをエクスポート中..."
kcadm.sh get roles -r ${TARGET_REALM} > "${EXPORT_DIR}/roles.json"

# === 4. Groups ===
echo "📦 Groupsをエクスポート中..."
kcadm.sh get groups -r ${TARGET_REALM} > "${EXPORT_DIR}/groups.json"

# === 5. Users ===（ユーザーも含めたい場合）
echo "📦 Usersをエクスポート中..."
kcadm.sh get users -r ${TARGET_REALM} > "${EXPORT_DIR}/users.json"

# === 6. Identity Providers ===
echo "📦 Identity Providersをエクスポート中..."
kcadm.sh get identity-provider/instances -r ${TARGET_REALM} > "${EXPORT_DIR}/idp.json"

# === 7. IdP Mappers ===
echo "📦 Identity Provider Mappersをエクスポート中..."
mkdir -p "${EXPORT_DIR}/idp-mappers"
for idp in $(jq -r '.[].alias' "${EXPORT_DIR}/idp.json"); do
  echo "    ↳ ${idp}"
  kcadm.sh get identity-provider/instances/${idp}/mappers -r ${TARGET_REALM} \
    > "${EXPORT_DIR}/idp-mappers/${idp}-mappers.json"
done

# === 8. Client Scopes ===
echo "📦 Client Scopesをエクスポート中..."
mkdir -p "${EXPORT_DIR}/client-scopes"
kcadm.sh get client-scopes -r ${TARGET_REALM} > "${EXPORT_DIR}/client-scopes/all-client-scopes.json"

# 各スコープごとに詳細を出力
for scope_id in $(jq -r '.[].id' "${EXPORT_DIR}/client-scopes/all-client-scopes.json"); do
  scope_name=$(jq -r ".[] | select(.id==\"${scope_id}\") | .name" "${EXPORT_DIR}/client-scopes/all-client-scopes.json")
  echo "    ↳ ${scope_name}"
  kcadm.sh get client-scopes/${scope_id} -r ${TARGET_REALM} \
    > "${EXPORT_DIR}/client-scopes/${scope_name}.json"
done


# === 9. Authentication Flows ===
echo "📦 Authentication Flows をエクスポート..."
mkdir -p "${EXPORT_DIR}/authentication-flows"

# すべてのフローを一括取得
kcadm.sh get authentication/flows -r ${TARGET_REALM} \
  > "${EXPORT_DIR}/authentication-flows/all-flows.json"

echo "📦 各 Authentication Flow の詳細 export..."

urlencode() {
    jq -rn --arg v "$1" '$v|@uri'
  }

for flow_alias in $(jq -r '.[].alias' "${EXPORT_DIR}/authentication-flows/all-flows.json"); do
  echo "    ↳ ${flow_alias}"

  encoded_alias=$(urlencode "$flow_alias")

  kcadm.sh get "authentication/flows/${encoded_alias}/executions" -r ${TARGET_REALM} \
        > "${EXPORT_DIR}/authentication-flows/${flow_alias}-executions.json" \
        || echo "⚠️  executions が存在しないためスキップ: ${flow_alias}"
done

# === 10. IDP が使用している ===
echo "📦 IDP が指定している First Login Flow を個別バックアップ..."

mkdir -p "${EXPORT_DIR}/idp-first-login-flows"

for idp in $(jq -r '.[].alias' "${EXPORT_DIR}/idp.json"); do
  first_flow=$(jq -r ".[] | select(.alias==\"${idp}\") | .firstBrokerLoginFlowAlias" "${EXPORT_DIR}/idp.json")

  if [[ "${first_flow}" != "null" ]]; then
    echo "    ↳ ${idp} の First Login Flow: ${first_flow}"

    # 1) 本体（flow の要素）を all-flows.json から抽出
    jq ".[] | select(.alias==\"${first_flow}\")" \
      "${EXPORT_DIR}/authentication-flows/all-flows.json" \
      > "${EXPORT_DIR}/idp-first-login-flows/${idp}-${first_flow}.json"

    # 2) executions をコピー
    if [[ -f "${EXPORT_DIR}/authentication-flows/${first_flow}-executions.json" ]]; then
      cp "${EXPORT_DIR}/authentication-flows/${first_flow}-executions.json" \
        "${EXPORT_DIR}/idp-first-login-flows/${idp}-${first_flow}-executions.json"
    else
      echo "       ⚠️ executions が存在しないためスキップ: ${first_flow}"
    fi
  fi
done

chmod -R 777 "${EXPORT_DIR}"

echo "✅ エクスポート完了: ${EXPORT_DIR}/"
