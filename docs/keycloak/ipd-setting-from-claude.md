# KeycloakのIdentity Provider (Google) 設定項目詳細ガイド

## 一般設定（General settings）

### Redirect URI（リダイレクトURI）

**概要**
- Identity Providerの設定時に使用するリダイレクトURIです。
- このURIは、Googleの認証が完了した後にユーザーがリダイレクトされる先のKeycloakのエンドポイントを示します。

**詳細説明**
- このURIは自動生成され、Keycloakが提供する読み取り専用の値です。
- Google Cloud Consoleで OAuth 2.0 クライアントIDを設定する際、「承認済みのリダイレクトURI」としてこの値を登録する必要があります。
- 形式: `https://{keycloak-domain}/realms/{realm-name}/broker/{provider-alias}/endpoint`

**使用例**
```
https://auth.example.com/realms/myrealm/broker/google/endpoint
```

---

### Alias（エイリアス）

**概要**
- Identity Providerを一意に識別するための別名です。

**詳細説明**
- このエイリアスは、Keycloak内でIdentity Providerを参照する際に使用されます。
- リダイレクトURIの一部として組み込まれます。
- 一度設定すると変更が困難なため、慎重に決定する必要があります。
- 英数字とハイフン、アンダースコアが使用可能です。

**ベストプラクティス**
- わかりやすく、目的が明確な名前を使用（例: `google`, `google-oauth`, `google-sso`）
- 複数のGoogle Identity Providerを使用する場合は、用途別に区別（例: `google-internal`, `google-external`）

---

### Prompt（プロンプト）

**概要**
- Googleの認証画面でのユーザー体験を制御するパラメータです。

**詳細説明**
- GoogleのOAuth 2.0フローにおける`prompt`クエリパラメータを設定します。
- ユーザーに表示される認証・同意画面の動作を制御します。

**設定可能な値と特徴**

#### `none`
- **動作**: ユーザーに認証画面や同意画面を表示しません。
- **用途**: ユーザーが既にログインしている場合にのみ成功します。
- **特徴**:
    - ユーザーがログインしていない場合、エラーが返されます。
    - シームレスなSSO体験を提供したい場合に使用します。
    - バックグラウンドでの認証チェックに適しています。

#### `consent`
- **動作**: ユーザーが既にログインしていても、必ず同意画面を表示します。
- **用途**: ユーザーに毎回権限の確認を求めたい場合に使用します。
- **特徴**:
    - データアクセスの透明性を高めます。
    - コンプライアンス要件がある場合に有用です。
    - ユーザーの明示的な同意を毎回取得できます。

#### `select_account`
- **動作**: ユーザーにアカウント選択画面を表示します。
- **用途**: 複数のGoogleアカウントを持つユーザーが使用するアカウントを選択できるようにします。
- **特徴**:
    - 最も一般的な設定です。
    - ユーザーが異なるアカウントでログインすることを許可します。
    - 共有デバイスでの使用に適しています。

#### 未設定（空白）
- **動作**: ユーザーが事前に認可していない場合のみ同意画面を表示します。
- **特徴**:
    - デフォルトのGoogle OAuth動作です。
    - 2回目以降のログインでは同意画面をスキップします。

**推奨設定**
- 一般的な用途: `select_account`
- SSO環境: 未設定または`none`
- コンプライアンス重視: `consent`

---

### Hosted Domain（ホステッドドメイン）

**概要**
- Google Workspace（旧G Suite）の特定ドメインに所属するアカウントのみを許可する設定です。

**詳細説明**
- GoogleのOAuth 2.0フローにおける`hd`（hosted domain）パラメータを設定します。
- Googleは指定されたドメインに所属するアカウントのみをアカウント選択画面に表示します。
- Keycloakは返されたIDトークンにこのドメインのクレームが含まれていることを検証します。

**設定可能な値と特徴**

#### 特定のドメイン
```
example.com
```
- **動作**: 指定したドメインのアカウントのみが使用可能です。
- **用途**: 企業や組織の内部ユーザーのみにアクセスを制限します。
- **特徴**:
    - Google Workspaceのドメインを使用している組織に最適です。
    - セキュリティを強化し、外部アカウントの使用を防ぎます。

#### 複数のドメイン（カンマ区切り）
```
example.com,partner.com,subsidiary.net
```
- **動作**: 複数の組織のドメインからのアクセスを許可します。
- **用途**: パートナー企業や子会社を含むマルチテナント環境に使用します。
- **特徴**:
    - 複数の信頼できる組織を統合できます。
    - それぞれのドメインが個別に検証されます。

#### アスタリスク（`*`）
```
*
```
- **動作**: 任意のGoogle Workspaceドメインのアカウントを許可します。
- **用途**: 個人のGmailアカウントを除外し、組織管理されたアカウントのみを許可します。
- **特徴**:
    - 個人アカウント（@gmail.com）は除外されます。
    - 企業アカウントであることを保証しますが、特定の企業に限定しません。

#### 未設定（空白）
- **動作**: すべてのGoogleアカウント（個人アカウント含む）が使用可能です。
- **用途**: 制限なくすべてのユーザーにアクセスを許可します。

**セキュリティ上の注意**
- ドメインを指定しても、Googleアカウントを持つ誰でもログイン試行は可能です。
- しかし、IDトークンの検証段階でドメインが一致しない場合、認証は失敗します。
- この設定は、ドメイン所有権の検証とは異なります。

**推奨設定**
- 企業内部アプリケーション: `company.com`（自社ドメイン）
- B2Bアプリケーション: 複数ドメインのカンマ区切りリスト
- 一般公開アプリケーション: 未設定

---

### Use userIp param（userIpパラメータの使用）

**概要**
- GoogleのUser Info APIを呼び出す際に、ユーザーのIPアドレスを含めるかどうかを設定します。

**詳細説明**
- 有効にすると、Google User Info サービスへのリクエストに`userIp`クエリパラメータが追加されます。
- GoogleはこのIPアドレス情報を使用して、リクエストのレート制限をより細かく制御します。

**動作の詳細**

#### 有効の場合
- **動作**:
    - User Info APIリクエストにエンドユーザーのIPアドレスが含まれます。
    - GoogleはIPアドレスごとにレート制限を適用します。
- **メリット**:
    - Keycloakサーバー全体のレート制限ではなく、個別のユーザーIPごとに制限が適用されます。
    - 多数のユーザーが同時にログインする環境で、Keycloakサーバーが制限に達しにくくなります。
    - Google側でのスロットリング（流量制限）を回避しやすくなります。

#### 無効の場合（デフォルト）
- **動作**:
    - User Info APIリクエストにはKeycloakサーバーのIPアドレスのみが使用されます。
    - GoogleはKeycloakサーバーのIPアドレスに対してレート制限を適用します。
- **デメリット**:
    - 多数のユーザーが同時にログインする場合、Keycloakサーバー全体が制限に達する可能性があります。

**使用シナリオ**
- **有効にすべき場合**:
    - 大規模なユーザーベースを持つアプリケーション
    - ピーク時に多数の同時ログインが発生する環境
    - GoogleからAPI制限エラーを受け取っている場合
- **無効のままでよい場合**:
    - 小規模なユーザーベース
    - ログイン頻度が低い環境

**技術的な注意点**
- ユーザーのIPアドレスはHTTPヘッダー（X-Forwarded-For等）から取得されます。
- プロキシやロードバランサーを使用している場合、正しいIPアドレスが取得されるよう設定が必要です。

---

### Request refresh token（リフレッシュトークンの要求）

**概要**
- Google認証時にリフレッシュトークンを取得するかどうかを設定します。

**詳細説明**
- 有効にすると、Google認可エンドポイントへのリダイレクト時に`access_type=offline`パラメータが追加されます。
- これにより、初回認証時にリフレッシュトークンが発行されます。

**リフレッシュトークンとは**
- アクセストークンの有効期限が切れた後も、ユーザーの再認証なしに新しいアクセストークンを取得できる特殊なトークンです。
- 長期間有効で、アクセストークンの更新に使用されます。

**動作の詳細**

#### 有効の場合
- **動作**:
    - 初回認証時にリフレッシュトークンが発行されます。
    - Keycloakはこのリフレッシュトークンを保存します（「Store tokens」が有効な場合）。
    - ユーザーがオフラインの時でも、保存されたリフレッシュトークンを使用してGoogle APIにアクセスできます。
- **用途**:
    - バックグラウンド処理でGoogle APIを呼び出す必要がある場合
    - Token Exchangeを使用してGoogle APIトークンを取得する場合
    - ユーザーがログアウトした後もGoogle サービスにアクセスする必要がある場合

#### 無効の場合（デフォルト）
- **動作**:
    - リフレッシュトークンは発行されません。
    - アクセストークンの有効期限が切れた後は、ユーザーの再認証が必要です。
- **用途**:
    - 単純なSSO認証のみが目的の場合
    - Google APIを直接呼び出す必要がない場合

**使用シナリオ**

##### 有効にすべき場合
1. **Google API統合**:
    - Gmail APIでメールを読み書きする
    - Google Drive APIでファイルにアクセスする
    - Google Calendar APIで予定を管理する

2. **バックグラウンド処理**:
    - 定期的なデータ同期
    - スケジュールされたバックアップ
    - 非同期のデータ処理

3. **Token Exchange使用時**:
    - Keycloakのトークンを使用してGoogleトークンを取得する
    - マイクロサービス間でGoogle APIアクセスを委譲する

##### 無効のままでよい場合
- 認証のみが目的で、Google APIを使用しない
- ユーザーがアクティブな間のみGoogle サービスにアクセスする
- セキュリティポリシーで長期トークンの保存が禁止されている

**セキュリティ上の考慮事項**
- リフレッシュトークンは強力な権限を持つため、安全に保管する必要があります。
- 「Store tokens」を有効にする場合、Keycloakのデータベースが適切に保護されていることを確認してください。
- リフレッシュトークンが漏洩すると、攻撃者がユーザーのGoogle アカウントに長期間アクセスできる可能性があります。

**Googleの制限事項**
- リフレッシュトークンは初回認証時にのみ発行されます。
- ユーザーが既にアクセスを承認している場合、再度リフレッシュトークンを取得するには、Googleアカウント設定でアプリの接続を解除してもらう必要があります。
- または、`prompt=consent`を使用して強制的に同意画面を表示させることで、リフレッシュトークンを再取得できます。

---

## 詳細設定（Advanced settings）

### Scopes（スコープ）

**概要**
- OAuth 2.0 / OpenID Connectの認可時に要求するスコープ（権限の範囲）を指定します。

**詳細説明**
- スペース区切りで複数のスコープを指定できます。
- スコープは、アプリケーションがアクセスできるユーザー情報やGoogle サービスの範囲を定義します。
- デフォルト値は`openid`です。

**標準OpenID Connectスコープ**

#### `openid`（必須）
- **説明**: OpenID Connect認証を有効にする基本スコープです。
- **取得できる情報**: ユーザーの一意識別子（sub）
- **用途**: すべてのOpenID Connect認証で必須です。
- **特徴**: これがないと、OAuth 2.0の単純な認可フローになります。

#### `profile`
- **説明**: ユーザーのプロフィール情報へのアクセスを要求します。
- **取得できる情報**:
    - `name`: フルネーム
    - `family_name`: 姓
    - `given_name`: 名
    - `picture`: プロフィール画像のURL
    - `locale`: ロケール（言語設定）
- **用途**: ユーザーの基本情報を表示する必要がある場合。

#### `email`
- **説明**: ユーザーのメールアドレスへのアクセスを要求します。
- **取得できる情報**:
    - `email`: メールアドレス
    - `email_verified`: メールアドレスが検証済みかどうか
- **用途**: ユーザー識別やコミュニケーションに必須です。

#### `address`
- **説明**: ユーザーの住所情報へのアクセスを要求します。
- **取得できる情報**:
    - `address`: 住所オブジェクト（formatted, street_address, locality, region, postal_code, country）
- **用途**: 配送先情報が必要なEコマースアプリケーション等。

#### `phone`
- **説明**: ユーザーの電話番号へのアクセスを要求します。
- **取得できる情報**:
    - `phone_number`: 電話番号
    - `phone_number_verified`: 電話番号が検証済みかどうか
- **用途**: 2要素認証や連絡先情報が必要な場合。

**Google固有のスコープ**

#### Gmail API スコープ

##### `https://www.googleapis.com/auth/gmail.readonly`
- **説明**: Gmailのメールとメタデータへの読み取り専用アクセス。
- **用途**: メールの閲覧、検索、分析機能。

##### `https://www.googleapis.com/auth/gmail.send`
- **説明**: ユーザーの代わりにメールを送信する権限。
- **用途**: メール送信機能の実装。

##### `https://www.googleapis.com/auth/gmail.compose`
- **説明**: メールの作成と送信（既存のメールの閲覧は不可）。
- **用途**: 制限されたメール送信機能。

##### `https://www.googleapis.com/auth/gmail.modify`
- **説明**: メールの読み取り、作成、送信、削除（完全アクセス）。
- **用途**: 包括的なメールクライアント機能。

#### Google Drive API スコープ

##### `https://www.googleapis.com/auth/drive.readonly`
- **説明**: Google Driveのファイルとメタデータへの読み取り専用アクセス。
- **用途**: ファイルの閲覧、ダウンロード機能。

##### `https://www.googleapis.com/auth/drive.file`
- **説明**: アプリが作成したファイルのみへのアクセス。
- **用途**: アプリ専用のストレージ領域として使用。

##### `https://www.googleapis.com/auth/drive`
- **説明**: Google Drive の完全アクセス（全ファイルの読み書き削除）。
- **用途**: 包括的なファイル管理機能。

##### `https://www.googleapis.com/auth/drive.appdata`
- **説明**: アプリケーション専用の隠しフォルダへのアクセス。
- **用途**: 設定ファイルやアプリデータの保存。

#### Google Calendar API スコープ

##### `https://www.googleapis.com/auth/calendar.readonly`
- **説明**: カレンダーイベントへの読み取り専用アクセス。
- **用途**: スケジュール表示機能。

##### `https://www.googleapis.com/auth/calendar.events`
- **説明**: カレンダーイベントの作成、読み取り、更新、削除。
- **用途**: カレンダー管理機能。

##### `https://www.googleapis.com/auth/calendar`
- **説明**: カレンダーの完全アクセス（カレンダー自体の管理も含む）。
- **用途**: 包括的なカレンダーアプリケーション。

#### Google Contacts API スコープ

##### `https://www.googleapis.com/auth/contacts.readonly`
- **説明**: 連絡先への読み取り専用アクセス。
- **用途**: 連絡先の表示、検索機能。

##### `https://www.googleapis.com/auth/contacts`
- **説明**: 連絡先の完全アクセス（作成、読み取り、更新、削除）。
- **用途**: 連絡先管理機能。

#### YouTube API スコープ

##### `https://www.googleapis.com/auth/youtube.readonly`
- **説明**: YouTubeデータへの読み取り専用アクセス。
- **用途**: 動画リストの表示、チャンネル情報の取得。

##### `https://www.googleapis.com/auth/youtube.upload`
- **説明**: 動画のアップロード権限。
- **用途**: 動画投稿機能。

##### `https://www.googleapis.com/auth/youtube`
- **説明**: YouTube アカウントの完全管理権限。
- **用途**: 包括的なYouTube管理機能。

**設定例**

#### 基本的なSSO認証のみ
```
openid email profile
```

#### Gmailへのアクセスを含む
```
openid email profile https://www.googleapis.com/auth/gmail.readonly
```

#### 複数のGoogle サービスへのアクセス
```
openid email profile https://www.googleapis.com/auth/gmail.send https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/calendar.events
```

#### 最小限の権限（識別子のみ）
```
openid
```

**ベストプラクティス**
1. **最小権限の原則**: 必要最小限のスコープのみを要求する。
2. **透明性**: ユーザーに何のデータにアクセスするかを明確にする。
3. **段階的な権限要求**: 初回は基本スコープのみ、必要に応じて追加スコープを要求する。
4. **読み取り専用**: 可能な限り読み取り専用スコープを使用する。

**セキュリティ上の注意**
- 過剰なスコープを要求すると、ユーザーの信頼を損ねる可能性があります。
- スコープが多いほど、同意画面でユーザーが警戒する可能性が高くなります。
- 不必要なスコープは攻撃者に悪用される可能性があります。

---

### Store tokens（トークンの保存）

**概要**
- 認証後に取得したトークン（アクセストークン、リフレッシュトークン、IDトークン）をKeycloakのデータベースに保存するかどうかを設定します。

**詳細説明**
- 有効にすると、Identity Providerから取得したトークンがKeycloakのデータベースに暗号化されて保存されます。
- これらのトークンは後で取得し、Google APIへのアクセスに使用できます。

**動作の詳細**

#### 有効の場合
- **保存されるトークン**:
    - **アクセストークン**: Google APIへの短期間のアクセスを許可するトークン
    - **リフレッシュトークン**: 新しいアクセストークンを取得するための長期トークン（「Request refresh token」が有効な場合）
    - **IDトークン**: ユーザーの認証情報を含むトークン

- **メリット**:
    - Token Exchangeを使用してトークンを取得できます。
    - バックエンドサービスからGoogle APIを呼び出せます。
    - ユーザーの再認証なしにGoogle サービスにアクセスできます。

- **アクセス方法**:
  ```
  GET /realms/{realm}/broker/{provider-alias}/token
  ```
  このエンドポイントから保存されたトークンを取得できます。

#### 無効の場合（デフォルト）
- **動作**:
    - トークンは保存されません。
    - 認証セッション中のみトークンが使用可能です。
    - セッション終了後はトークンにアクセスできません。

- **メリット**:
    - セキュリティリスクが低減します。
    - データベースのストレージ使用量が少なくなります。
    - コンプライアンス要件を満たしやすくなります（トークンの長期保存を避けられる）。

**使用シナリオ**

##### 有効にすべき場合
1. **Google API統合**:
    - サーバーサイドでGoogle APIを呼び出す必要がある
    - ユーザーのGoogle Driveにファイルを保存する
    - Gmailを使用してメールを送信する

2. **Token Exchange使用時**:
    - マイクロサービスアーキテクチャでトークンを交換する
    - 異なるサービス間でGoogle APIアクセスを委譲する

