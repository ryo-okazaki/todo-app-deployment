#!/usr/bin/env bash
set -euo pipefail

KEYCLOAK_URL="http://auth-keycloak:8080"
ADMIN_REALM="master"
ADMIN_USER="admin"
ADMIN_PASSWORD="admin"
TARGET_REALM="microservice-app"
EXPORT_DIR="/opt/keycloak/exports/${TARGET_REALM}_export_$(date +%Y%m%d_%H%M%S)"

mkdir -p "${EXPORT_DIR}"

echo "🔐 Logging in..."
kcadm.sh config credentials \
  --server "$KEYCLOAK_URL" \
  --realm "$ADMIN_REALM" \
  --user "$ADMIN_USER" \
  --password "$ADMIN_PASSWORD"

echo "📦 Export realm..."
kcadm.sh get realms/${TARGET_REALM} > "${EXPORT_DIR}/realm.json"

echo "📦 Export top-level flows..."
mkdir -p "${EXPORT_DIR}/authentication-flows"

kcadm.sh get authentication/flows -r ${TARGET_REALM} \
  > "${EXPORT_DIR}/authentication-flows/all-flows.json"

# URL encode
urlencode() {
  jq -rn --arg v "$1" '$v|@uri'
}

echo "📦 Export executions for each top-level flow..."
for flow_alias in $(jq -r '.[].alias' "${EXPORT_DIR}/authentication-flows/all-flows.json"); do
  encoded_alias=$(urlencode "$flow_alias")

  OUT_FILE="${EXPORT_DIR}/authentication-flows/${flow_alias}-executions.json"

  kcadm.sh get "authentication/flows/${encoded_alias}/executions" -r ${TARGET_REALM} \
    > "$OUT_FILE" || true
done

echo "📦 Detecting subflow flowIds..."
SUBFLOW_IDS=$(jq -r '
  inputs | .[]? |
  select(.authenticationFlow == true and .flowId != null) |
  .flowId
' "${EXPORT_DIR}/authentication-flows/"*-executions.json | sort -u)

echo "📦 Exporting subflow details + executions..."
mkdir -p "${EXPORT_DIR}/authentication-flows/subflows"

for fid in $SUBFLOW_IDS; do
  echo "  → Subflow: $fid"

  # 1) subflow info
  kcadm.sh get "authentication/flows" -r ${TARGET_REALM} \
      | jq ".[] | select(.id==\"${fid}\")" \
      > "${EXPORT_DIR}/authentication-flows/subflows/${fid}.json"

  # 2) subflow executions
  alias=$(jq -r '.alias' "${EXPORT_DIR}/authentication-flows/subflows/${fid}.json")
  ENC=$(urlencode "$alias")

  kcadm.sh get "authentication/flows${ENC}/executions" -r ${TARGET_REALM} \
    > "${EXPORT_DIR}/authentication-flows/subflows/${alias}-executions.json" || true

done

chmod -R 777 "${EXPORT_DIR}"

echo "📦 DONE: $EXPORT_DIR"
