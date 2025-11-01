# Keycloak Identity Provider 設定ガイド（Google 連携）

このドキュメントは、Keycloak において **Google を Identity Provider (IdP)** として設定する際の  
**全項目の詳細な説明**を日本語でまとめたものです。

---

## 🔷 General Settings（一般設定）

### Redirect URI（リダイレクトURI）
- **概要**：Google 側（Google Cloud Console）で登録が必要なリダイレクト先 URL。
- **役割**：ユーザーが Google 認証を完了すると、この URI に戻ってきます。
- **形式**：https://<your-keycloak-domain>/realms/<realm-name>/broker/<alias>/endpoint
- **注意**：
- Google 側で「正確に一致」している必要があります（スキーム・ホスト・ポート・パスすべて）。
- Alias を変更すると URI も変わります。Google 側登録も更新が必要。

---

### Alias（エイリアス）
- **概要**：この IdP を Keycloak 内で一意に識別する名前。
- **利用箇所**：Redirect URI や `kc_idp_hint` などに使用。
- **推奨値**：`google`
- **注意**：
- Alias の変更は Redirect URI に影響します。
- 短くわかりやすい名前を推奨。

---

### Prompt（プロンプト）
- **概要**：Google の認証画面に渡すクエリパラメータ `prompt` の設定。
- **入力形式**：テキストボックス（ただし固定値が存在）
- **選択肢一覧**：

| 値 | 説明 | 主な利用シーン |
|----|------|----------------|
| `none` | ログイン画面を表示せず自動認証を試行。Google セッションがない場合はエラー。 | サイレントログインを実装する場合。 |
| `consent` | 毎回ユーザーに同意画面を表示。 | 毎回明示的な同意が必要な場合。 |
| `select_account` | アカウント選択画面を必ず表示。 | 複数アカウントから選ばせたい場合。 |

- **既定値**：空（Google のデフォルト挙動）

---

### Hosted Domain（ホストドメイン）
- **概要**：Google Workspace などの特定ドメインのアカウントに限定するための設定。
- **入力形式**：テキストボックス（複数値可）
- **入力値の例と意味**：

| 入力値 | 意味 |
|---------|------|
| `example.com` | `@example.com` のアカウントのみ許可。 |
| `*` | すべての Google アカウントを許可。 |
| `example.com,example.org` | 複数ドメインをカンマ区切りで許可。 |

- **注意**：
- Google の ID トークンに含まれるドメイン情報を Keycloak が検証。
- Workspace 組織ログイン限定などに有用。

---

### Use userIp param（`userIp` パラメータを使用）
- **概要**：Google の User Info API 呼び出し時に `userIp` パラメータを付与。
- **役割**：Google のスロットリング回避や IP ベース制御を補助。
- **既定値**：無効
- **利用頻度**：特殊なネットワーク制約がない限り通常は不要。

---

### Request refresh token（リフレッシュトークン要求）
- **概要**：Google に `access_type=offline` を指定し、リフレッシュトークンを取得。
- **役割**：ブラウザを閉じてもバックエンドから Google API にアクセスできるようにする。
- **既定値**：無効
- **補足**：
- Google は初回のみリフレッシュトークンを返す場合があります。
- 毎回発行を促すには `prompt=consent` と併用可能。

---

## 🔷 Advanced Settings（詳細設定）

### Scopes（スコープ）
- **概要**：Google に要求するアクセス権限（スペース区切りで指定）。
- **入力形式**：テキストボックス（複数指定可能）
- **既定値**：`openid`
- **入力例と意味**：

| スコープ | 機能・取得情報 |
|-----------|----------------|
| `openid` | OIDC ログインに必須。ID トークンを取得。 |
| `email` | ユーザーのメールアドレスを取得。 |
| `profile` | 名前・プロフィール画像・ロケールなど基本情報を取得。 |
| `https://www.googleapis.com/auth/calendar.readonly` | Google カレンダー読み取り専用アクセス。 |
| `https://www.googleapis.com/auth/drive.readonly` | Google ドライブ読み取り専用アクセス。 |

- **一般的推奨値**：openid email profile

- **注意**：
- `openid` は必須。
- スコープを増やすほど同意画面で求められる権限が増える。

---