3. **バックグラウンド処理**:
    - 定期的なデータ同期
    - スケジュールされたタスク
    - ユーザーがオフラインの時の処理

##### 無効のままでよい場合
- **SSO認証のみ**:
    - Googleを認証プロバイダーとしてのみ使用
    - Google APIを直接呼び出す必要がない
    - ユーザー識別のみが目的

- **セキュリティ要件が厳しい環境**:
    - トークンの長期保存が禁止されている
    - 最小限のデータ保持ポリシー
    - コンプライアンス規制（GDPR等）

**セキュリティ上の考慮事項**

1. **データベースのセキュリティ**:
    - トークンは暗号化されて保存されますが、データベースへの不正アクセスを防ぐ必要があります。
    - データベースのバックアップも適切に保護する必要があります。

2. **アクセス制御**:
    - Token Exchange エンドポイントへのアクセスを適切に制限する必要があります。
    - 認可されたクライアントのみがトークンを取得できるようにします。

3. **トークンの有効期限**:
    - アクセストークンは通常1時間で期限切れになります。
    - リフレッシュトークンは長期間有効ですが、ユーザーがアクセスを取り消すと無効になります。

4. **監査ログ**:
    - トークンへのアクセスをログに記録することを推奨します。
    - 異常なアクセスパターンを検出できるようにします。

**技術的な詳細**

- **保存場所**: `FED_IDENTITY` テーブルの `TOKEN` カラム
- **暗号化**: Keycloakの暗号化キーを使用して暗号化
- **サイズ**: トークンは数KB程度のサイズです
- **パフォーマンス**: 大量のユーザーがいる場合、データベースのサイズとパフォーマンスに影響する可能性があります

**Token Exchangeとの連携**

Token Exchangeを使用する場合の典型的なフロー:
1. ユーザーがKeycloakで認証
2. KeycloakがGoogleからトークンを取得し保存（Store tokens有効）
3. アプリケーションがKeycloakのトークンを取得
4. アプリケーションがToken Exchange エンドポイントを呼び出し
5. KeycloakがGoogleトークンを返却
6. アプリケーションがGoogleトークンを使用してGoogle APIを呼び出し

---

### Accepts prompt=none forward from client（クライアントからのprompt=noneの転送を受け入れる）

**概要**
- クライアントアプリケーションから`prompt=none`パラメータ付きでリクエストが来た場合の動作を制御します。

**詳細説明**
- この設定は、Identity Provider Authenticatorと併用する場合、または`kc_idp_hint`パラメータがこのIdentity Providerを指している場合に機能します。
- OpenID Connectの仕様における「Silent Authentication」フローに関連します。

**`prompt=none`とは**
- OpenID Connectの標準パラメータで、「ユーザーに対話的な認証画面を表示しない」ことを指示します。
- ユーザーが既にログインしている場合のみ成功し、そうでない場合はエラーを返します。

**動作の詳細**

#### 有効の場合
- **シナリオ1: ユーザーが既にKeycloakで認証済み**
    1. クライアントが`prompt=none`でリクエスト
    2. Keycloakはユーザーがログイン済みであることを確認
    3. 即座にトークンを返却（ユーザーの操作不要）

- **シナリオ2: ユーザーがKeycloakで未認証**
    1. クライアントが`prompt=none`でリクエスト
    2. Keycloakはユーザーが未認証であることを確認
    3. **エラーを直接クライアントに返さず**、`prompt=none`をGoogle Identity Providerに転送
    4. Googleがユーザーのログイン状態を確認
    5. Googleが結果を返却（成功またはエラー）

- **メリット**:
    - シームレスなSSO体験を提供
    - ユーザーが複数のシステムで既にログインしている場合、追加の認証画面なしでアクセス可能
    - Googleのセッションを活用できる

#### 無効の場合（デフォルト）
- **動作**:
    1. クライアントが`prompt=none`でリクエスト
    2. Keycloakはユーザーが未認証であることを確認
    3. **即座にエラーを返却**（`login_required`または`interaction_required`）
    4. Googleには問い合わせない

- **メリット**:
    - より予測可能な動作
    - Googleへの不要なリダイレクトを避けられる
    - レスポンスが高速

**使用シナリオ**

##### 有効にすべき場合

1. **シングルサインオン (SSO) 環境**:
   ```
   ユーザーがGoogle Workspace環境で既にログイン済み
   → Keycloakアプリにアクセス
   → 追加の認証画面なしで自動ログイン
   ```

2. **マイクロフロントエンド / SPA (Single Page Application)**:
    - アプリケーション起動時に自動的にログイン状態を確認
    - ユーザーが気づかないうちにセッションを確立
    - バックグラウンドでの認証チェック

3. **モバイルアプリケーション**:
    - アプリ起動時の自動ログイン
    - ユーザーエクスペリエンスの向上

4. **Identity Provider Authenticatorを使用する場合**:
    - 特定の条件下で自動的にGoogle認証を試行
    - ユーザーの手動操作を最小限に抑える

##### 無効のままでよい場合

1. **明示的なログインフロー**:
    - ユーザーが意図的にログインボタンをクリックする
    - 認証のタイミングを完全に制御したい

2. **セキュリティ要件が厳しい環境**:
    - 自動認証を避けたい
    - すべての認証を明示的にしたい

3. **シンプルな実装**:
    - `prompt=none`を使用しない
    - 標準的な認証フローのみ

**技術的な詳細**

##### `kc_idp_hint`パラメータとの連携
```
https://keycloak.example.com/realms/myrealm/protocol/openid-connect/auth
  ?client_id=myapp
  &redirect_uri=https://myapp.example.com/callback
  &response_type=code
  &scope=openid
  &kc_idp_hint=google
  &prompt=none
```
- `kc_idp_hint=google`: 自動的にGoogle Identity Providerを使用
- `prompt=none`: 対話的な認証画面を表示しない
- この設定が有効だと、Googleに対しても`prompt=none`が転送される

##### エラーレスポンス
無効時または認証失敗時のエラー:
- `login_required`: ユーザーがログインしていない
- `interaction_required`: ユーザーの操作が必要
- `account_selection_required`: アカウント選択が必要
- `consent_required`: 同意が必要

**実装例**

##### JavaScript (SPA)でのsilent authentication:
```javascript
// ページロード時に自動的にログイン状態を確認
async function checkLoginStatus() {
  try {
    const response = await fetch('https://keycloak.example.com/auth', {
      method: 'GET',
      credentials: 'include',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    });
    
    // prompt=none で認証チェック
    const url = new URL(response.url);
    url.searchParams.set('prompt', 'none');
    url.searchParams.set('kc_idp_hint', 'google');
    
    // 成功すればトークンを取得、失敗すればログイン画面へ
  } catch (error) {
    // エラー処理: ログイン画面へリダイレクト
  }
}
```

**セキュリティ上の考慮事項**

1. **CSRF保護**:
    - `prompt=none`を使用する場合でも、stateパラメータを使用してCSRF攻撃を防ぐ

2. **セッションハイジャック**:
    - 自動認証が成功した場合でも、重要な操作の前に再認証を要求する

3. **タイミング攻撃**:
    - エラーレスポンスのタイミングから情報が漏洩しないよう注意

**デバッグとトラブルシューティング**

- **問題**: `prompt=none`が機能しない
    - **確認事項**:
        - この設定が有効になっているか
        - `kc_idp_hint`が正しく設定されているか
        - Googleセッションが有効か
        - クッキーが適切に設定されているか（SameSite属性等）

- **問題**: 予期しないエラーが返される
    - **確認事項**:
        - Googleのホステッドドメイン設定
        - 必要なスコープが設定されているか
        - Googleでのユーザーの同意状態

---

### Disable user info（User Infoの無効化）

**概要**
- OpenID ConnectのUser Info エンドポイントを使用して追加のユーザー情報を取得するかどうかを設定します。

**詳細説明**
- OpenID Connectでは、IDトークンに含まれる基本情報に加えて、User Info エンドポイントから追加のユーザー情報を取得できます。
- この設定を有効にすると、User Info エンドポイントへのリクエストをスキップします。

**User Info エンドポイントとは**
- OpenID Connectの標準エンドポイントで、認証されたユーザーに関する詳細情報を返します。
- Googleの場合: `https://openidconnect.googleapis.com/v1/userinfo`
- アクセストークンを使用してリクエストします。

**動作の詳細**

#### 無効（User Infoを使用）- デフォルト
- **動作フロー**:
    1. ユーザーがGoogle認証を完了
    2. KeycloakがIDトークンとアクセストークンを受け取る
    3. **KeycloakがUser Info エンドポイントを呼び出す**
    4. 追加のユーザー情報を取得（メールアドレス、プロフィール画像等）
    5. IDトークンの情報とUser Infoの情報をマージ
    6. Keycloakユーザーを作成/更新

- **取得できる追加情報**:
    - より詳細なプロフィール情報
    - IDトークンのサイズ制限を超える情報
    - リアルタイムの最新情報

- **メリット**:
    - 最も包括的なユーザー情報を取得
    - IDトークンに含まれていない情報も取得可能
    - 標準的なOpenID Connectフロー

#### 有効（User Infoを無効化）
- **動作フロー**:
    1. ユーザーがGoogle認証を完了
    2. KeycloakがIDトークンとアクセストークンを受け取る
    3. **User Info エンドポイントを呼び出さない**
    4. IDトークンの情報のみを使用
    5. Keycloakユーザーを作成/更新

- **メリット**:
    - パフォーマンスの向上（1回のHTTPリクエストを削減）
    - Google APIの呼び出し回数を削減（レート制限対策）
    - シンプルなフロー
    - ネットワークトラフィックの削減

- **デメリット**:
    - IDトークンに含まれる情報のみに制限される
    - 一部の詳細情報が取得できない可能性

**IDトークン vs User Info**

| 項目 | IDトークン | User Info エンドポイント |
|------|-----------|------------------------|
| **取得タイミング** | 認証時に即座に | 認証後に別途リクエスト |
| **サイズ** | 制限あり（通常2KB程度） | 制限なし |
| **情報の鮮度** | 認証時点 | リクエスト時点（最新） |
| **標準クレーム** | 基本情報のみ | 詳細情報を含む |
| **パフォーマンス** | 高速 | 追加のHTTPリクエストが必要 |
| **署名/暗号化** | 署名あり（JWS） | HTTPSのみで保護 |

**Googleで取得できる情報の比較**

##### IDトークンに通常含まれる情報:
```json
{
  "iss": "https://accounts.google.com",
  "sub": "110169484474386276334",
  "azp": "client-id.apps.googleusercontent.com",
  "aud": "client-id.apps.googleusercontent.com",
  "iat": 1234567890,
  "exp": 1234571490,
  "email": "user@example.com",
  "email_verified": true,
  "name": "John Doe",
  "picture": "https://lh3.googleusercontent.com/...",
  "given_name": "John",
  "family_name": "Doe",
  "locale": "en"
}
```

##### User Info エンドポイントから取得できる追加情報:
```json
{
  "sub": "110169484474386276334",
  "email": "user@example.com",
  "email_verified": true,
  "name": "John Doe",
  "picture": "https://lh3.googleusercontent.com/...",
  "given_name": "John",
  "family_name": "Doe",
  "locale": "en",
  "hd": "example.com"  // ホステッドドメイン（追加情報の例）
}
```

**使用シナリオ**

##### 無効（User Infoを使用）を推奨する場合

1. **包括的なユーザー情報が必要**:
    - すべての利用可能なユーザー属性を取得したい
    - マッパーで多様な情報を活用したい

2. **標準的な実装**:
    - OpenID Connectの標準フローに従いたい
    - 将来的な拡張性を確保したい

3. **最新情報の取得**:
    - ユーザー情報の鮮度が重要
    - リアルタイムのプロフィール更新を反映したい

##### 有効（User Infoを無効化）を推奨する場合

1. **パフォーマンス重視**:
    - ログイン速度を最適化したい
    - 大量のユーザーが同時にログインする環境
    - ネットワークレイテンシが高い環境

2. **APIレート制限の回避**:
    - Googleのレート制限に達している
    - API呼び出し回数を最小限にしたい
    - コスト削減（API呼び出しに課金がある場合）

3. **シンプルなユーザー情報のみで十分**:
    - 基本的な識別情報（メール、名前）のみが必要
    - IDトークンに含まれる情報で要件を満たせる

4. **セキュリティポリシー**:
    - 外部APIへの呼び出しを最小限にしたい
    - すべての情報をIDトークン（署名付き）から取得したい

**技術的な考慮事項**

1. **マッパーへの影響**:
    - User Info を無効にすると、一部のマッパーが期待通りに動作しない可能性があります
    - カスタムマッパーがUser Info に依存している場合は注意が必要です

2. **スコープとの関係**:
    - 要求したスコープに対応する情報がIDトークンに含まれない場合があります
    - その場合、User Info を有効にしておく必要があります

3. **Googleの仕様**:
    - Googleは重要な情報の多くをIDトークンに含めています
    - 基本的なユースケースではUser Info なしでも十分なことが多いです

**デバッグとトラブルシューティング**

##### 問題: 期待したユーザー情報が取得できない
- **確認事項**:
    - User Info が無効になっていないか確認
    - 必要な情報がIDトークンに含まれているか確認
    - スコープが適切に設定されているか確認

##### 問題: ログインが遅い
- **解決策**:
    - User Info を無効にしてパフォーマンスを改善
    - 必要な情報がIDトークンで取得できることを確認

**ベストプラクティス**

1. **初期設定**: User Info を有効（デフォルト）のままにして、すべての情報を取得
2. **検証**: IDトークンだけで必要な情報が揃っているか確認
3. **最適化**: 問題なければUser Info を無効にしてパフォーマンスを向上
4. **監視**: ログを確認し、必要な情報が確実に取得できていることを確認

---

### Trust Email（メールの信頼）

**概要**
- Identity Providerから提供されたメールアドレスを検証なしで信頼するかどうかを設定します。

**詳細説明**
- Keycloakは通常、新規ユーザーにメール検証を要求できますが、この設定を有効にすると、Google認証で取得したメールアドレスは自動的に検証済みとして扱われます。
- レルムの「Verify email」設定との相互作用があります。

**Keycloakのメール検証機能**

Keycloakには2つのメール検証設定があります:

1. **レルムレベル**: `Realm Settings` → `Login` → `Verify email`
    - すべてのユーザーにメール検証を要求

2. **Identity Providerレベル**: この「Trust Email」設定
    - 特定のIdentity Providerからのメールを信頼

**動作の詳細**

#### 有効の場合
- **動作**:
    1. ユーザーがGoogleで認証
    2. KeycloakがGoogleからメールアドレスを取得
    3. **メールアドレスを自動的に検証済みとしてマーク**
    4. ユーザーはメール検証手順をスキップ
    5. 即座にアプリケーションにアクセス可能

- **条件**:
    - GoogleのIDトークンで`email_verified: true`である必要があります
    - Googleは通常、検証済みメールのみを提供します

- **メリット**:
    - ユーザーエクスペリエンスの向上（追加の検証ステップ不要）
    - シームレスなオンボーディング
    - ユーザーの離脱率低下
    - Google等の信頼できるプロバイダーの検証を活用

#### 無効の場合（デフォルト）
- **動作**:
    1. ユーザーがGoogleで認証
    2. KeycloakがGoogleからメールアドレスを取得
    3. **レルムの「Verify email」設定に従う**
    4. 「Verify email」が有効な場合:
        - Keycloakがメール検証リンクを送信
        - ユーザーがメール内のリンクをクリック
        - 検証完了後にアクセス可能

- **メリット**:
    - より厳格なセキュリティ
    - すべてのユーザーに一貫した検証プロセス
    - メールアドレスの所有権を二重に確認

**設定の組み合わせと動作**

| レルム「Verify email」 | Trust Email | 結果 |
|---------------------|-------------|------|
| 無効 | 無効 | メール検証なし |
| 無効 | 有効 | メール検証なし |
| 有効 | 無効 | Keycloakがメール検証を要求 |
| 有効 | 有効 | **Google認証でメール検証をスキップ**（推奨） |

**使用シナリオ**

##### 有効にすべき場合

1. **信頼できるIdentity Provider**:
    - Google、Microsoft、Facebookなどの大手プロバイダー
    - これらはメールアドレスを既に検証しています
    - 二重検証は不要でユーザー体験を損ねる

2. **企業内SSO**:
    - Google Workspaceを使用している組織
    - すべてのメールアドレスが企業ドメイン
    - メールアドレスの信頼性が保証されている

3. **B2Cアプリケーション**:
    - スムーズなユーザー登録フローが重要
    - ユーザーの離脱を最小限にしたい
    - ソーシャルログインがメインの認証方法

4. **ホステッドドメイン制限がある場合**:
    - 特定の企業ドメインのみを許可
    - ドメインレベルで信頼性が担保されている

##### 無効のままにすべき場合

1. **厳格なセキュリティ要件**:
    - 金融機関、医療機関等
    - すべてのメールアドレスを独自に検証したい
    - コンプライアンス要件

2. **未知のIdentity Provider**:
    - 信頼性が不明なプロバイダー
    - メール検証の品質が保証されていない

3. **混在した認証方法**:
    - ローカルアカウント作成も許可している
    - すべてのユーザーに一貫したプロセスを適用したい

4. **監査要件**:
    - すべてのメールアドレスの検証記録が必要
    - 内部プロセスでの検証が求められる

**Googleのメール検証**

Googleは以下の理由で信頼できます:

1. **厳格な検証プロセス**:
    - アカウント作成時に必ずメール検証
    - SMSや二要素認証も要求される場合がある

2. **email_verifiedクレーム**:
    - IDトークンに`email_verified: true`が含まれる
    - Googleが検証済みであることを保証

3. **Google Workspace**:
    - 企業ドメインは組織によって管理されている
    - さらに高い信頼性

**セキュリティ上の考慮事項**

1. **メールアドレスの変更**:
    - ユーザーがGoogle側でメールアドレスを変更した場合の動作を考慮
    - Sync modeの設定も確認

2. **プロバイダーの信頼性**:
    - すべてのIdentity Providerが同じレベルの検証を行っているわけではない
    - 各プロバイダーの検証ポリシーを確認

