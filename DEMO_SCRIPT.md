# Rails Security Dojo - デモ発表台本

## 導入 (5 分)

### スライド: なぜ暗号化が必要か？

「今日は ActiveRecord::Encryption について学びます。」

「まず、なぜ DB レベルの暗号化が必要なのでしょうか？」

- データベースバックアップの漏洩リスク
- 内部不正アクセス
- SQL インジェクション経由のデータ流出
- コンプライアンス要件（GDPR, 個人情報保護法など）

---

## Part 1: 問題の確認 (10 分)

### 事前準備: filter_parameters の確認

Rails 7.1 以降では、デフォルトで `email` が `filter_parameters` に含まれています。
これによりコンソール出力で `[FILTERED]` と表示されるため、デモ前に設定を確認してください。

```ruby
# config/initializers/filter_parameter_logging.rb
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, ...  # ← :email を削除
]
```

**注意**: これはログ出力のフィルタリングであり、DB 内のデータは平文のままです。
デモ後は `:email` を戻すことを推奨します。

### 現状のデータ確認

```bash
# Railsコンソールでデータを確認
docker compose exec web rails console
```

```ruby
# Railsを通すと普通に見える
User.first
# => #<User id: 1, name: "山田太郎", email: "user1@example.com", ...>
```

### DB を直接参照すると...

```bash
# MySQLに直接接続
docker compose exec db mysql -u root -ppassword security_dojo_development
```

```sql
-- 個人情報が丸見え！
SELECT name, email, phone, address FROM users LIMIT 3;
```

**ポイント**: 「これが問題です。DB に直接アクセスされると、すべての個人情報が平文で見えてしまいます。」

---

## Part 2: ActiveRecord::Encryption の設定 (10 分)

### Step 1: 暗号化キーの生成

```bash
# credentialsを編集してキーを設定
docker compose exec -it -e EDITOR=vi web rails credentials:edit
```

以下を追加:

```yaml
active_record_encryption:
  primary_key: <32バイトのランダム文字列>
  deterministic_key: <32バイトのランダム文字列>
  key_derivation_salt: <32バイトのランダム文字列>
```

または自動生成:

```bash
docker compose exec web rails db:encryption:init
```

### Step 2: モデルに暗号化を追加

```ruby
# app/models/user.rb
class User < ApplicationRecord
  encrypts :email
  encrypts :phone
  encrypts :address
end
```

---

## Part 3: 暗号化の効果を確認 (10 分)

### DB をリセットして再作成

```bash
docker compose exec web rails db:reset
```

### Rails コンソールで確認

```ruby
User.first.email
# => "user1@example.com"  # 普通に見える
```

### MySQL で直接確認

```sql
SELECT email FROM users LIMIT 1;
-- => "{\"p\":\"...暗号化された文字列...\",\"h\":{\"iv\":\"...\",\"at\":\"...\"}}"
```

**ポイント**: 「Rails を通すと復号されますが、DB に直接アクセスしても暗号文しか見えません！」

---

## Part 4: Deterministic Encryption (10 分)

### 問題: 暗号化すると検索できない

```ruby
User.find_by(email: "user1@example.com")
# => nil  # 見つからない！
```

### 解決: deterministic オプション

```ruby
class User < ApplicationRecord
  encrypts :email, deterministic: true
  encrypts :phone
  encrypts :address
end
```

**重要**: モデル変更後、データを再作成する必要があります（既存データは non-deterministic で暗号化されているため）。

```bash
# コンソールを終了してDBをリセット
docker compose exec web rails db:reset
```

```bash
# 再度コンソールに入る
docker compose exec web rails console
```

```ruby
User.find_by(email: "user1@example.com")
# => #<User ...>  # 検索できる！
```

**注意**: deterministic は同じ入力に対して同じ暗号文を生成するため、パターン分析に弱い。本当に検索が必要なフィールドのみに使用。

---

## Part 5: 鍵ローテーション (5 分)

### なぜ鍵ローテーションが必要？

- 定期的なセキュリティ更新
- 鍵の漏洩時の対応
- コンプライアンス要件

### 鍵ローテーションの仕組み

```
【ローテーション前】
DB: [古い鍵で暗号化されたデータ]
credentials: old_key

【ローテーション中】
DB: [古い鍵で暗号化されたデータ] ← まだ古い鍵
credentials:
  - new_key  ← 新しい鍵（書き込み用）
  - old_key  ← 古い鍵（読み取りフォールバック用）

この状態で Rails は:
- 読み取り: new_key で試す → 失敗 → old_key で復号 ✓
- 書き込み: new_key で暗号化

【re_encrypt 実行後】
DB: [新しい鍵で暗号化されたデータ] ← 全データが新しい鍵に
credentials:
  - new_key  ← これだけでOK
```

### 実装手順

**Step 1**: 新しい鍵を生成

```bash
docker compose exec web rails db:encryption:init
# 表示された primary_key をメモ
```

**Step 2**: credentials に新旧両方の鍵を設定

```yaml
# config/credentials.yml.enc
active_record_encryption:
  primary_key:
    - <新しいキー> # 配列の最初 = 書き込み用
    - <古いキー> # 配列の2番目 = 読み取りフォールバック用
  deterministic_key: ...
  key_derivation_salt: ...
```

**Step 3**: 全データを新しい鍵で再暗号化

```bash
docker compose exec web rails encryption:re_encrypt
```

このコマンドは以下を実行します:

1. 暗号化カラムを持つ全レコードを取得
2. 各レコードを読み込み（古い鍵で復号）
3. 同じ値で保存（新しい鍵で暗号化）

**Step 4**: 古い鍵を削除（任意）

全データが新しい鍵で暗号化されたら、古い鍵は不要になります。

---

## まとめ (5 分)

### ActiveRecord::Encryption のメリット

1. **透過的**: アプリケーションコードの変更が最小限
2. **標準機能**: Rails 7.0+ に組み込み済み
3. **柔軟**: non-deterministic / deterministic を選択可能
4. **運用しやすい**: 鍵ローテーションをサポート

### 導入時の注意点

- 既存データのマイグレーション計画
- パフォーマンスへの影響（軽微）
- deterministic の使いどころ
- バックアップからの復元時にキーが必要

### 質疑応答

「何か質問はありますか？」

---

## 補足デモ

### テスト実行

```bash
docker compose exec web bundle exec rspec spec/demo/
```

### ブランチの切り替え

```bash
git checkout step/02-add-encrypts
docker compose exec web rails db:reset
```