### Store tokens（トークン保存）
- **概要**：Google から受け取ったアクセストークン／リフレッシュトークンを Keycloak に保存する。
- **役割**：Token Exchange や他サービス連携に必要な場合に利用。
- **既定値**：無効
- **注意**：
- 保存時はセキュリティリスクに留意。
- 有効化するとユーザーごとにトークンが永続保存される。

---

### Accepts prompt=none forward from client
- **概要**：クライアントから `prompt=none` を受けた場合に Google へ転送するか。
- **効果**：未ログイン時もエラー返却せず Google 側でサイレント認証を試行。
- **既定値**：無効
- **用途**：SPA のバックグラウンドログインなど。

---

### Disable user info（User Info API 無効化）
- **概要**：ID トークンのみでユーザー情報を取得し、Google の User Info API 呼び出しを省略。
- **既定値**：無効（＝使用する）
- **利点**：外部呼び出しが減り、高速化。
- **欠点**：User Info にしか含まれない属性は取得できない。

---

### Trust Email（メールを信頼）
- **概要**：Google 提供のメールを検証済みとして扱う。
- **効果**：Keycloak のメール確認フローをスキップ。
- **既定値**：無効
- **推奨**：信頼できる IdP（Google など）の場合は有効。

---

### Account linking only（アカウント連携専用）
- **概要**：Google 経由での新規ログインを禁止し、既存ユーザーとの連携のみに使用。
- **既定値**：無効
- **用途**：SSO ログインは許可せず、連携のみ行いたい場合。

---

### Hide on login page（ログインページ非表示）
- **概要**：ログイン画面に Google ログインボタンを表示しない。
- **既定値**：無効
- **補足**：`kc_idp_hint` により直接呼び出しは可能。

---

### Verify essential claim（必須クレーム検証）
- **概要**：ID トークンに特定のクレームが存在することを要求。
- **既定値**：無効
- **用途**：セキュリティ強化（例：`hd`、`email_verified` などの検証）。

---

### First login flow override（初回ログインフロー上書き）
- **概要**：Google で初回ログイン時に実行されるフローを指定。
- **既定値**：`First Broker Login`
- **用途**：初回のみ追加情報入力やアカウントリンク確認を行いたい場合。

---

### Post login flow（ログイン後フロー）
- **概要**：Google ログイン後に毎回実行される追加フローを指定。
- **既定値**：`None`
- **用途**：例）毎回 OTP 認証を要求するなど。

---

### Sync mode（同期モード）
- **概要**：Google から取得したユーザー情報をいつ Keycloak に反映するか。
- **入力形式**：固定値選択
- **選択肢一覧**：

| 値 | 動作 | 主な用途 |
|-----|------|-----------|
| `legacy` | 旧バージョン互換動作。 | 移行時の暫定設定。 |
| `import` | 初回ログイン時にのみユーザー情報を取り込む。 | Keycloak 管理を優先する場合。 |
| `force` | 毎回ログイン時に Google 情報で上書き。 | 最新状態を常に反映したい場合。 |

- **推奨値**：`import`

---

### Case-sensitive username（大文字小文字の区別）
- **概要**：Google のユーザー名の大小文字をそのまま保持するか。
- **既定値**：無効（Keycloak 内部では小文字化）
- **用途**：外部システムとの正確なユーザー名一致が必要な場合。

---

## 🔶 推奨設定まとめ（実用例）

| 項目 | 推奨値 | 理由 |
|------|---------|------|
| Alias | `google` | シンプルで分かりやすい |
| Redirect URI | Keycloak 自動生成値を Google Console に登録 | 必須設定 |
| Scopes | `openid email profile` | メール・名前取得のため |
| Request refresh token | 有効 | Token Exchange 時に必要 |
| Store tokens | 有効（必要に応じて） | トークン再利用のため |
| Trust Email | 有効 | UX 改善、Google 信頼前提 |
| Sync mode | `import` | 初回のみ同期で十分 |
| Hosted Domain | 空 or `example.com` | 制限の有無に応じて設定 |

---

## 💬 補足：Scopes 入力欄について

> **OIDC 連携では必ず `openid` が必要です。**

### 一般的な入力例：openid email profile

### 特殊な例（Google API 利用時）：openid email profile https://www.googleapis.com/auth/calendar.readonly

- スコープは **スペース区切り** で入力します。
- 余計な改行やカンマは不可です。