3. **アカウントリンク**:
    - 既存のアカウントと同じメールアドレスの場合の動作
    - 「Account linking only」設定との関係

**実装のベストプラクティス**

##### 推奨設定パターン1: Google Workspace環境
```
Trust Email: 有効
Hosted Domain: company.com
Verify Email (realm): 有効
```
- 企業ドメインのみ許可
- 企業管理されたメールなので信頼
- 他の認証方法は検証が必要

##### 推奨設定パターン2: 一般公開アプリ
```
Trust Email: 有効
Hosted Domain: 未設定
Verify Email (realm): 有効
```
- すべてのGoogleアカウントを許可
- Googleの検証を信頼
- ローカルアカウントは検証が必要

##### 推奨設定パターン3: 最大セキュリティ
```
Trust Email: 無効
Hosted Domain: company.com
Verify Email (realm): 有効
```
- 企業ドメインのみ許可
- すべてのメールアドレスを独自に検証
- 二重の検証プロセス

**トラブルシューティング**

##### 問題: ユーザーがメール検証を要求される
- **原因**: Trust Emailが無効
- **解決策**: 設定を有効にするか、ユーザーにメール検証を完了してもらう

##### 問題: メール検証がスキップされすぎる
- **原因**: Trust Emailが有効で、セキュリティ要件を満たしていない
- **解決策**: 設定を無効にするか、First Login Flowで追加の検証を実装

##### 問題: Google Workspace以外のアカウントが検証をスキップする
- **原因**: Hosted Domainが設定されていない
- **解決策**: Hosted Domainを設定するか、カスタムマッパーで制御

**ユーザーエクスペリエンスへの影響**

##### Trust Email有効時のフロー:
```
1. 「Googleでログイン」をクリック
2. Google認証（既にログイン済みならスキップ）
3. 即座にアプリケーションにアクセス
   ✓ スムーズ、高速
```

##### Trust Email無効時のフロー:
```
1. 「Googleでログイン」をクリック
2. Google認証（既にログイン済みならスキップ）
3. Keycloakからメール検証リンクが送信される
4. メールを開いてリンクをクリック
5. アプリケーションにアクセス
   ✗ ステップが多い、ユーザーが離脱する可能性
```

---

### Account linking only（アカウントリンクのみ）

**概要**
- このIdentity Providerを新規ログインには使用せず、既存アカウントへのリンク（紐付け）のみに制限する設定です。

**詳細説明**
- 有効にすると、ユーザーはこのプロバイダーを使用して直接ログインできなくなります。
- 既存のKeycloakアカウントを持つユーザーのみが、アカウント管理画面からGoogle アカウントをリンクできます。

**動作の詳細**

#### 有効の場合
- **制限される動作**:
    1. ログインページに「Googleでログイン」ボタンが表示されない（「Hide on login page」も有効な場合）
    2. ユーザーが直接URLでアクセスしても、新規ログインは拒否される
    3. 新規ユーザーはこのプロバイダーでアカウントを作成できない

- **許可される動作**:
    1. 既存ユーザーがアカウント管理画面（Account Console）にアクセス
    2. 「Linked accounts」セクションでGoogleアカウントをリンク
    3. リンク後は、Googleでログインできるようになる

- **用途**:
    - プロバイダーからの新規登録を防ぎたいが、既存ユーザーには統合を許可したい
    - メインの認証方法は別にあり、Googleは補助的な認証手段として使用
    - 段階的な移行（最初はローカルアカウント、後でソーシャルログインを追加）

#### 無効の場合（デフォルト）
- **動作**:
    1. ユーザーはログインページから直接Googleでログインできる
    2. 新規ユーザーはGoogleアカウントで登録できる
    3. 既存ユーザーもアカウント管理画面でリンクできる

- **用途**:
    - 標準的なソーシャルログイン
    - Googleを主要な認証方法として使用

**使用シナリオ**

##### 有効にすべき場合

1. **企業の段階的移行**:
   ```
   フェーズ1: すべてのユーザーがローカルアカウントでログイン
   フェーズ2: Account linking onlyを有効にし、ユーザーが任意でGoogleをリンク
   フェーズ3: 十分なユーザーがリンクしたら、Googleログインを主要な方法に
   ```

2. **既存ユーザーベースがある場合**:
    - 何千ものローカルアカウントが既に存在
    - 新規ユーザーには別の認証方法を使用
    - 既存ユーザーには利便性向上のためGoogle連携を提供

3. **セキュリティポリシー**:
    - 新規ユーザーは承認プロセスを経る必要がある
    - ソーシャルログインでの自動登録を許可したくない
    - ユーザーベースを厳密に管理したい

4. **複数の認証方法の統合**:
    - メイン: LDAP/Active Directory認証
    - サブ: Googleアカウントをリンクして、外部からのアクセスを許可
    - 新規ユーザーはLDAP経由でのみ作成

5. **B2B環境**:
    - 顧客企業の管理者が従業員を招待
    - 招待されたユーザーのみがアカウントを持つ
    - 従業員は自分のGoogleアカウントをリンクして便利に使用

##### 無効のままにすべき場合

1. **B2Cアプリケーション**:
    - 誰でも自由に登録できる
    - ソーシャルログインがメインの登録方法
    - 新規ユーザー獲得が重要

2. **完全なSSO環境**:
    - Googleが主要な認証プロバイダー
    - ローカルアカウントは使用しない
    - すべてのユーザーがGoogleアカウントを持っている

3. **シンプルな実装**:
    - 複雑なアカウント管理を避けたい
    - ユーザーが自由に認証方法を選べる

**アカウントリンクのユーザーフロー**

##### Account linking only有効時:

```
【新規ユーザー（アカウントなし）】
1. ログインページにアクセス
2. Googleログインボタンは表示されない（または無効）
3. 別の方法でアカウントを作成する必要がある
   → 管理者による招待
   → 別のIdentity Provider
   → ローカルアカウント登録（許可されている場合）

【既存ユーザー（ローカルアカウント所持）】
1. ローカルアカウントでログイン
2. Account Console（https://keycloak.example.com/realms/myrealm/account）にアクセス
3. 「Linked accounts」セクションを開く
4. 「Link account」ボタンをクリック（Googleの横）
5. Google認証画面にリダイレクト
6. 認証完了後、アカウントがリンクされる
7. 次回からGoogleでもログイン可能

【リンク済みユーザー】
1. ログインページにアクセス
2. Googleログインボタンをクリック（表示される場合）
   または `kc_idp_hint=google`でアクセス
3. Googleで認証
4. 即座にログイン成功
```

**技術的な実装詳細**

##### アカウントリンクAPI:
```
POST /realms/{realm}/broker/{provider-alias}/link
```
- ユーザーが認証済みの状態で呼び出す
- Identity Providerでの認証フローを開始
- 成功すると、アカウントがリンクされる

##### リンク解除API:
```
DELETE /realms/{realm}/account/linked-accounts/{provider-alias}
```
- ユーザーが自分でリンクを解除できる
- 管理者もAdmin Consoleから解除可能

##### データベーススキーマ:
```sql
-- FEDERATED_IDENTITY テーブル
USER_ID: Keycloakのユーザー ID
IDENTITY_PROVIDER: "google"
FEDERATED_USER_ID: GoogleのユーザーID (sub claim)
FEDERATED_USERNAME: Googleのメールアドレス等
```

**「Hide on login page」との組み合わせ**

| Account linking only | Hide on login page | 結果 |
|---------------------|-------------------|------|
| 無効 | 無効 | ログインページにボタン表示、誰でもログイン可能 |
| 無効 | 有効 | ボタンは非表示だが、kc_idp_hintで直接アクセス可能 |
| 有効 | 無効 | ボタンは表示されるが、新規ログインは不可 |
| 有効 | 有効 | **ボタン非表示、アカウントリンクのみ可能**（推奨） |

**First Login Flowとの相互作用**

Account linking onlyが有効でも、First Login Flowは実行されます:
- 既存ユーザーがアカウントをリンクする際
- First Login FlowでDuplicate Email検出等のチェックが行われる
- リンクが許可されるかどうかをカスタマイズ可能

**セキュリティ上の考慮事項**

1. **メールアドレスの重複**:
    - 既存ユーザーのメールアドレスとGoogleアカウントのメールアドレスが一致するか確認
    - First Login Flowで適切に処理する必要がある

2. **アカウント乗っ取りのリスク**:
    - ユーザーAが誤って他人のGoogleアカウントをリンクしないよう注意
    - メール検証とユーザー確認が重要

3. **リンク解除の管理**:
    - ユーザーが自分でリンクを解除できるか決定
    - リンク解除後の認証方法を確保

**ユースケース例**

##### ユースケース1: 企業のゼロトラスト移行
```yaml
状況:
  - 企業がオンプレミスLDAPを使用
  - Google Workspaceに移行中
  - 移行期間中は両方をサポート

設定:
  Google Identity Provider:
    Account linking only: 有効
    Hide on login page: 無効
    Hosted Domain: company.com
  
フロー:
  1. 従業員はLDAPでログイン（従来通り）
  2. 任意でGoogleアカウントをリンク
  3. リンク後はGoogleでもログイン可能
  4. 移行完了後、LDAPを廃止してGoogleのみに
```

##### ユースケース2: パートナーポータル
```yaml
状況:
  - B2B SaaSプラットフォーム
  - 管理者が従業員を招待
  - 従業員は自分のGoogleアカウントで便利にアクセスしたい

設定:
  Google Identity Provider:
    Account linking only: 有効
    Hide on login page: 有効
    Trust Email: 有効

フロー:
  1. 管理者が従業員にメール招待を送信
  2. 従業員がローカルアカウントを作成
  3. Account ConsoleでGoogleアカウントをリンク
  4. 以降、Googleで簡単ログイン
```

**トラブルシューティング**

##### 問題: 新規ユーザーがGoogleでログインできない
- **原因**: Account linking onlyが有効
- **確認**: 意図的な設定か確認。新規登録を許可する場合は無効に。

##### 問題: リンクボタンがAccount Consoleに表示されない
- **原因**:
    - Identity Providerが無効
    - ユーザーに権限がない
- **解決**: Admin Consoleで設定を確認

##### 問題: 同じメールアドレスの別ユーザーがリンクしようとする
- **原因**: First Login Flowの設定
- **解決**: Duplicate Email検出を有効にし、適切に処理

**ベストプラクティス**

1. **段階的な導入**:
    - 最初はAccount linking onlyで開始
    - ユーザーフィードバックを収集
    - 問題なければ完全に移行

2. **明確なコミュニケーション**:
    - ユーザーにアカウントリンクの方法を説明
    - ドキュメントやチュートリアルを提供

3. **バックアップ認証方法**:
    - リンクしたIdentity Providerが使えなくなった場合の代替手段を確保
    - パスワードリセット機能等

4. **監視とログ**:
    - アカウントリンクの成功/失敗をログに記録
    - 異常なパターンを検出

---

### Hide on login page（ログインページで非表示）

**概要**
- ログインページでこのIdentity Providerのログインボタンを表示するかどうかを制御します。

**詳細説明**
- 有効にすると、標準のログインページには「Googleでログイン」ボタンが表示されません。
- ただし、特定のパラメータを使用することで、Googleログインに直接アクセスできます。

**動作の詳細**

#### 無効の場合（デフォルト）
- **動作**:
    1. ユーザーがログインページにアクセス
    2. **「Googleでログイン」ボタンが表示される**
    3. ユーザーがボタンをクリックしてGoogle認証を開始
    4. 通常のソーシャルログインフロー

- **表示位置**:
    - ユーザー名/パスワード入力フォームの下または横
    - 他のIdentity Providerと並んで表示
    - カスタマイズ可能なテーマで位置を調整可能

#### 有効の場合
- **動作**:
    1. ユーザーがログインページにアクセス
    2. **「Googleでログイン」ボタンは表示されない**
    3. 通常のユーザー名/パスワードログインフォームのみ表示

- **アクセス方法**（非表示でもアクセス可能）:

  ##### 方法1: `kc_idp_hint`パラメータ
  ```
  https://keycloak.example.com/realms/myrealm/protocol/openid-connect/auth
    ?client_id=myapp
    &redirect_uri=https://myapp.example.com/callback
    &response_type=code
    &scope=openid
    &kc_idp_hint=google
  ```
    - `kc_idp_hint`でIdentity Providerのエイリアスを指定
    - ログインページをバイパスし、直接Google認証にリダイレクト

  ##### 方法2: 直接URL
  ```
  https://keycloak.example.com/realms/myrealm/broker/google/login
    ?client_id=myapp
    &redirect_uri=https://myapp.example.com/callback
  ```
    - Identity Providerの直接URLにアクセス

  ##### 方法3: Identity Provider Authenticator
    - Authentication Flowでプログラマティックに選択
    - 条件に基づいて自動的にIdentity Providerを決定

**使用シナリオ**

##### 有効にすべき場合

1. **企業内部システム**:
   ```yaml
   状況:
     - Google Workspaceを使用している企業
     - すべての従業員がGoogleアカウントを持っている
     - ログインページをシンプルに保ちたい
   
   設定:
     Hide on login page: 有効
     
   実装:
     - アプリケーションのログインボタンから kc_idp_hint=google で直接リダイレクト
     - ユーザーはKeycloakのログインページを見ない
     - シームレスなGoogle SSO体験
   ```

2. **マルチテナントアプリケーション**:
   ```yaml
   状況:
     - 各企業が異なるIdentity Providerを使用
     - 企業A: Google Workspace
     - 企業B: Microsoft Azure AD
     - 企業C: SAML
   
   設定:
     すべてのIdentity Provider:
       Hide on login page: 有効
   
   実装:
     - ユーザーが企業ドメインを入力
     - アプリケーションがドメインに基づいて適切なIdentity Providerを決定
     - kc_idp_hintで該当するプロバイダーにリダイレクト
   ```

3. **ホワイトラベルアプリケーション**:
   ```yaml
   状況:
     - 各顧客にカスタマイズされた認証体験を提供
     - 顧客ごとに異なるIdentity Provider
   
   設定:
     Hide on login page: 有効
   
   実装:
     - サブドメインやパスで顧客を識別
     - customer1.app.com → Google
     - customer2.app.com → Azure AD
     - 自動的に適切なIdentity Providerにルーティング
   ```

4. **段階的な移行**:
   ```yaml
   状況:
     - レガシーシステムから新システムへ移行中
     - 一部ユーザーのみ新しい認証方法を使用
   
   設定:
     Hide on login page: 有効
   
   実装:
     - ベータテスターやパイロットユーザーには専用リンク提供
     - kc_idp_hintで新しいIdentity Providerにアクセス
     - 一般ユーザーは従来のログイン方法を継続
   ```

5. **セキュリティ要件**:
   ```yaml
   状況:
     - 特定のIdentity Providerは内部ユーザー専用
     - 外部ユーザーには見せたくない
   
   設定:
     内部用Identity Provider:
       Hide on login page: 有効
   
   実装:
     - 内部ネットワークからのアクセスのみkc_idp_hintを使用
     - 外部ユーザーはそもそもオプションを知らない
   ```

##### 無効のままにすべき場合

1. **一般公開アプリケーション**:
    - B2Cアプリケーション
    - 誰でも自由に認証方法を選べる
    - ソーシャルログインを積極的に提示したい

2. **シンプルな認証要件**:
    - 1〜2個のIdentity Providerのみ
    - ユーザーが選択できることが重要
    - 追加の実装が不要

3. **ユーザーの自由な選択を重視**:
    - 複数の認証オプションを提供
    - ユーザーが好みの方法を選べる
    - 透明性が重要

**実装パターン**

##### パターン1: アプリケーション側でルーティング

```javascript
// フロントエンドコード
function loginWithGoogle() {
  const keycloakUrl = 'https://keycloak.example.com/realms/myrealm/protocol/openid-connect/auth';
  const params = new URLSearchParams({
    client_id: 'myapp',
    redirect_uri: 'https://myapp.example.com/callback',
    response_type: 'code',
    scope: 'openid email profile',
    kc_idp_hint: 'google'  // 直接Google認証へ
  });
  
  window.location.href = `${keycloakUrl}?${params.toString()}`;
}

// HTMLボタン
<button onclick="loginWithGoogle()">
  <img src="google-icon.png"> Sign in with Google
</button>
```

##### パターン2: ドメインベースのルーティング

```javascript
// ユーザーがメールアドレスを入力
function handleEmailSubmit(email) {
  const domain = email.split('@')[1];
  
  let idpHint;
  switch(domain) {
    case 'company-a.com':
      idpHint = 'google';
      break;
    case 'company-b.com':
      idpHint = 'azure-ad';
      break;
    case 'partner.com':
      idpHint = 'saml-partner';
      break;
    default:
      // デフォルトのログインページにリダイレクト
      redirectToDefaultLogin();
      return;
  }
  
  redirectToKeycloak(idpHint);
}
```

##### パターン3: Identity Provider Authenticator

```java
// カスタムAuthenticator実装
public class DomainBasedIdPSelector implements Authenticator {
    @Override
    public void authenticate(AuthenticationFlowContext context) {
        String email = context.getAuthenticationSession()
            .getAuthNote("EMAIL");
        
        if (email != null) {
            String domain = email.substring(email.indexOf('@') + 1);
            
            // ドメインに基づいてIdentity Providerを選択
            String idpAlias = mapDomainToIdP(domain);
            
            if (idpAlias != null) {
                // 自動的にIdentity Providerにリダイレクト
                context.setAuthenticationSelection(idpAlias);
                return;
            }
        }
        
        // デフォルトの動作
        context.attempted();
    }
}
```

**`kc_idp_hint`の詳細**

##### 標準的な使用方法:
```
kc_idp_hint={identity-provider-alias}
```

##### 複数のプロバイダーから選択（スペース区切り）:
```
kc_idp_hint=google microsoft
```
- ユーザーにこれらのオプションのみを表示
- 他のIdentity Providerは表示されない

##### OpenID Connect / OAuth 2.0仕様:
- `kc_idp_hint`はKeycloak固有のパラメータ
- 標準仕様の`idp_hint`とは異なる
- Keycloakが独自に実装

**UIカスタマイゼーション**

##### カスタムテーマでの制御:

