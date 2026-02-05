# ActiveRecord::Encryption チートシート

## 基本設定

### 1. 暗号化キーの生成

```bash
rails db:encryption:init
```

出力されたキーを `config/credentials.yml.enc` に追加:

```yaml
active_record_encryption:
  primary_key: <生成されたキー>
  deterministic_key: <生成されたキー>
  key_derivation_salt: <生成されたキー>
```

### 2. credentials の編集

```bash
# ローカル
EDITOR=code rails credentials:edit

# Docker
docker compose exec -e EDITOR=vi web rails credentials:edit
```

## モデルでの使用

### 基本の暗号化（non-deterministic）

```ruby
class User < ApplicationRecord
  encrypts :email
  encrypts :phone
  encrypts :address
end
```

**特徴**: 同じ値でも毎回異なる暗号文になる（より安全）

### 検索可能な暗号化（deterministic）

```ruby
class User < ApplicationRecord
  encrypts :email, deterministic: true
end
```

**特徴**: 同じ値は同じ暗号文になる → `find_by` が使える

## よく使うパターン

### 暗号化＋ダウンケース

```ruby
encrypts :email, deterministic: true, downcase: true
```

### 暗号化＋無視する空白

```ruby
encrypts :email, deterministic: true, ignore_case: true
```

### 前方一致検索用（部分一致は不可）

```ruby
# これは動かない
User.where("email LIKE ?", "%@example.com")

# 代わりにスコープを使う
encrypts :email_domain, deterministic: true

def email_domain
  email.split("@").last
end
```

## 鍵ローテーション

### 1. 新しいキーを追加

```yaml
active_record_encryption:
  primary_key:
    - <新しいキー>
    - <古いキー>
```

### 2. 全データを再暗号化

```ruby
# lib/tasks/re_encrypt.rake
User.find_each do |user|
  user.encrypt
end
```

## トラブルシューティング

### 暗号化されているか確認

```ruby
User.first.email          # 復号された値
User.first.email_before_type_cast  # 生の暗号文
```

### DBで直接確認

```sql
SELECT email FROM users LIMIT 1;
-- 暗号化されていれば JSON形式の文字列が見える
```

### 暗号化を一時的に無効化

```ruby
ActiveRecord::Encryption.without_encryption do
  User.first.email  # 暗号文がそのまま返る
end
```

## 注意点

| 項目 | non-deterministic | deterministic |
|------|-------------------|---------------|
| セキュリティ | 高い | やや低い |
| 検索 | 不可 | 可能 |
| ユニーク制約 | 使えない | 使える |
| 推奨用途 | 住所、メモなど | メール、電話番号など |

## パフォーマンス

- 暗号化/復号はCPU負荷あり（軽微）
- インデックスは暗号文に対して作成される
- LIKE検索は non-deterministic では不可能