```html
<!-- login.ftl テンプレート -->
<#if social.providers??>
  <div class="social-providers">
    <#list social.providers as provider>
      <#-- Hide on login page が有効なプロバイダーは表示されない -->
      <#if !provider.hidden>
        <a href="${provider.loginUrl}" 
           class="social-link ${provider.alias}">
          <i class="${provider.iconClass}"></i>
          ${msg("${provider.displayName}")}
        </a>
      </#if>
    </#list>
  </div>
</#if>
```

**セキュリティ上の考慮事項**

1. **隠蔽によるセキュリティの誤解**:
    - ボタンを隠しても、直接URLでアクセス可能
    - 真のアクセス制御ではない
    - 「Account linking only」と組み合わせることで実質的に制限可能

2. **エニュメレーション攻撃**:
    - 攻撃者が様々なエイリアスを試す可能性
    - 推測しにくいエイリアス名を使用
    - レート制限を実装

3. **ユーザビリティ vs セキュリティ**:
    - 隠すことでユーザーが迷う可能性
    - 適切なドキュメントとガイダンスを提供

**他の設定との組み合わせ**

| Hide on login page | Account linking only | 動作 |
|-------------------|---------------------|------|
| 無効 | 無効 | ボタン表示、誰でもログイン可能 |
| 有効 | 無効 | ボタン非表示、kc_idp_hintでアクセス可能 |
| 無効 | 有効 | ボタン表示、既存ユーザーのみログイン可能 |
| 有効 | 有効 | ボタン非表示、リンク機能のみ |

**デバッグとトラブルシューティング**

##### 問題: kc_idp_hintが機能しない
- **確認事項**:
    - エイリアス名が正しいか
    - Identity Providerが有効になっているか
    - URLエンコーディングが正しいか

##### 問題: ユーザーがGoogle ログインを見つけられない
- **解決策**:
    - アプリケーション側でカスタムボタンを提供
    - ヘルプドキュメントにアクセス方法を記載
    - オンボーディングフローで説明

##### 問題: 意図しないプロバイダーが表示される
- **原因**: Hide on login pageの設定ミス
- **解決**: 各Identity Providerの設定を再確認

**ベストプラクティス**

1. **明確な意図を持つ**:
    - なぜ隠すのか明確にする
    - ユーザー体験への影響を考慮

2. **代替アクセス方法を提供**:
    - kc_idp_hintを使ったカスタムボタン
    - 直接リンク
    - ドキュメント

3. **段階的な展開**:
    - 最初は表示したまま
    - ユーザーの行動を観察
    - 必要に応じて隠す

4. **監視とフィードバック**:
    - ユーザーがどの認証方法を選んでいるか分析
    - サポートへの問い合わせをモニター
    - 継続的に改善

---

### Verify essential claim（必須クレームの検証）

**概要**
- Identity Providerが発行するIDトークンに特定のクレーム（claim）が含まれていることを検証し、含まれていない場合は認証を拒否する設定です。

**詳細説明**
- 有効にすると、IDトークンに必須のクレームが存在することを要求します。
- クレームの存在だけでなく、特定の値を要求することも可能です。
- これにより、特定の条件を満たすユーザーのみを許可できます。

**クレーム（Claim）とは**
- OpenID Connect / OAuth 2.0におけるユーザー属性情報の単位
- IDトークンに含まれるJSON形式のキー・バリューペア
- 例: `{"email": "user@example.com", "email_verified": true, "hd": "company.com"}`

**動作の詳細**

#### 無効の場合（デフォルト）
- **動作**:
    1. Googleから返されたIDトークンを受け取る
    2. 基本的な検証（署名、有効期限等）を実行
    3. **追加のクレーム検証は行わない**
    4. 認証成功

- **用途**:
    - すべてのGoogleユーザーを許可
    - 特別な条件なし
    - シンプルな認証フロー

#### 有効の場合
- **動作**:
    1. Googleから返されたIDトークンを受け取る
    2. 基本的な検証を実行
    3. **指定されたクレームの存在と値を検証**
    4. クレームが存在し、値が一致する場合のみ認証成功
    5. そうでない場合は認証エラー

- **設定項目**:
    - **Essential Claim Name**: 検証するクレーム名
    - **Essential Claim Value**: 期待される値（オプション）
    - **Claim Value Type**: 値の型（String, JSON, List等）

**Googleで利用可能な主要クレーム**

##### 標準OpenID Connectクレーム

1. **`sub`（Subject）**
    - **説明**: ユーザーの一意識別子
    - **形式**: 文字列（例: "110169484474386276334"）
    - **用途**: 主キーとして使用
    - **検証例**: 特定のユーザーのみ許可

2. **`email`**
    - **説明**: メールアドレス
    - **形式**: 文字列（例: "user@example.com"）
    - **用途**: ユーザー識別、通知
    - **検証例**: 特定のドメインのメールのみ許可

3. **`email_verified`**
    - **説明**: メールアドレスが検証済みか
    - **形式**: ブール値（true/false）
    - **用途**: メール検証状態の確認
    - **検証例**: 検証済みメールのみ許可

4. **`name`**
    - **説明**: フルネーム
    - **形式**: 文字列（例: "John Doe"）
    - **用途**: 表示名

5. **`given_name`**
    - **説明**: 名
    - **形式**: 文字列（例: "John"）

6. **`family_name`**
    - **説明**: 姓
    - **形式**: 文字列（例: "Doe"）

7. **`picture`**
    - **説明**: プロフィール画像URL
    - **形式**: URL文字列

8. **`locale`**
    - **説明**: ロケール（言語設定）
    - **形式**: 文字列（例: "en", "ja"）

##### Google固有のクレーム

9. **`hd`（Hosted Domain）**
    - **説明**: Google Workspaceのドメイン
    - **形式**: 文字列（例: "company.com"）
    - **用途**: **最も重要な検証クレーム**
    - **検証例**: 特定の企業ドメインのみ許可

**設定例と使用シナリオ**

##### シナリオ1: Google Workspaceユーザーのみ許可

```yaml
設定:
  Verify essential claim: 有効
  Essential Claim Name: hd
  Essential Claim Value: company.com
  Claim Value Type: String

効果:
  - company.comドメインのGoogle Workspaceアカウントのみ認証成功
  - 個人のGmailアカウント（@gmail.com）は拒否
  - 他の企業ドメインも拒否
```

**IDトークン例（成功）:**
```json
{
  "email": "john@company.com",
  "hd": "company.com",  // ← 一致するので成功
  "email_verified": true
}
```

**IDトークン例（失敗）:**
```json
{
  "email": "john@gmail.com",
  "hd": null,  // ← hdクレームがないので失敗
  "email_verified": true
}
```

##### シナリオ2: メール検証済みユーザーのみ許可

```yaml
設定:
  Verify essential claim: 有効
  Essential Claim Name: email_verified
  Essential Claim Value: true
  Claim Value Type: Boolean

効果:
  - メールアドレスが検証済みのユーザーのみ認証成功
  - 未検証のメールアドレスは拒否
```

**注意**: Googleは通常すべてのアカウントでメールを検証済みにしているため、この設定は実質的に無意味な場合が多いです。

##### シナリオ3: 複数ドメインを許可（正規表現）

```yaml
設定:
  Verify essential claim: 有効
  Essential Claim Name: hd
  Essential Claim Value: (company\.com|subsidiary\.net|partner\.org)
  Claim Value Type: String (正規表現)

効果:
  - company.com, subsidiary.net, partner.orgのいずれかのドメインを許可
  - 他のドメインは拒否
```

**注意**: Keycloakのバージョンによっては正規表現サポートが異なる場合があります。

##### シナリオ4: 特定のロケールのユーザーのみ

```yaml
設定:
  Verify essential claim: 有効
  Essential Claim Name: locale
  Essential Claim Value: ja
  Claim Value Type: String

効果:
  - 日本語ロケールのユーザーのみ許可
  - 地域限定サービスに有用
```

**使用シナリオ**

##### 有効にすべき場合

1. **企業内部システム（厳格なアクセス制御）**:
   ```yaml
   要件:
     - 自社ドメインのGoogle Workspaceアカウントのみ
     - 個人アカウントや他社アカウントを完全にブロック
   
   設定:
     Verify essential claim: 有効
     Essential Claim Name: hd
     Essential Claim Value: mycompany.com
   
   メリット:
     - Hosted Domain設定よりも厳格
     - IDトークンレベルで検証（改ざん困難）
   ```

2. **B2Bアプリケーション（パートナー企業管理）**:
   ```yaml
   要件:
     - 承認済みパートナー企業のみアクセス可能
     - 企業ごとに異なるIdentity Providerを設定
   
   設定:
     Partner A用Identity Provider:
       Essential Claim Name: hd
       Essential Claim Value: partnera.com
     
     Partner B用Identity Provider:
       Essential Claim Name: hd
       Essential Claim Value: partnerb.com
   ```

3. **コンプライアンス要件**:
   ```yaml
   要件:
     - GDPR等の規制により、特定地域のユーザーのみ
     - データ主権の確保
   
   設定:
     Essential Claim Name: hd
     Essential Claim Value: eu-subsidiary.com
   
   または:
     カスタムクレームで地域情報を検証
   ```

4. **段階的なロールアウト**:
   ```yaml
   要件:
     - ベータテストを特定のドメインのみに制限
     - 本番展開前の検証
   
   設定:
     Essential Claim Name: hd
     Essential Claim Value: beta.company.com
   
   フロー:
     - ベータドメインのユーザーのみアクセス可能
     - 問題なければ本番ドメインに拡大
   ```

5. **セキュリティ監査要件**:
   ```yaml
   要件:
     - すべてのアクセスが検証済みメールから
     - 監査ログで追跡可能
   
   設定:
     Essential Claim Name: email_verified
     Essential Claim Value: true
   ```

##### 無効のままにすべき場合

1. **一般公開アプリケーション**:
    - すべてのGoogleユーザーを受け入れる
    - B2Cアプリケーション
    - 制限なしのソーシャルログイン

2. **柔軟な認証要件**:
    - さまざまなタイプのGoogleアカウントをサポート
    - ユーザーベースが多様

3. **シンプルな実装**:
    - 追加の検証ロジックが不要
    - 基本的なSSO認証のみ

**「Hosted Domain」設定との違い**

| 項目 | Hosted Domain | Verify essential claim (hd) |
|------|--------------|---------------------------|
| **検証場所** | Keycloakのビジネスロジック | IDトークンの署名付きクレーム |
| **改ざん耐性** | 低（実装依存） | 高（Googleの署名で保護） |
| **柔軟性** | ドメインのみ | 任意のクレームを検証可能 |
| **設定方法** | General settingsのフィールド | Advanced settingsで詳細設定 |
| **エラーメッセージ** | 一般的なエラー | より具体的なエラー |
| **監査証跡** | 標準ログ | クレーム検証ログ |

**推奨**: 企業環境では**両方を設定**することでセキュリティを強化できます。

**設定手順（Admin Console）**

1. **Identity Providerを開く**:
   ```
   Realm Settings → Identity Providers → Google
   ```

2. **Advanced settingsセクションに移動**

3. **Verify essential claimを有効化**

4. **クレーム情報を入力**:
   ```
   Essential Claim Name: hd
   Essential Claim Value: company.com
   Claim Value Type: String
   ```

5. **保存**

6. **テスト**:
    - 正しいドメインのアカウントでログイン → 成功
    - 間違ったドメインのアカウントでログイン → 失敗

**エラーハンドリング**

##### 認証失敗時の動作:

```
エラーメッセージ例:
"Required claim 'hd' is missing or has an incorrect value in the identity token."
```

##### ユーザーへの表示:
- Keycloakのエラーページが表示される
- カスタムテーマでメッセージを改善可能
- 適切なガイダンスを提供（例: "このサービスは company.com ドメインのユーザーのみが利用できます"）

##### ログ出力:
```
WARN [org.keycloak.broker] (default task-1) 
Essential claim validation failed for user. 
Required claim: hd, Expected value: company.com, Actual value: null
```

**複数のクレームを検証する方法**

Keycloakの標準機能では1つのクレームのみ検証可能ですが、複数のクレームを検証したい場合:

##### 方法1: カスタムAuthenticator
```java
public class MultiClaimValidator implements Authenticator {
    @Override
    public void authenticate(AuthenticationFlowContext context) {
        BrokeredIdentityContext identity = 
            (BrokeredIdentityContext) context.getAuthenticationSession()
                .getAuthNote(AbstractIdpAuthenticator.BROKERED_CONTEXT_NOTE);
        
        JsonWebToken token = identity.getToken();
        
        // 複数のクレームを検証
        String hd = token.getOtherClaims().get("hd").toString();
        Boolean emailVerified = (Boolean) token.getOtherClaims()
            .get("email_verified");
        
        if (!"company.com".equals(hd) || !emailVerified) {
            context.failure(AuthenticationFlowError.INVALID_USER);
            return;
        }
        
        context.success();
    }
}
```

##### 方法2: 複数のIdentity Provider
```yaml
Google-CompanyA:
  Essential Claim Name: hd
  Essential Claim Value: companya.com

Google-CompanyB:
  Essential Claim Name: hd
  Essential Claim Value: companyb.com
```
- それぞれ異なるクレーム要件を持つIdentity Providerを作成
- ユーザーまたはアプリケーションが適切なものを選択

**高度な検証パターン**

##### パターン1: ネストされたクレーム

一部のIdentity Providerは、ネストされたJSONクレームを返します:
```json
{
  "organization": {
    "domain": "company.com",
    "department": "engineering"
  }
}
```

検証設定:
```yaml
Essential Claim Name: organization.domain
Essential Claim Value: company.com
Claim Value Type: String
```

**注意**: Keycloakのバージョンによってネストされたクレームのサポートが異なります。

##### パターン2: 配列クレーム

```json
{
  "groups": ["admin", "developer", "manager"]
}
```

検証設定:
```yaml
Essential Claim Name: groups
Essential Claim Value: admin
Claim Value Type: List (contains)
```

クレームの配列に"admin"が含まれているか検証します。

##### パターン3: カスタムクレーム

Googleは標準クレームのみを提供しますが、他のIdentity Providerでは:
```json
{
  "custom:department": "engineering",
  "custom:clearance_level": "secret"
}
```

検証設定:
```yaml
Essential Claim Name: custom:clearance_level
Essential Claim Value: secret
Claim Value Type: String
```

**Claim Value Type（クレーム値の型）**

Keycloakがサポートする主な型:

1. **String**
    - 文字列の完全一致
    - 例: "company.com"

2. **Boolean**
    - true/false の検証
    - 例: true

3. **Integer/Long**
    - 数値の比較
    - 例: 18（年齢制限等）

4. **JSON**
    - JSON構造の検証
    - 複雑なオブジェクトの比較

5. **List**
    - 配列に特定の値が含まれるか
    - 例: グループメンバーシップ

**セキュリティ上の考慮事項**

1. **IDトークンの署名検証**:
    - Keycloakは自動的にGoogleの署名を検証
    - クレームの改ざんは検出される
    - 追加の検証層として機能

2. **クライアントサイドでの検証との違い**:
    - クライアントでの検証はバイパス可能
    - サーバーサイド（Keycloak）での検証は信頼できる
    - 必ずサーバーサイドで検証する

3. **時間ベースの攻撃**:
    - IDトークンには有効期限がある（通常1時間）
    - 期限切れトークンでの認証は自動的に失敗

4. **クレームインジェクション攻撃**:
    - Googleの署名により保護されている
    - 攻撃者が偽のクレームを注入することは不可能

**デバッグとトラブルシューティング**

##### 問題: 正しいドメインのユーザーが認証できない

**診断手順**:

1. **IDトークンの内容を確認**:
   ```
   KeycloakのログレベルをDEBUGに設定
   → IDトークンの内容がログに出力される
   ```

2. **クレーム名のスペルミス**:
   ```
   間違い: "hd "（末尾にスペース）
   正しい: "hd"
   ```

3. **クレーム値の大文字小文字**:
   ```
   設定: Company.com
   実際: company.com
   → 一致しない（大文字小文字を区別）
   ```

4. **クレームが存在しない**:
   ```
   個人のGmailアカウントには"hd"クレームがない
   → Hosted Domain設定と組み合わせる
   ```

##### 問題: エラーメッセージが不明確

**解決策**:
- カスタムテーマでエラーメッセージを改善
- ユーザーに具体的なガイダンスを提供

```html
<!-- error.ftl -->
<#if message.summary == "required_claim_validation_failed">
  <div class="alert alert-error">
    <p>このアプリケーションは ${realmName} 組織のメンバーのみが
       利用できます。</p>
    <p>company.com ドメインのGoogle Workspaceアカウントで
       ログインしてください。</p>
    <p>個人のGmailアカウント（@gmail.com）は使用できません。</p>
  </div>
</#if>
```

##### 問題: 一部のユーザーのみ失敗する

**確認事項**:
1. ユーザーのGoogleアカウントの種類
    - Google Workspace vs 個人アカウント
2. ドメイン設定
    - ユーザーが複数のドメインに所属している場合
3. スコープ設定
    - 必要なクレームを取得するスコープが設定されているか

**パフォーマンスへの影響**

- **オーバーヘッド**: 最小限
- **検証タイミング**: IDトークン受信後、ユーザー作成前
- **失敗時の処理**: 即座にエラーを返す（ユーザー作成なし）
- **成功時の処理**: 通常フローと同じ

**ベストプラクティス**

1. **Hosted Domainと併用**:
   ```yaml
   General settings:
     Hosted Domain: company.com  # 第一の防御線
   
   Advanced settings:
     Verify essential claim: 有効
     Essential Claim Name: hd
     Essential Claim Value: company.com  # 第二の防御線
   ```
    - 多層防御でセキュリティを強化

2. **明確なドキュメント**:
    - どのような条件でアクセスが許可されるか明記
    - ユーザー向けFAQを用意
    - サポートチームへのガイドライン

3. **段階的な展開**:
    - 最初はログのみ（検証失敗をログに記録するが、認証は許可）
    - 問題がないことを確認後、実際に制限を有効化

4. **監視とアラート**:
    - 検証失敗のメトリクスを収集
    - 異常なパターンを検出
    - セキュリティインシデントの早期発見

5. **バックアップ認証方法**:
    - クレーム検証が厳しすぎて正当なユーザーがロックアウトされる場合に備える
    - 管理者が手動でアカウントを作成できる仕組み
    - 緊急時のバイパス手順

**実世界のユースケース**

##### ユースケース1: 金融機関
```yaml
要件:
  - 従業員のみアクセス可能
  - 個人アカウント完全禁止
  - 監査証跡が必須

設定:
  Hosted Domain: bank.com
  Verify essential claim: 有効
    Essential Claim Name: hd
    Essential Claim Value: bank.com
  Store tokens: 無効（セキュリティ）

結果:
  - bank.comドメインのみアクセス可能
  - IDトークンレベルでの検証
  - すべての認証試行をログに記録
```

##### ユースケース2: 教育機関
```yaml
要件:
  - 学生と教職員でドメインが異なる
  - 両方を許可したい

オプション1: 複数ドメインのHosted Domain
  Hosted Domain: university.edu,students.university.edu

オプション2: 正規表現（カスタム実装）
  Essential Claim Name: hd
  Essential Claim Value: .*\.university\.edu

結果:
  - 大学関連のすべてのサブドメインを許可
```

##### ユースケース3: マルチリージョンSaaS
```yaml
要件:
  - 地域ごとに異なるデータセンター
  - データ主権の遵守

設定:
  EU Identity Provider:
    Essential Claim Name: hd
    Essential Claim Value: (eu-subsidiary\.com|europe\.company\.com)
  
  US Identity Provider:
    Essential Claim Name: hd
    Essential Claim Value: (us-subsidiary\.com|americas\.company\.com)

結果:
  - 地域に応じて適切なIdentity Providerを使用
  - データが適切なリージョンに保存される
```

**まとめ**

Verify essential claimは、強力なアクセス制御メカニズムです:

✅ **利点**:
- 細かいアクセス制御
- IDトークンレベルでの検証（改ざん耐性）
- 柔軟なクレームベースの認証
- コンプライアンス要件の充足

⚠️ **注意点**:
- 設定ミスで正当なユーザーをブロックする可能性
- 明確なエラーメッセージとドキュメントが必要
- 他のセキュリティ機能との併用が推奨

---

## First login flow override（初回ログインフローの上書き）

**概要**
- Identity Providerでの初回ログイン時に実行される認証フローをカスタマイズする設定です。

**詳細説明**
- ユーザーがこのIdentity Providerで初めてログインする際（Keycloakアカウントがまだリンクされていない）に、特別な認証フローを実行できます。
- デフォルトのフローを上書きし、カスタムの処理を追加できます。

**「初回ログイン」の定義**
- Google Identity Providerで認証されたGoogleアカウント（subject ID）が、まだKeycloakの既存ユーザーにリンクされていない状態
- つまり、`FEDERATED_IDENTITY`テーブルにこのGoogleアカウントのレコードが存在しない

**デフォルトの初回ログインフロー**

Keycloakのデフォルト「First Broker Login」フロー:

```
1. Review Profile
   - ユーザーにプロフィール情報（名前、メールアドレス等）を確認させる
   - 必要に応じて編集を許可

2. Create User If Unique
   - メールアドレスが既存ユーザーと重複していないか確認
   - 重複していない場合: 新しいユーザーを自動作成
   - 重複している場合: 次のステップへ

3. Handle Existing Account
   - 既存のアカウントとリンクするか、新しいアカウントを作成するかを選択
   - ユーザーに選択肢を提示
```

**動作の詳細**

#### 未設定の場合（デフォルト）
- **動作**:
    1. ユーザーがGoogleで認証（初回）
    2. Keycloakのデフォルト「First Broker Login」フローが実行される
    3. プロフィール確認画面が表示される（場合によって）
    4. 重複チェックが実行される
    5. 新しいユーザーが作成される、またはアカウントリンクが行われる

#### 設定した場合
- **動作**:
    1. ユーザーがGoogleで認証（初回）
    2. **指定されたカスタム認証フローが実行される**
    3. カスタムフローで定義された処理が順次実行される
    4. すべてのステップが成功すると、ユーザーが作成/リンクされる

**認証フロー（Authentication Flow）とは**

Keycloakにおける認証フローは、一連の認証ステップを定義したものです:

```
認証フロー
├── ステップ1: Cookie確認
├── ステップ2: Kerberos認証（オプション）
├── ステップ3: Identity Provider Redirector
└── ステップ4: ユーザー名/パスワードフォーム
    ├── サブステップ4-1: ユーザー名/パスワード検証
    └── サブステップ4-2: OTP検証（条件付き）
```

**利用可能なカスタムフローの作成方法**

1. **Admin Consoleでの作成**:
   ```
   Authentication → Flows → Create Flow
   ```

2. **フロー名を入力**:
   ```
   例: "Google First Login - Company Policy"
   ```

3. **Executionsを追加**:
    - 既存のAuthenticatorから選択
    - カスタムAuthenticatorを実装して追加

**カスタムフローの構成要素**

##### 利用可能な主要なAuthenticator:

1. **Create User If Unique**
    - メールアドレスの重複をチェック
    - 重複がなければ新しいユーザーを作成

2. **Automatically Set Existing User**
    - メールアドレスが一致する既存ユーザーに自動的にリンク
    - セキュリティリスクがあるため慎重に使用

3. **Prompt for password**
    - 既存アカウントのパスワード入力を要求
    - アカウント乗っ取り防止

4. **Review Profile**
    - ユーザーにプロフィール情報を確認・編集させる
    - 必須項目の入力を強制

5. **Deny Access**
    - 条件に応じてアクセスを拒否
    - 例: 特定のドメイン以外を拒否

6. **OTP Form**
    - ワンタイムパスワードによる二要素認証
    - 初回登録時のセキュリティ強化

7. **Terms and Conditions**
    - 利用規約への同意を要求
    - 法的要件の充足

8. **Attribute Mapping**
    - Identity Providerから取得した属性を特定の方法でマッピング
    - カスタム属性の処理

**使用シナリオ**

##### シナリオ1: 自動アカウント作成（摩擦最小化）

```yaml
目的:
  - ユーザーエクスペリエンスを最適化
  - 追加の確認ステップなし
  - 即座にアクセス許可

カスタムフロー構成:
  Flow Name: "Auto Create User"
  Executions:
    1. Create User If Unique
       Requirement: REQUIRED
       Settings:
         - Automatically create user
         - No profile review

設定:
  First login flow override: "Auto Create User"

結果:
  1. ユーザーがGoogleで認証
  2. 即座に新しいKeycloakユーザーが作成される
  3. プロフィール確認画面なし
  4. 即座にアプリケーションにアクセス
```

##### シナリオ2: 厳格なセキュリティ（既存アカウント保護）

```yaml
目的:
  - アカウント乗っ取り防止
  - 既存ユーザーのセキュリティ確保
  - メールアドレス重複時の適切な処理

カスタムフロー構成:
  Flow Name: "Secure First Login"
  Executions:
    1. Create User If Unique
       Requirement: ALTERNATIVE
       
    2. Prompt for password
       Requirement: ALTERNATIVE
       Settings:
         - Update profile on first login
         
    3. Handle Existing Account
       Requirement: REQUIRED

設定:
  First login flow override: "Secure First Login"

結果:
  【シナリオA: 新規ユーザー】
  1. メールアドレスが既存ユーザーと重複していない
  2. 自動的に新しいユーザーを作成
  
  【シナリオB: 既存ユーザー】
  1. メールアドレスが既存のKeycloakユーザーと一致
  2. ユーザーに既存アカウントのパスワード入力を要求
  3. パスワードが正しければアカウントをリンク
  4. 不正なアクセス試行を防止
```

##### シナリオ3: 利用規約同意必須

```yaml
目的:
  - 法的コンプライアンス
  - すべての新規ユーザーに利用規約同意を要求
  - GDPR/CCPA等への対応

カスタムフロー構成:
  Flow Name: "First Login with Terms"
  Executions:
    1. Review Profile
       Requirement: REQUIRED
       
    2. Terms and Conditions
       Requirement: REQUIRED
       Settings:
         - Terms version: v1.0
         
    3. Create User If Unique
       Requirement: REQUIRED

設定:
  First login flow override: "First Login with Terms"

結果:
  1. ユーザーがGoogleで認証
  2. プロフィール情報を確認
  3. 利用規約を表示
  4. ユーザーが「同意する」をクリック
  5. 同意記録がユーザー属性に保存
  6. ユーザーが作成される
```

##### シナリオ4: 二要素認証必須

```yaml
目的:
  - 高セキュリティ環境
  - 初回登録時からOTPを設定
  - 不正登録の防止

カスタムフロー構成:
  Flow Name: "First Login with 2FA Setup"
  Executions:
    1. Create User If Unique
       Requirement: REQUIRED
       
    2. OTP Form Setup
       Requirement: REQUIRED
       Settings:
         - Force OTP setup
         - Support TOTP and SMS

設定:
  First login flow override: "First Login with 2FA Setup"

結果:
  1. ユーザーがGoogleで認証
  2. 新しいユーザーが作成される
  3. OTPセットアップ画面が表示
  4. ユーザーがAuthenticatorアプリでQRコードをスキャン
  5. テストコードを入力
  6. 次回以降のログインでOTPが要求される
```

##### シナリオ5: 承認制（手動アカウント作成）

```yaml
目的:
  - 管理者の承認が必要
  - 自動登録を許可しない
  - ユーザーベースの厳格な管理

カスタムフロー構成:
  Flow Name: "Manual Approval Required"
  Executions:
    1. Deny Access
       Requirement: REQUIRED
       Settings:
         - Error message: "Please contact administrator for account activation"

設定:
  First login flow override: "Manual Approval Required"
  Account linking only: 有効（併用）

結果:
  1. ユーザーがGoogleで認証を試みる
  2. 「管理者にアカウント作成を依頼してください」というメッセージが表示される
  3. 管理者が手動でユーザーアカウントを作成
  4. 管理者がGoogleアカウントとKeycloakアカウントをリンク
  5. ユーザーがログイン可能になる
```

##### シナリオ6: ドメインベースのアクセス制御

```yaml
目的:
  - 特定のドメインのみ自動作成を許可
  - それ以外は拒否またはマニュアル承認

カスタムフロー構成:
  Flow Name: "Domain-Based Auto Create"
  Executions:
    1. Custom Domain Validator
       Requirement: REQUIRED
       Settings:
         - Allowed domains: company.com, partner.com
         
    2. Create User If Unique
       Requirement: REQUIRED

Custom Authenticator実装:
  public class DomainValidator implements Authenticator {
      public void authenticate(AuthenticationFlowContext context) {
          BrokeredIdentityContext identity = getBrokeredIdentity(context);
          String email = identity.getEmail();
          String domain = email.substring(email.indexOf('@') + 1);
          
          List<String> allowedDomains = Arrays.asList(
              "company.com", "partner.com"
          );
          
          if (!allowedDomains.contains(domain)) {
              context.failure(AuthenticationFlowError.INVALID_USER,
                  Response.status(403)
                      .entity("Your domain is not authorized")
                      .build()
              );
              return;
          }
          
          context.success();
      }
  }

設定:
  First login flow override: "Domain-Based Auto Create"

結果:
  - company.comユーザー: 自動作成
  - partner.comユーザー: 自動作成
  - gmail.comユーザー: アクセス拒否
```

**既存アカウントとの関係**

##### ケース1: メールアドレスが既存ユーザーと一致しない
```
Google認証: john@company.com (初回)
Keycloakの既存ユーザー: なし

→ Create User If Unique が新しいユーザーを作成
→ Googleアカウントがリンクされる
```

##### ケース2: メールアドレスが既存ユーザーと一致
```
Google認証: alice@company.com (初回)
Keycloakの既存ユーザー: alice@company.com (パスワード認証で作成済み)

オプションA: Automatically Set Existing User
  → 自動的にリンク（セキュリティリスク）

オプションB: Prompt for password
  → 既存アカウントのパスワード入力を要求
  → 正しければリンク

オプションC: Handle Existing Account
  → ユーザーに選択肢を提示
     - 既存アカウントにリンク（パスワード要求）
     - 新しいアカウントを作成（異なるユーザー名で）
```

**「Post login flow」との違い**

| 項目 | First login flow override | Post login flow |
|------|--------------------------|-----------------|
| **実行タイミング** | 初回ログイン時のみ | 毎回のログイン |
| **目的** | アカウント作成/リンクの制御 | 追加の認証・検証 |
| **典型的な用途** | プロフィール確認、利用規約同意 | OTP、条件付きアクセス |
| **実行頻度** | 1回のみ | 毎ログイン |

**技術的な実装詳細**

##### フローの作成（Admin Console）:

```
1. Authentication → Flows → New
   
2. Flow設定:
   Alias: My Custom First Login
   Description: Custom flow for Google first login
   Top Level Flow Type: generic

3. Add Execution:
   Provider: Create User If Unique
   Requirement: REQUIRED

4. Add Execution:
   Provider: Review Profile
   Requirement: DISABLED

5. Save

6. Identity Provider設定で選択:
   First login flow override: My Custom First Login
```

##### カスタムAuthenticatorの実装:

```java
public class CustomFirstLoginAuthenticator implements Authenticator {
    
    @Override
    public void authenticate(AuthenticationFlowContext context) {
        // Identity Providerから取得したユーザー情報
        BrokeredIdentityContext brokerContext = 
            (BrokeredIdentityContext) context.getAuthenticationSession()
                .getAuthNote(AbstractIdpAuthenticator.BROKERED_CONTEXT_NOTE);
        
        // ユーザー情報の検証
        String email = brokerContext.getEmail();
        String domain = email.substring(email.indexOf('@') + 1);
        
        // カスタムロジック
        if (isAllowedDomain(domain)) {
            // 許可されたドメイン
            createOrLinkUser(context, brokerContext);
            context.success();
        } else {
            // 拒否
            context.failure(AuthenticationFlowError.INVALID_USER);
        }
    }
    
    @Override
    public void action(AuthenticationFlowContext context) {
        // ユーザーが何かアクションを実行した後の処理
    }
    
    @Override
    public boolean requiresUser() {
        return false;  // まだユーザーが作成されていない
    }
    
    @Override
    public boolean configuredFor(KeycloakSession session, 
                                 RealmModel realm, UserModel user) {
        return true;
    }
    
    @Override
    public void setRequiredActions(KeycloakSession session, 
                                    RealmModel realm, UserModel user) {
        // 必要なアクションを設定（例: UPDATE_PROFILE）
    }
}
```

**デバッグとトラブルシューティング**

##### 問題: カスタムフローが実行されない

**確認事項**:
1. First login flow overrideが正しく設定されているか
2. フロー名のスペルミスがないか
3. フローが有効になっているか（Disabled になっていないか）

##### 問題: ユーザーが作成されない

**診断**:
1. ログを確認:
   ```
   tail -f /var/log/keycloak/server.log | grep "First Broker Login"
   ```

2. Create User If UniqueのRequirementを確認:
    - REQUIRED: 必須
    - ALTERNATIVE: 他の選択肢と排他的
    - DISABLED: 無効

3. メールアドレスの重複:
    - 既存ユーザーと重複している場合、Create User If Uniqueは失敗する

##### 問題: プロフィール確認画面が表示されない

**原因**:
- Review Profileがフローに含まれていない
- または、DISABLEDになっている

**解決**:
- フローにReview Profileを追加
- Requirementを REQUIRED または ALTERNATIVE に設定

##### 問題: エラーメッセージが不明確

**解決**:
- カスタムAuthenticatorで詳細なエラーメッセージを設定:
```java
Response response = Response.status(403)
    .entity("Your email domain (@" + domain + ") is not authorized. " +
            "Please contact support@company.com for assistance.")
    .build();
context.failure(AuthenticationFlowError.INVALID_USER, response);
```

**セキュリティ上の考慮事項**

1. **Automatically Set Existing Userのリスク**:
    - メールアドレスのみでアカウントをリンク
    - 攻撃者が他人のメールアドレスを持つGoogleアカウントを作成できる場合、アカウント乗っ取りが可能
    - **推奨**: 必ずパスワード確認を追加

2. **メールアドレスの検証**:
    - Identity Providerからのメールアドレスを信頼できるか確認
    - 「Trust Email」設定との組み合わせを検討

3. **ブルートフォース攻撃対策**:
    - 初回ログインフローでも試行回数制限を適用
    - Keycloakのブルートフォース検出機能を有効化

4. **セッションハイジャック**:
    - 初回ログイン完了後、セッショントークンを再生成
    - CSRFトークンを適切に使用

**パフォーマンスへの影響**

- **シンプルなフロー**: 数ミリ秒
- **複雑なフロー**: ユーザー入力待ち時間が主な要因
- **データベースクエリ**: Create User If Uniqueはメールアドレスで既存ユーザーを検索
- **最適化**: 必要な処理のみを含める

**ベストプラクティス**

1. **段階的なアプローチ**:
   ```
   フェーズ1: デフォルトフローで開始
   フェーズ2: プロフィール確認を追加
   フェーズ3: 利用規約を追加
   フェーズ4: セキュリティ強化（OTP等）
   ```

2. **ユーザーエクスペリエンスとセキュリティのバランス**:
    - B2C: 摩擦を最小化、自動作成
    - B2B: セキュリティ重視、手動承認
    - 企業内部: 中間、プロフィール確認程度

3. **明確なエラーメッセージ**:
    - ユーザーが次に何をすべきか明確に
    - サポート連絡先を提供

4. **監視とメトリクス**:
    - 初回ログインの成功率を追跡
    - どのステップで離脱が発生しているか分析
    - 継続的に改善

5. **テストの徹底**:
    - 新規ユーザーのシナリオ
    - 既存ユーザー（メール一致）のシナリオ
    - エラーケース（不正なドメイン等）

**実世界の設定例**

##### 例1: スタートアップ（Growth重視）
```yaml
First login flow override: "Auto Create - No Friction"
  Executions:
    - Create User If Unique (REQUIRED)

特徴:
  - 即座にユーザー作成
  - プロフィール確認なし
  - 利用規約は別途（アプリ内で）
  - 最速のオンボーディング
```

##### 例2: エンタープライズSaaS（Balance）
```yaml
First login flow override: "Balanced First Login"
  Executions:
    - Review Profile (REQUIRED)
    - Terms and Conditions (REQUIRED)
    - Create User If Unique (ALTERNATIVE)
    - Handle Existing Account (ALTERNATIVE)

特徴:
  - プロフィール確認で正確なデータ収集
  - 法的要件を満たす
  - 既存アカウントを適切に処理
```

##### 例3: 金融機関（Security重視）
```yaml
First login flow override: "High Security First Login"
  Executions:
    - Email Domain Validator (REQUIRED)
    - Create User If Unique (ALTERNATIVE)
    - Prompt for Password (ALTERNATIVE)
    - OTP Setup (REQUIRED)
    - Review Profile (REQUIRED)

特徴:
  - ドメイン検証で不正アクセス防止
  - 既存アカウント保護
  - 必須のOTP設定
  - 完全なプロフィール情報
```

**まとめ**

First login flow overrideは、Identity Providerでの初回ログイン体験を完全にカスタマイズできる強力な機能です:

✅ **活用できる場面**:
- ユーザーオンボーディングの最適化
- セキュリティ要件の充足
- 法的コンプライアンス（利用規約、GDPR等）
- 既存アカウントとの適切な統合

⚠️ **注意点**:
- 複雑すぎるフローはユーザーの離脱を招く
- セキュリティとユーザビリティのバランスが重要
- 十分なテストが必須

---

## Post login flow（ログイン後フロー）

**概要**
- このIdentity Providerでのログインの度に実行される認証フローを設定します。

**詳細説明**
- 「First login flow override」が初回のみ実行されるのに対し、「Post login flow」は**毎回のログイン時**に実行されます。
- 既にアカウントがリンクされているユーザーが再度ログインする際に、追加の認証や検証を行うために使用します。

**「First login flow」との主な違い**

| 項目 | First login flow | Post login flow |
|------|-----------------|-----------------|
| **実行タイミング** | 初回ログイン時のみ | 毎回のログイン |
| **対象ユーザー** | 未リンクのユーザー | 既にリンク済みのユーザー |
| **主な目的** | アカウント作成/リンク | 追加の認証・検証 |
| **ユーザー状態** | まだKeycloakアカウントがない | Keycloakアカウント既存 |
| **典型的な用途** | プロフィール確認、利用規約 | OTP、条件付きアクセス、属性更新 |

**デフォルトの動作（未設定の場合）**

Post login flowが設定されていない場合:
1. ユーザーがGoogleで認証
2. Keycloakが既存のアカウントリンクを確認
3. **追加の処理なし**
4. 即座にログイン完了

**動作の詳細**

#### 未設定（None）の場合
- **フロー**:
  ```
  1. ユーザーがGoogleで認証
  2. Identity Providerがユーザー情報を返す
  3. Keycloakが既存のリンクを確認
  4. ログイン完了
  5. アプリケーションにリダイレクト
  ```

- **用途**:
    - シンプルなSSO
    - 追加の認証が不要
    - ユーザーエクスペリエンス最優先

#### 設定した場合
- **フロー**:
  ```
  1. ユーザーがGoogleで認証
  2. Identity Providerがユーザー情報を返す
  3. **カスタムPost login flowが実行される**
  4. すべてのステップが成功するとログイン完了
  5. アプリケーションにリダイレクト
  ```

- **用途**:
    - 追加の二要素認証
    - 条件付きアクセス制御
    - ユーザー属性の更新
    - セキュリティチェック

**使用シナリオ**

##### シナリオ1: 二要素認証（OTP）必須

```yaml
目的:
  - すべてのGoogleログインの後にOTPを要求
  - Googleだけでは不十分なセキュリティ要件
  - 多層防御の実装

カスタムフロー構成:
  Flow Name: "Post Login with OTP"
  Executions:
    1. OTP Form
       Requirement: REQUIRED
       Settings:
         - OTP type: TOTP (Google Authenticator等)
         - Or SMS OTP

設定:
  Post login flow: "Post Login with OTP"

結果:
  1. ユーザーがGoogleで認証成功
  2. OTP入力画面が表示
  3. ユーザーがAuthenticatorアプリからコードを入力
  4. コードが正しければログイン完了
  5. 不正なコードは拒否

ユーザーフロー:
  Google認証 → OTP入力 → ログイン完了
```

**実装例**:
```
Authentication → Flows → Create Flow

Flow設定:
  Alias: Post Login with OTP
  Top Level Flow Type: generic

Add Execution:
  Provider: OTP Form
  Requirement: REQUIRED

Identity Provider設定:
  Post login flow: Post Login with OTP
```

##### シナリオ2: 条件付きアクセス（IP制限）

```yaml
目的:
  - 特定のIPアドレスからのアクセスのみ許可
  - 企業ネットワーク外からのアクセスに追加認証
  - ゼロトラストセキュリティの実装

カスタムフロー構成:
  Flow Name: "Conditional Access by IP"
  Executions:
    1. Custom IP Validator
       Requirement: REQUIRED
       Settings:
         - Allowed IP ranges: 
           - 192.168.1.0/24 (オフィス)
           - 10.0.0.0/8 (VPN)
       
    2. OTP Form
       Requirement: CONDITIONAL
       Condition: IP not in allowed ranges

カスタムAuthenticator実装:
  public class IPValidator implements Authenticator {
      public void authenticate(AuthenticationFlowContext context) {
          String clientIP = context.getConnection().getRemoteAddr();
          
          if (isAllowedIP(clientIP)) {
              // オフィスまたはVPNからのアクセス
              context.success();
          } else {
              // 外部からのアクセス - OTPを要求
              context.attempted();
          }
      }
      
      private boolean isAllowedIP(String ip) {
          // IPアドレスが許可範囲内かチェック
          return ipRanges.stream()
              .anyMatch(range -> range.contains(ip));
      }
  }

設定:
  Post login flow: "Conditional Access by IP"

結果:
  【オフィスからのアクセス】
  1. Googleで認証
  2. IPチェック → 許可範囲内
  3. 即座にログイン完了
  
  【外部からのアクセス】
  1. Googleで認証
  2. IPチェック → 許可範囲外
  3. OTP入力を要求
  4. OTP検証後にログイン完了
```

##### シナリオ3: ユーザー属性の自動更新

```yaml
目的:
  - Googleから最新のユーザー情報を自動的に同期
  - プロフィール画像、名前等を常に最新に保つ
  - 手動更新の手間を削減

カスタムフロー構成:
  Flow Name: "Auto Update User Attributes"
  Executions:
    1. Custom Attribute Updater
       Requirement: REQUIRED
       Settings:
         - Update fields:
           - name
           - given_name
           - family_name
           - picture
         - Sync mode: Force update

カスタムAuthenticator実装:
  public class AttributeUpdater implements Authenticator {
      public void authenticate(AuthenticationFlowContext context) {
          // Identity Providerから取得した情報
          BrokeredIdentityContext idpContext = getBrokeredIdentity(context);
          
          // 既存のKeycloakユーザー
          UserModel user = context.getUser();
          
          // 属性を更新
          user.setFirstName(idpContext.getFirstName());
          user.setLastName(idpContext.getLastName());
          user.setEmail(idpContext.getEmail());
          user.setSingleAttribute("picture", 
              idpContext.getUserAttribute("picture"));
          
          context.success();
      }
  }

設定:
  Post login flow: "Auto Update User Attributes"
  Sync mode: force（併用）

結果:
  - ユーザーがGoogleでプロフィールを更新
  - 次回ログイン時にKeycloakにも自動反映
  - 常に最新の情報がアプリケーションで利用可能
```

##### シナリオ4: 利用規約の再同意

```yaml
目的:
  - 利用規約が更新された際に再同意を要求
  - 法的コンプライアンスの確保
  - GDPR、CCPAへの対応

カスタムフロー構成:
  Flow Name: "Terms Reacceptance Check"
  Executions:
    1. Custom Terms Version Checker
       Requirement: REQUIRED
       Settings:
         - Current terms version: 2.0
       
    2. Terms and Conditions
       Requirement: CONDITIONAL
       Condition: User has not accepted current version

カスタムAuthenticator実装:
  public class TermsVersionChecker implements Authenticator {
      private static final String CURRENT_VERSION = "2.0";
      
      public void authenticate(AuthenticationFlowContext context) {
          UserModel user = context.getUser();
          String acceptedVersion = user.getFirstAttribute("terms_version");
          
          if (CURRENT_VERSION.equals(acceptedVersion)) {
              // 最新版に同意済み
              context.success();
          } else {
              // 再同意が必要
              context.attempted();
          }
      }
  }

設定:
  Post login flow: "Terms Reacceptance Check"

結果:
  【最新版に同意済み】
  1. Googleで認証
  2. 利用規約バージョンチェック → 同意済み
  3. 即座にログイン完了
  
  【未同意または旧バージョン】
  1. Googleで認証
  2. 利用規約バージョンチェック → 同意が必要
  3. 利用規約画面を表示
  4. ユーザーが同意
  5. ユーザー属性にバージョン記録
  6. ログイン完了
```

##### シナリオ5: デバイス登録と信頼

```yaml
目的:
  - 新しいデバイスからのログインを検出
  - 信頼済みデバイスは追加認証不要
  - 未知のデバイスには追加認証を要求

カスタムフロー構成:
  Flow Name: "Device Trust Verification"
  Executions:
    1. Custom Device Fingerprint Checker
       Requirement: REQUIRED
       
    2. OTP Form
       Requirement: CONDITIONAL
       Condition: Unknown device
       
    3. Device Registration
       Requirement: CONDITIONAL
       Condition: OTP successful

カスタムAuthenticator実装:
  public class DeviceFingerprintChecker implements Authenticator {
      public void authenticate(AuthenticationFlowContext context) {
          UserModel user = context.getUser();
          String deviceFingerprint = getDeviceFingerprint(context);
          
          // ユーザーの信頼済みデバイスリストを確認
          List<String> trustedDevices = 
              user.getAttribute("trusted_devices");
          
          if (trustedDevices != null && 
              trustedDevices.contains(deviceFingerprint)) {
              // 信頼済みデバイス
              context.success();
          } else {
              // 新しいデバイス - 追加認証が必要
              context.getAuthenticationSession()
                  .setAuthNote("device_fingerprint", deviceFingerprint);
              context.attempted();
          }
      }
      
      private String getDeviceFingerprint(AuthenticationFlowContext context) {
          // User-Agent, IPアドレス等からフィンガープリントを生成
          HttpRequest request = context.getHttpRequest();
          String userAgent = request.getHttpHeaders()
              .getHeaderString("User-Agent");
          String ip = context.getConnection().getRemoteAddr();
          
          return DigestUtils.sha256Hex(userAgent + ip);
      }
  }
  
  public class DeviceRegistration implements Authenticator {
      public void authenticate(AuthenticationFlowContext context) {
          // OTP検証成功後に実行される
          UserModel user = context.getUser();
          String deviceFingerprint = context.getAuthenticationSession()
              .getAuthNote("device_fingerprint");
          
          // デバイスを信頼済みリストに追加
          user.addAttributeValue("trusted_devices", deviceFingerprint);
          
          context.success();
      }
  }

設定:
  Post login flow: "Device Trust Verification"

結果:
  【信頼済みデバイス】
  1. Googleで認証
  2. デバイスチェック → 既知のデバイス
  3. 即座にログイン完了
  
  【新しいデバイス】
  1. Googleで認証
  2. デバイスチェック → 未知のデバイス
  3. OTP入力を要求
  4. OTP検証成功
  5. デバイスを信頼済みリストに追加
  6. 次回からはOTP不要
  7. ログイン完了
```

##### シナリオ6: 時間ベースのアクセス制御

```yaml
目的:
  - 業務時間外のアクセスを制限
  - または業務時間外は追加認証を要求
  - セキュリティポリシーの実装

カスタムフロー構成:
  Flow Name: "Business Hours Access Control"
  Executions:
    1. Custom Business Hours Checker
       Requirement: REQUIRED
       Settings:
         - Business hours: 09:00-18:00 (JST)
         - Business days: Mon-Fri
       
    2. OTP Form
       Requirement: CONDITIONAL
       Condition: Outside business hours

カスタムAuthenticator実装:
  public class BusinessHoursChecker implements Authenticator {
      public void authenticate(AuthenticationFlowContext context) {
          ZonedDateTime now = ZonedDateTime.now(ZoneId.of("Asia/Tokyo"));
          int hour = now.getHour();
          DayOfWeek day = now.getDayOfWeek();
          
          boolean isBusinessHours = 
              day.getValue() >= 1 && day.getValue() <= 5 &&  // Mon-Fri
              hour >= 9 && hour < 18;  // 09:00-18:00
          
          if (isBusinessHours) {
              // 業務時間内
              context.success();
          } else {
              // 業務時間外 - 追加認証が必要
              context.attempted();
          }
      }
  }

設定:
  Post login flow: "Business Hours Access Control"

結果:
  【業務時間内（平日9:00-18:00）】
  1. Googleで認証
  2. 時間チェック → 業務時間内
  3. 即座にログイン完了
  
  【業務時間外】
  1. Googleで認証
  2. 時間チェック → 業務時間外
  3. OTP入力を要求
  4. OTP検証後にログイン完了
```

**重要な注意事項**

### ⚠️ ユーザーは既にClientSessionに設定済み

ドキュメントに記載されている通り:
> "Also note that authenticator implementations must assume that user is already set in ClientSession as identity provider already set it."

これは非常に重要なポイントです:

```java
// Post login flow内のAuthenticator
public void authenticate(AuthenticationFlowContext context) {
    // ユーザーは既に設定されている
    UserModel user = context.getUser();  // ✅ 必ず存在
    
    if (user == null) {
        // ❌ これは発生しない（First login flowとの違い）
        throw new RuntimeException("User should always be set");
    }
    
    // ユーザー情報を使用してカスタムロジックを実行
    String email = user.getEmail();
    // ...
}
```

**First login flow との違い**:
```java
// First login flow内のAuthenticator
public void authenticate(AuthenticationFlowContext context) {
    // ユーザーはまだ設定されていない可能性がある
    UserModel user = context.getUser();  // null の可能性
    
    if (user == null) {
        // ✅ これは正常（まだユーザーが作成されていない）
        // アカウント作成またはリンクの処理
    }
}
```

**技術的な詳細**

##### Post login flowの実行コンテキスト:

```java
// Keycloak内部での処理フロー
1. Identity Providerから認証成功の応答を受け取る
2. FEDERATED_IDENTITYテーブルでリンクを検索
3. **ユーザーをClientSessionに設定**  ← ここが重要
4. Post login flowを実行（この時点でuserは既に存在）
5. フローが成功すればログイン完了
```

##### ClientSessionとは:
- 認証プロセス中の一時的なセッション情報
- ユーザー、クライアント、認証状態等を保持
- Post login flow開始時には既にユーザーが紐付けられている

**パフォーマンスへの影響**

Post login flowは毎回実行されるため、パフォーマンスへの影響を考慮する必要があります:

| フローの複雑さ | 追加遅延 | 推奨度 |
|-------------|---------|--------|
| なし（デフォルト） | 0ms | ✅ ユーザー体験最優先の場合 |
| シンプル（属性チェックのみ） | <50ms | ✅ ほとんどの場合 |
| 中程度（OTP） | ユーザー入力待ち | ⚠️ セキュリティ要件がある場合 |
| 複雑（複数API呼び出し） | 100-500ms | ❌ 避けるべき |

**最適化のヒント**:
1. **キャッシュの活用**:
   ```java
   // デバイス信頼性チェックの結果をキャッシュ
   CacheManager cache = session.getProvider(CacheManager.class);
   String cacheKey = "device_trust:" + user.getId() + ":" + deviceId;
   Boolean isTrusted = cache.get(cacheKey, Boolean.class);
   
   if (isTrusted == null) {
       isTrusted = checkDeviceTrust(user, deviceId);
       cache.put(cacheKey, isTrusted, 3600);  // 1時間キャッシュ
   }
   ```

2. **非同期処理**:
   ```java
   // ログイン完了後にバックグラウンドで処理
   context.getAuthenticationSession()
       .setAuthNote("pending_sync", "true");
   
   // 別のタスクで属性を更新
   ```

3. **条件付き実行**:
   ```java
   // 特定の条件下でのみ重い処理を実行
   if (needsExpensiveCheck(user)) {
       performExpensiveCheck();
   }
   ```

**デバッグとトラブルシューティング**

##### 問題: Post login flowが実行されない

**確認事項**:
1. Post login flowが正しく設定されているか
2. フロー名のスペルミスがないか
3. ユーザーがIdentity Providerを使用してログインしているか（パスワードログインではPost login flowは実行されない）

**ログで確認**:
```
tail -f /var/log/keycloak/server.log | grep "Post Broker Login"
```

##### 問題: OTPが毎回要求される（記憶されない）

**原因**:
- OTPの「Remember Me」機能が無効
- またはクッキーが適切に設定されていない

**解決策**:
```
OTP Policy設定で:
- OTP Remember Me: 有効
- Remember Me Duration: 30日

ブラウザクッキー設定:
- SameSite属性を適切に設定
- Secure フラグを確認
```

##### 問題: パフォーマンスが悪い

**診断**:
```java
// タイミング測定を追加
long startTime = System.currentTimeMillis();

// カスタムロジック
performCustomLogic();

long duration = System.currentTimeMillis() - startTime;
logger.info("Post login flow execution time: " + duration + "ms");
```

**解決策**:
- 重い処理を削除または最適化
- キャッシュを活用
- 非同期処理に変更

**セキュリティ上の考慮事項**

1. **バイパス攻撃の防止**:
   ```java
   // Post login flowが必須であることを確認
   // ユーザーが直接トークンエンドポイントにアクセスすることを防ぐ
   @Override
   public boolean requiresUser() {
       return true;  // ユーザーが必須
   }
   ```

2. **セッションハイジャック**:
    - Post login flow完了後、セッションIDを再生成
    - CSRF保護を適用

3. **ブルートフォース攻撃**:
    - OTPの試行回数制限
    - アカウントロックアウトポリシー

4. **情報漏洩**:
    - エラーメッセージで詳細情報を漏らさない
    - ログに機密情報を記録しない

**他の機能との組み合わせ**

##### Post login flow + Required Actions:

```yaml
シナリオ:
  - Post login flowで基本的なチェック
  - Required Actionsで複雑な処理

Post login flow:
  - OTP検証（毎回）
  
Required Actions:
  - UPDATE_PASSWORD（初回のみ）
  - UPDATE_PROFILE（初回のみ）
  - TERMS_AND_CONDITIONS（バージョン更新時）

メリット:
  - 役割分担が明確
  - Keycloakの標準機能を活用
```

##### Post login flow + Sync mode:

```yaml
Post login flow: "Update Attributes"
Sync mode: force

効果:
  - Sync modeでマッパーが属性を更新
  - Post login flowで追加の処理
  - 相互補完的に機能
```

**ベストプラクティス**

1. **最小限の処理**:
    - 毎回実行されるため、軽量に保つ
    - 重い処理は避ける
    - 必要な場合はキャッシュを活用

2. **ユーザー体験を損なわない**:
    - 追加の認証は本当に必要な場合のみ
    - 条件付き実行を活用
    - 「Remember Me」オプションを提供

3. **明確なフィードバック**:
    - ユーザーに何が起きているか説明
    - 進捗インジケーターを表示
    - エラーメッセージは具体的に

4. **段階的な展開**:
    - 最初は監視のみ（ログ記録）
    - 問題なければ実際の制御を有効化
    - ロールバック計画を用意

5. **監視とメトリクス**:
    - Post login flowの実行時間を追跡
    - 失敗率をモニター
    - ユーザーフィードバックを収集

**まとめ**

Post login flowは、Identity Providerでのログイン後に追加の認証や検証を行うための強力な機能です:

✅ **主な用途**:
- 二要素認証（OTP）の追加
- 条件付きアクセス制御
- ユーザー属性の自動更新
- デバイス信頼性の検証
- 時間ベースのアクセス制御

⚠️ **重要な注意点**:
- 毎回実行されるためパフォーマンスへの影響を考慮
- ユーザーは既にClientSessionに設定済み
- ユーザー体験とセキュリティのバランスが重要
- 十分なテストが必須

---

## Sync mode（同期モード）

**概要**
- Identity Providerから取得したユーザー情報をKeycloakのユーザーデータにどのように同期するかを制御する設定です。

**詳細説明**
- Identity Provider Mappers（属性マッピング設定）がユーザーデータをいつ、どのように更新するかを決定します。
- すべてのマッパーに適用されるデフォルトの同期動作を設定します（個々のマッパーで上書き可能）。

**Identity Provider Mappersとは**

マッパーは、Identity Providerから取得した属性（クレーム）をKeycloakのユーザー属性にマッピングするための設定です:

```
Googleからの情報:
{
  "sub": "110169484474386276334",
  "email": "john@company.com",
  "given_name": "John",
  "family_name": "Doe",
  "picture": "https://lh3.googleusercontent.com/..."
}

↓ マッパーで変換

Keycloakユーザー属性:
{
  "username": "john@company.com",
  "email": "john@company.com",
  "firstName": "John",
  "lastName": "Doe",
  "attributes": {
    "profile_picture": "https://lh3.googleusercontent.com/..."
  }
}
```

**Sync modeの選択肢と詳細**

### 1. `legacy`（レガシー）

**説明**:
- この設定が導入される前の動作を維持します。
- 後方互換性のために提供されています。

**動作**:
```
初回ログイン時: ✅ マッパーが実行される
2回目以降: ✅ マッパーが実行される（常に更新）
```

**特徴**:
- すべてのログインでユーザー属性が更新される
- Identity Providerの情報が常に優先される
- ユーザーがKeycloak側で属性を編集しても、次回ログイン時に上書きされる

**使用シナリオ**:
- 既存のシステムからアップグレードする場合
- 動作を変更したくない場合
- 後方互換性が必要な場合

**例**:
```yaml
シナリオ:
  - ユーザーがKeycloak のAccount Consoleで名前を変更
  - 次回Googleでログイン
  - 名前がGoogleの情報で上書きされる

初回ログイン:
  Google: John Doe
  → Keycloak: John Doe ✅

ユーザーが編集:
  Keycloak: John Smith（ユーザーが変更）

次回ログイン:
  Google: John Doe
  → Keycloak: John Doe（上書き） ⚠️
```

---

### 2. `import`（インポート）

**説明**:
- ユーザーの初回ログイン時にのみ属性をインポートします。
- 以降のログインでは属性を更新しません。

**動作**:
```
初回ログイン時: ✅ マッパーが実行される
2回目以降: ❌ マッパーは実行されない
```

**特徴**:
- Identity Providerの情報は初回のみ使用される
- ユーザーがKeycloak側で属性を編集すると、その変更が保持される
- Identity Provider側で情報が更新されても、Keycloak側には反映されない

**使用シナリオ**:
- ユーザーに自分の情報を管理させたい
- Identity Providerは初期値の提供のみ
- ユーザーの編集を尊重する

**例**:
```yaml
初回ログイン:
  Google: John Doe, john@company.com
  → Keycloak: John Doe, john@company.com ✅

ユーザーが編集:
  Keycloak: John Smith（ユーザーが変更）

次回ログイン:
  Google: John Doe（Googleでは変更なし）
  → Keycloak: John Smith（変更が保持される） ✅

Googleで名前変更:
  Google: Jonathan Doe（Googleで変更）
  
次回ログイン:
  Google: Jonathan Doe
  → Keycloak: John Smith（更新されない） ⚠️
```

**メリット**:
- ユーザーの自律性を尊重
- ユーザーが意図的に変更した情報が失われない
- 予期しない上書きを防ぐ

**デメリット**:
- Identity Provider側の更新が反映されない
- データの不整合が発生する可能性
- 管理者が更新を強制できない（手動更新が必要）

---

### 3. `force`（強制）

**説明**:
- すべてのログイン時に属性を強制的に更新します。
- Identity Providerの情報が常に優先されます。

**動作**:
```
初回ログイン時: ✅ マッパーが実行される
2回目以降: ✅ マッパーが毎回実行される（強制更新）
```

**特徴**:
- Identity Providerが唯一の情報源（Single Source of Truth）
- ユーザーがKeycloak側で編集しても、次回ログイン時に上書きされる
- 常に最新の情報がKeycloakに反映される

**使用シナリオ**:
- Identity Providerの情報を絶対的な情報源として扱う
- ユーザーによる編集を許可しない
- Google Workspace等の企業ディレクトリが正となる場合

**例**:
```yaml
初回ログイン:
  Google: John Doe, Engineering
  → Keycloak: John Doe, Engineering ✅

ユーザーが編集:
  Keycloak: John Smith, Sales（ユーザーが変更）

次回ログイン:
  Google: John Doe, Engineering
  → Keycloak: John Doe, Engineering（強制上書き） ✅

Googleで異動:
  Google: John Doe, Marketing（Googleで更新）

次回ログイン:
  Google: John Doe, Marketing
  → Keycloak: John Doe, Marketing（自動更新） ✅
```

**メリット**:
- データの一貫性が保証される
- Identity Providerの情報が常に正確に反映される
- 管理者による一元管理が可能

**デメリット**:
- ユーザーの編集が無意味になる
- ユーザーが混乱する可能性（変更が保存されない）
- Identity Provider側の誤った情報も強制的に反映される

---

**Sync modeの比較表**

| モード | 初回ログイン | 2回目以降 | ユーザー編集 | IdP更新の反映 | 推奨用途 |
|--------|------------|---------|------------|-------------|---------|
| **legacy** | 更新 | 更新 | ❌ 上書きされる | ✅ 即座に反映 | 後方互換性 |
| **import** | 更新 | **更新しない** | ✅ 保持される | ❌ 反映されない | ユーザー自律性重視 |
| **force** | 更新 | **強制更新** | ❌ 上書きされる | ✅ 即座に反映 | IdPが唯一の情報源 |

**各モードの使用シナリオ詳細**

### Import（インポート）を使用すべき場合

##### シナリオ1: B2Cアプリケーション
```yaml
状況:
  - 一般消費者向けアプリケーション
  - ユーザーが自分の情報を管理
  - Googleは初期登録の簡略化のみ

設定:
  Sync mode: import

理由:
  - ユーザーがプロフィールを自由にカスタマイズ
  - ニックネーム、表示名等の個人的な設定を尊重
  - Googleの情報はあくまで初期値

例:
  1. ユーザーがGoogleで登録（"Robert Johnson"）
  2. アプリ内で表示名を"Rob"に変更
  3. 次回ログイン時も"Rob"が保持される
```

##### シナリオ2: マルチテナントプラットフォーム
```yaml
状況:
  - 複数の企業が同じプラットフォームを使用
  - 各企業が独自のユーザー情報を管理
  - Googleは認証のみに使用

設定:
  Sync mode: import

理由:
  - テナント管理者がユーザー情報を管理
  - Google側の変更が他のテナントに影響しない
  - 独立したユーザーデータベースを維持
```

##### シナリオ3: 教育機関
```yaml
状況:
  - 学生が入学時にGoogleアカウントで登録
  - 学内でのニックネームやプロフィールを設定
  - 卒業後もアカウントを保持

設定:
  Sync mode: import

理由:
  - 学生の個性を尊重
  - キャンパス内での通称を使用可能
  - 卒業後もアイデンティティを維持
```

---

### Force（強制）を使用すべき場合

##### シナリオ1: 企業内部システム
```yaml
状況:
  - Google Workspaceを人事システムと統合
  - 人事異動、部署変更等が頻繁
  - 従業員情報の正確性が重要

設定:
  Sync mode: force
  マッパー:
    - email → email
    - given_name → firstName
    - family_name → lastName
    - hd → organization
    - custom:department → department

理由:
  - Googleが唯一の正しい情報源
  - 人事異動が即座に反映される
  - ユーザーが不正確な情報を設定することを防ぐ

例:
  1. John Doeが営業部から開発部に異動
  2. 管理者がGoogle Workspaceで部署を更新
  3. Johnが次回ログイン
  4. Keycloakの部署情報が自動的に更新される
  5. アプリケーションで正しい権限が適用される
```

##### シナリオ2: コンプライアンス要件
```yaml
状況:
  - 金融機関、医療機関等
  - 監査証跡が必要
  - すべての情報が公式記録と一致する必要

設定:
  Sync mode: force

理由:
  - データの整合性が法的要件
  - ユーザーによる不正な情報変更を防ぐ
  - 監査時に情報源が明確
```

##### シナリオ3: B2Bエンタープライズアプリケーション
```yaml
状況:
  - 顧客企業のGoogle Workspaceと統合
  - 企業管理者が従業員情報を管理
  - 従業員の役割と権限が重要

設定:
  Sync mode: force
  マッパー:
    - custom:role → role
    - custom:cost_center → cost_center
    - custom:manager → manager_email

理由:
  - 企業の組織構造を正確に反映
  - 役割ベースのアクセス制御（RBAC）の基盤
  - セキュリティポリシーの一貫性
```

---

### Legacy（レガシー）を使用すべき場合

##### シナリオ1: 既存システムのアップグレード
```yaml
状況:
  - 古いバージョンのKeycloakから移行
  - 既存の動作を変更したくない
  - 段階的な移行を実施中

設定:
  Sync mode: legacy

理由:
  - 既存のユーザーへの影響を最小限に
  - 動作変更によるトラブルを避ける
  - 移行完了後に import または force に変更
```

##### シナリオ2: 特別な要件なし
```yaml
状況:
  - 特に厳格な要件がない
  - デフォルトの動作で問題ない

設定:
  Sync mode: legacy（または未設定）

理由:
  - シンプルさを優先
  - 特別な同期ロジックが不要
```

---

**個々のマッパーでのSync mode上書き**

Sync modeはIdentity Provider全体のデフォルト設定ですが、個々のマッパーで上書きできます:

```yaml
Identity Provider設定:
  Sync mode: import（デフォルト）

マッパー1（Email）:
  Sync mode override: force
  理由: メールアドレスは常に最新に保つ

マッパー2（First Name）:
  Sync mode override: （上書きなし、デフォルトのimportを使用）
  理由: ユーザーが編集した名前を尊重

マッパー3（Profile Picture）:
  Sync mode override: force
  理由: Googleのプロフィール画像を常に使用

結果:
  - メールアドレス: 毎回更新（force）
  - 名前: 初回のみ（import）
  - プロフィール画像: 毎回更新（force）
```

**設定例**

Admin Consoleでの設定:
```
Identity Providers → Google → Mappers

例: Email マッパー
  Name: email
  Mapper Type: Attribute Importer
  Claim: email
  User Attribute Name: email
  Sync Mode Override: force  ← 個別設定
```

**実際の使用例**

##### 例1: ハイブリッドアプローチ（推奨）

```yaml
Identity Provider全体:
  Sync mode: import（ユーザーの編集を尊重）

個別マッパー:
  Email:
    Sync mode: force
    理由: 企業メールは常に正確に
  
  Profile Picture:
    Sync mode: force
    理由: Googleの画像を使用
  
  First Name:
    Sync mode: import
    理由: ユーザーのニックネームを許可
  
  Last Name:
    Sync mode: import
    理由: 同上
  
  Department:
    Sync mode: force
    理由: 組織構造の正確性

結果:
  - 重要な情報（メール、部署）は常に最新
  - 個人的な設定（名前）はユーザーが管理
  - バランスの取れたアプローチ
```

##### 例2: 完全な自律性

```yaml
Identity Provider全体:
  Sync mode: import

すべてのマッパー:
  Sync mode override: （なし）

結果:
  - すべての属性が初回のみインポート
  - ユーザーが完全に管理
  - Identity Providerは認証のみに使用
```

##### 例3: 完全な同期

```yaml
Identity Provider全体:
  Sync mode: force

すべてのマッパー:
  Sync mode override: （なし）

結果:
  - すべての属性が毎回更新
  - Identity Providerが唯一の情報源
  - ユーザーの編集は不可
```

**Sync modeとPost login flowの組み合わせ**

Sync modeとPost login flowを組み合わせることで、より細かい制御が可能です:

```yaml
設定:
  Sync mode: import
  Post login flow: "Conditional Attribute Update"

Post login flow実装:
  public class ConditionalAttributeUpdater implements Authenticator {
      public void authenticate(AuthenticationFlowContext context) {
          UserModel user = context.getUser();
          BrokeredIdentityContext idpContext = getBrokeredIdentity(context);
          
          // 特定の条件下でのみ属性を更新
          if (shouldUpdateAttributes(user)) {
              user.setEmail(idpContext.getEmail());
              user.setFirstName(idpContext.getFirstName());
              // ...
          }
          
          context.success();
      }
      
      private boolean shouldUpdateAttributes(UserModel user) {
          // 例: 30日以上更新されていない場合
          String lastSync = user.getFirstAttribute("last_sync");
          if (lastSync == null) return true;
          
          long lastSyncTime = Long.parseLong(lastSync);
          long now = System.currentTimeMillis();
          long daysSinceLastSync = (now - lastSyncTime) / (1000 * 60 * 60 * 24);
          
          return daysSinceLastSync > 30;
      }
  }

効果:
  - 通常はimportモード（ユーザーの編集を尊重）
  - 30日ごとに自動的に同期
  - バランスの取れたアプローチ
```

**トラブルシューティング**

##### 問題: 属性が更新されない

**原因**:
- Sync modeが`import`で、既に初回ログイン済み
- マッパーが無効になっている
- マッパーの設定が不正確

**解決策**:
1. Sync modeを`force`に変更（一時的に）
2. ユーザーを削除して再作成
3. 手動で属性を更新

##### 問題: ユーザーの編集が失われる

**原因**:
- Sync modeが`force`または`legacy`
- ユーザーの編集が次回ログイン時に上書きされる

**解決策**:
1. Sync modeを`import`に変更
2. または、編集を許可しない旨をユーザーに通知

##### 問題: データの不整合

**原因**:
- Sync modeが`import`で、Identity Provider側の変更が反映されない
- 組織の変更（部署異動等）が反映されていない

**解決策**:
1. 重要な属性のみ`force`に設定
2. 定期的な手動同期を実施
3. Post login flowで条件付き更新を実装

**ベストプラクティス**

1. **要件に応じた選択**:
   ```
   B2C: import（ユーザー自律性）
   B2B企業: force（組織管理）
   混在: ハイブリッド（属性ごとに設定）
   ```

2. **ハイブリッドアプローチ**:
    - デフォルトは`import`
    - 重要な属性のみ個別に`force`
    - バランスの取れた設定

3. **明確なコミュニケーション**:
    - ユーザーにどの情報が編集可能か説明
    - 編集不可の項目は UI で無効化
    - ヘルプドキュメントを提供

4. **段階的な展開**:
    - 最初は`import`で開始
    - ユーザーフィードバックを収集
    - 必要に応じて`force`に変更

5. **監視とログ**:
    - 属性更新をログに記録
    - データの不整合を検出
    - 定期的にレビュー

**まとめ**

Sync modeは、Identity Providerとの属性同期を制御する重要な設定です:

- **import**: ユーザーの自律性を尊重、初回のみ同期
- **force**: Identity Providerを唯一の情報源として扱う、常に同期
- **legacy**: 後方互換性のため、常に同期（旧動作）

適切なSync modeの選択は、アプリケーションの性質、セキュリティ要件、ユーザー体験のバランスによって決まります。

---

## Case-sensitive username（大文字小文字を区別するユーザー名）

**概要**
- Identity Providerから取得したユーザー名の大文字小文字をそのまま保持するか、小文字に正規化するかを制御する設定です。

**詳細説明**
- 有効にすると、Identity Providerから返されたユーザー名がそのままの形式（大文字小文字を含む）でKeycloakに保存されます。
- 無効の場合、ユーザー名は自動的に小文字に変換されます。
- **重要**: この設定はフェデレーテッドアイデンティティに関連付けられたユーザー名のみに影響し、Keycloakサーバー内のユーザー名は常に小文字で保存されます。

**Keycloakにおけるユーザー名の扱い**

Keycloakには2種類の「ユーザー名」の概念があります:

### 1. Keycloakユーザー名（username）
```
- データベースのUSER_ENTITYテーブルに保存
- **常に小文字**で保存される
- Keycloakの内部識別子として使用
- この設定の影響を受けない
```

### 2. フェデレーテッドユーザー名（federated username）
```
- データベースのFEDERATED_IDENTITYテーブルに保存
- Identity Providerから取得した元のユーザー名
- **この設定の影響を受ける**
- リンク情報として使用
```

**動作の詳細**

#### 無効の場合（デフォルト）

```yaml
Google認証:
  sub: "110169484474386276334"
  email: "John.Doe@Company.com"

Keycloakでの保存:
  USER_ENTITY.username: "john.doe@company.com"  ← 小文字
  
  FEDERATED_IDENTITY.federated_username: "john.doe@company.com"  ← 小文字に正規化
  FEDERATED_IDENTITY.federated_user_id: "110169484474386276334"
  FEDERATED_IDENTITY.identity_provider: "google"

特徴:
  - 大文字小文字の違いを無視
  - "John.Doe@Company.com" も "john.doe@company.com" も同じユーザーとして扱われる
  - 一貫性が保証される
```

#### 有効の場合

```yaml
Google認証:
  sub: "110169484474386276334"
  email: "John.Doe@Company.com"

Keycloakでの保存:
  USER_ENTITY.username: "john.doe@company.com"  ← 依然として小文字
  
  FEDERATED_IDENTITY.federated_username: "John.Doe@Company.com"  ← **元のまま保持**
  FEDERATED_IDENTITY.federated_user_id: "110169484474386276334"
  FEDERATED_IDENTITY.identity_provider: "google"

特徴:
  - Identity Providerからの元の形式を保持
  - 表示時に元の大文字小文字を使用可能
  - ただし、Keycloak内部では依然として小文字で処理
```

**実際の影響範囲**

この設定が影響するのは、以下の場面に限定されます:

### 1. フェデレーテッドアイデンティティの表示

```yaml
Account Console → Linked accounts:
  
Case-sensitive: 無効
  表示: "john.doe@company.com"

Case-sensitive: 有効
  表示: "John.Doe@Company.com"  ← 元の形式
```

### 2. トークン交換時の情報

```json
Token Exchange APIレスポンス:

Case-sensitive: 無効
{
  "federated_identity": {
    "provider": "google",
    "username": "john.doe@company.com"
  }
}

Case-sensitive: 有効
{
  "federated_identity": {
    "provider": "google",
    "username": "John.Doe@Company.com"
  }
}
```

### 3. Admin Consoleでの表示

```yaml
Admin Console → Users → [User] → Identity Provider Links:

Case-sensitive: 無効
  Federated Username: john.doe@company.com

Case-sensitive: 有効
  Federated Username: John.Doe@Company.com
```

**影響を受けない項目**
```yaml
以下の項目はこの設定の影響を受けません（常に小文字）:

1. Keycloakのユーザー名（USER_ENTITY.username）
   → 常に小文字で保存

2. ログイン時のユーザー名入力
   → 大文字小文字を区別せず認証

3. ユーザー検索
   → 大文字小文字を区別しない

4. API呼び出し
   → username パラメータは常に小文字として扱われる

5. ユーザー一覧表示
   → Keycloakのusernameが表示される（小文字）
```

**使用シナリオ**

##### シナリオ1: 元の形式を保持したい場合

```yaml
状況:
  - ユーザーがGoogleで "John.Doe@Company.com" として登録
  - 表示時に元の形式を保ちたい
  - ブランディングやユーザー体験の観点

設定:
  Case-sensitive username: 有効

効果:
  - Account Consoleで "John.Doe@Company.com" と表示
  - ユーザーが自分のアカウントを識別しやすい
  - プロフェッショナルな印象

例:
  Google Workspace:
    - John.Doe@Company.com（社員番号を含む形式等）
  
  Keycloak Account Console:
    - Linked Google Account: John.Doe@Company.com
    - ユーザーが認識しやすい
```

##### シナリオ2: 一貫性を重視する場合（デフォルト）

```yaml
状況:
  - システム全体で小文字に統一したい
  - 大文字小文字の違いによる混乱を避けたい
  - シンプルさを優先

設定:
  Case-sensitive username: 無効（デフォルト）

効果:
  - すべてが小文字で統一される
  - "John.Doe@Company.com" も "john.doe@company.com" として表示
  - 一貫したユーザーエクスペリエンス

例:
  Google: John.Doe@Company.com
  Keycloak: john.doe@company.com（すべて小文字）
  
  メリット:
    - データベースクエリが簡単
    - 重複の心配なし
    - 標準化された表示
```

##### シナリオ3: 複数のIdentity Providerを使用

```yaml
状況:
  - Google、Microsoft、SAML等を併用
  - 各プロバイダーで大文字小文字の扱いが異なる
  - 一貫性が重要

設定:
  Case-sensitive username: 無効

理由:
  - すべてのプロバイダーで統一された動作
  - プロバイダー間での違いを気にしなくて良い
  - シンプルな管理

例:
  Google: John.Doe@company.com
  Microsoft: john.doe@company.com
  SAML: JOHN.DOE@COMPANY.COM
  
  Keycloakでは全て: john.doe@company.com
  → 同じユーザーとして認識
```

**技術的な詳細**

### データベーススキーマ

```sql
-- USER_ENTITY テーブル
CREATE TABLE USER_ENTITY (
    ID VARCHAR(36) PRIMARY KEY,
    USERNAME VARCHAR(255) NOT NULL,  -- 常に小文字
    EMAIL VARCHAR(255),
    -- ...
);

-- FEDERATED_IDENTITY テーブル
CREATE TABLE FEDERATED_IDENTITY (
    IDENTITY_PROVIDER VARCHAR(255) NOT NULL,
    REALM_ID VARCHAR(36) NOT NULL,
    FEDERATED_USER_ID VARCHAR(255) NOT NULL,
    FEDERATED_USERNAME VARCHAR(255),  -- この設定の影響を受ける
    TOKEN TEXT,
    USER_ID VARCHAR(36) NOT NULL,
    -- ...
    PRIMARY KEY (IDENTITY_PROVIDER, FEDERATED_USER_ID, USER_ID)
);
```

### ユーザー作成時の処理フロー

```java
// Keycloak内部処理の簡略化された例

// 1. Identity Providerから情報を取得
BrokeredIdentityContext identity = getBrokeredIdentity();
String originalUsername = identity.getUsername();  // "John.Doe@Company.com"

// 2. Keycloakユーザー名を生成（常に小文字）
String keycloakUsername = originalUsername.toLowerCase();  // "john.doe@company.com"

// 3. ユーザーを作成
UserModel user = session.users().addUser(realm, keycloakUsername);

// 4. フェデレーテッドアイデンティティを保存
String federatedUsername;
if (isCaseSensitiveUsername()) {
    federatedUsername = originalUsername;  // "John.Doe@Company.com"（設定: 有効）
} else {
    federatedUsername = keycloakUsername;  // "john.doe@company.com"（設定: 無効）
}

FederatedIdentityModel federatedIdentity = new FederatedIdentityModel(
    identityProvider.getAlias(),
    identity.getId(),
    federatedUsername,  // この値が設定により変わる
    token
);

session.users().addFederatedIdentity(realm, user, federatedIdentity);
```

### ユーザー認証時の処理

```java
// ログイン時の処理

// 1. Identity Providerから情報を取得
String googleUserId = "110169484474386276334";

// 2. フェデレーテッドアイデンティティを検索
FederatedIdentityModel federatedIdentity = 
    session.users().getFederatedIdentity(realm, user, "google");

// 3. 比較（googleUserIdで比較、usernameは使用しない）
if (federatedIdentity.getUserId().equals(googleUserId)) {
    // 認証成功
}

// 注意: federated_usernameは表示用のみで、認証には使用されない
// 実際の照合はfederated_user_id（Googleのsub claim）で行われる
```

**重要な注意点**

### 1. この設定は識別には影響しない

```yaml
重要:
  - フェデレーテッドアイデンティティの識別はfederated_user_id（Googleのsub）で行われる
  - federated_usernameは表示用のメタデータに過ぎない
  - 大文字小文字の違いでユーザーが重複することはない

例:
  Case-sensitive: 有効
  
  初回ログイン:
    Google: "John.Doe@Company.com" (sub: "12345")
    → 新しいユーザー作成
  
  2回目（メールアドレスの大文字小文字を変更）:
    Google: "john.doe@company.com" (sub: "12345")
    → **同じユーザーとして認識**（subが一致）
    → federated_usernameのみ更新される可能性（Sync modeによる）
```

### 2. Keycloakユーザー名は常に小文字

```yaml
誤解しやすい点:
  
  ✗ 間違った理解:
    Case-sensitive: 有効
    → Keycloakのユーザー名も大文字小文字を保持
  
  ✓ 正しい理解:
    Case-sensitive: 有効
    → フェデレーテッドアイデンティティのusernameのみ保持
    → Keycloakのユーザー名は依然として小文字

実例:
  Google: "John.Doe@Company.com"
  
  Keycloak USER_ENTITY:
    username: "john.doe@company.com"  ← 常に小文字
  
  Keycloak FEDERATED_IDENTITY:
    federated_username: "John.Doe@Company.com"  ← 設定により保持
```

### 3. ログイン時の影響なし

```yaml
ログイン動作:
  - ユーザーがログイン画面でユーザー名を入力する場合
  - 大文字小文字は区別されない（この設定に関係なく）
  
例:
  ユーザーが入力:
    - "john.doe@company.com"
    - "John.Doe@Company.com"
    - "JOHN.DOE@COMPANY.COM"
  
  すべて同じユーザーとしてログイン成功
  （Keycloakは内部的に小文字に変換して比較）
```

**トラブルシューティング**

##### 問題: ユーザー名が期待した形式で表示されない

**シナリオ1**: 有効にしたのに小文字で表示される

**原因**:
- 設定前に作成されたユーザー
- 既存のFEDERATED_IDENTITYレコードは更新されない

**解決策**:
```sql
-- オプション1: データベースを直接更新（非推奨、バックアップ必須）
UPDATE FEDERATED_IDENTITY
SET FEDERATED_USERNAME = 'John.Doe@Company.com'
WHERE FEDERATED_USER_ID = '110169484474386276334'
  AND IDENTITY_PROVIDER = 'google';

-- オプション2: ユーザーを削除して再作成
-- Admin Console → Users → [User] → Delete
-- ユーザーが再度ログインすると新しい設定で作成される

-- オプション3: リンクを解除して再リンク
-- Account Console → Linked accounts → Unlink → Link again
```

**シナリオ2**: 無効にしたのに大文字小文字が保持されている

**原因**:
- 既存のレコードは更新されない
- 新規ログイン時のみ新しい設定が適用される

**解決策**:
- 同上

##### 問題: 複数のユーザーが作成される

**シナリオ**: "John.Doe@Company.com" と "john.doe@company.com" で別々のユーザーができる

**原因**:
- これは発生しないはず（設計上）
- もし発生した場合、Identity Providerのsubが異なる

**確認**:
```sql
-- 重複ユーザーを確認
SELECT 
    u.USERNAME,
    fi.FEDERATED_USERNAME,
    fi.FEDERATED_USER_ID,
    fi.IDENTITY_PROVIDER
FROM USER_ENTITY u
JOIN FEDERATED_IDENTITY fi ON u.ID = fi.USER_ID
WHERE LOWER(fi.FEDERATED_USERNAME) = 'john.doe@company.com'
ORDER BY fi.FEDERATED_USER_ID;

-- federated_user_idが異なる場合、実際に別のGoogleアカウント
```

**解決策**:
- Identity Providerで同じアカウントか確認
- 必要に応じてアカウントをマージ（手動）

##### 問題: API呼び出しで期待した値が返らない

**シナリオ**:
```javascript
// APIでユーザー情報を取得
GET /admin/realms/{realm}/users/{userId}

// レスポンス
{
  "username": "john.doe@company.com",  // 常に小文字
  "federatedIdentities": [{
    "identityProvider": "google",
    "userId": "110169484474386276334",
    "userName": "John.Doe@Company.com"  // 設定による
  }]
}
```

**解決**:
- `username`フィールドは常に小文字
- `federatedIdentities[].userName`を使用して元の形式を取得

**セキュリティ上の考慮事項**

### 1. 大文字小文字によるなりすまし攻撃

```yaml
攻撃シナリオ:
  1. 正規ユーザー: john.doe@company.com
  2. 攻撃者が登録: John.Doe@Company.com（別のGoogleアカウント）
  3. ユーザーが混同？

実際の動作:
  - Keycloakは両方を異なるユーザーとして扱う
  - subが異なるため、正しく識別される
  - この設定による追加のリスクはない
  
理由:
  - 識別はsubで行われる（usernameではない）
  - federated_usernameは表示用のみ
```

### 2. ログの可読性

```yaml
Case-sensitive: 有効の場合
  - ログに元の形式が記録される
  - 監査証跡として有用
  - ユーザーを特定しやすい

例:
  2025-11-01 10:30:45 INFO User 'John.Doe@Company.com' 
                            linked to Identity Provider 'google'
```

### 3. データベースの一貫性

```yaml
Case-sensitive: 無効の場合
  - すべて小文字で統一
  - クエリが簡単
  - インデックスの効率が良い

Case-sensitive: 有効の場合
  - 表示用と内部用で異なる
  - 多少の複雑さが増す
  - パフォーマンスへの影響は最小限
```

**パフォーマンスへの影響**

```yaml
影響: ほぼなし

理由:
  - フェデレーテッドアイデンティティの検索はfederated_user_idで行われる
  - federated_usernameはインデックスされていない（通常）
  - 表示時のみ使用されるため、パフォーマンスへの影響は無視できる

測定例:
  Case-sensitive: 無効
    - ユーザー作成: 50ms
    - ログイン: 100ms
  
  Case-sensitive: 有効
    - ユーザー作成: 50ms（変化なし）
    - ログイン: 100ms（変化なし）
```

**他の機能との相互作用**

### 1. Username Mapper との関係

```yaml
シナリオ:
  Identity Provider設定:
    Case-sensitive username: 有効
  
  Username Mapper:
    Template: ${ALIAS}-${CLAIM.email}
    Target: USERNAME

動作:
  Google email: John.Doe@Company.com
  
  生成されるKeycloakユーザー名:
    username: "google-john.doe@company.com"  ← 小文字化される
  
  フェデレーテッドユーザー名:
    federated_username: "John.Doe@Company.com"  ← 元のまま

結論:
  - Case-sensitive設定はフェデレーテッドユーザー名のみに影響
  - マッパーで生成されるKeycloakユーザー名は依然として小文字
```

### 2. User Attribute Mapper との関係

```yaml
Attribute Mapper:
  Claim: email
  User Attribute: google_email
  
動作:
  Google email: John.Doe@Company.com
  
  ユーザー属性:
    google_email: "John.Doe@Company.com"  ← マッパーの動作による
  
  Keycloakユーザー名:
    username: "john.doe@company.com"  ← 依然として小文字
  
  フェデレーテッドユーザー名:
    federated_username: "John.Doe@Company.com" or "john.doe@company.com"
                         ← Case-sensitive設定による
```

### 3. Account Linking との関係

```yaml
既存ユーザー:
  username: "john.doe@company.com"（ローカルアカウント）

Googleアカウントをリンク:
  email: "John.Doe@Company.com"

Case-sensitive: 有効
  federated_username: "John.Doe@Company.com"
  → リンク成功、元の形式が保存される

Case-sensitive: 無効
  federated_username: "john.doe@company.com"
  → リンク成功、小文字に正規化される

どちらの場合も:
  - リンクは正常に機能
  - 同じユーザーとして認識される
```

**ベストプラクティス**

### 1. デフォルトのままにする（推奨）

```yaml
推奨設定:
  Case-sensitive username: 無効（デフォルト）

理由:
  - シンプルさを保つ
  - 一貫性が保証される
  - ほとんどの場合、特別な理由がない限り変更不要
  - Identity Providerの識別はsubで行われるため、usernameの形式は重要でない
```

### 2. 有効にする場合の判断基準

```yaml
有効にすべき場合:
  ✓ ユーザーが元の形式を期待している
  ✓ ブランディング上の理由（企業の命名規則等）
  ✓ 監査やログで元の形式が必要
  ✓ ユーザー体験の向上が重要

有効にしなくて良い場合:
  ✓ 一貫性を重視
  ✓ シンプルさを優先
  ✓ 大文字小文字に特別な意味がない
  ✓ 技術的な複雑さを避けたい
```

### 3. 移行時の注意

```yaml
既存システムがある場合:
  
ステップ1: 現状確認
  - 既存のfederated_usernameを確認
  - ユーザー数を確認

ステップ2: 影響評価
  - 変更による影響を評価
  - ユーザーへの通知が必要か判断

ステップ3: 段階的な移行
  - まずテスト環境で検証
  - 一部のユーザーで試験
  - 問題なければ全体に展開

ステップ4: ドキュメント化
  - 設定変更を記録
  - ユーザーへの説明を用意
```

### 4. 監視と保守

```yaml
定期的な確認:
  - フェデレーテッドアイデンティティの整合性チェック
  - 重複ユーザーの確認
  - ログの監視

クエリ例:
  -- フェデレーテッドユーザー名の分布を確認
  SELECT 
      IDENTITY_PROVIDER,
      COUNT(*) as count,
      COUNT(DISTINCT LOWER(FEDERATED_USERNAME)) as unique_lowercase
  FROM FEDERATED_IDENTITY
  GROUP BY IDENTITY_PROVIDER;
  
  -- 大文字を含むユーザー名を確認
  SELECT FEDERATED_USERNAME
  FROM FEDERATED_IDENTITY
  WHERE FEDERATED_USERNAME != LOWER(FEDERATED_USERNAME)
  LIMIT 100;
```

**まとめ**

Case-sensitive username設定の要点:

✅ **影響範囲は限定的**:
- フェデレーテッドアイデンティティのusernameのみ
- Keycloakの内部ユーザー名は常に小文字
- ユーザー識別には影響しない（subで識別）

✅ **主な用途**:
- 表示時の見た目の制御
- ブランディングやユーザー体験の向上
- 監査ログの可読性向上

⚠️ **重要なポイント**:
- セキュリティリスクはない
- パフォーマンスへの影響は最小限
- ほとんどの場合、デフォルト（無効）で問題ない
- 変更する明確な理由がない限り、デフォルトを推奨

🎯 **推奨設定**:
```yaml
一般的なケース: 無効（デフォルト）
特別な要件がある場合: 有効
```

---