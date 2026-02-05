# Rails Security Dojo

ActiveRecord::Encryption を学ぶための社内勉強会用デモアプリケーション

## 概要

このリポジトリは、Rails 8 の `ActiveRecord::Encryption` 機能を段階的に学習できるように設計されています。

## 動作環境

- Docker / Docker Compose
- Ruby 4.0.1
- Rails 8.1.2
- MySQL 8.0

**ローカル環境にRubyやRailsのインストールは不要です。**

## クイックスタート

```bash
# 1. リポジトリをクローン
git clone <repository-url>
cd rails-security-sample

# 2. Dockerイメージをビルド
docker compose build

# 3. コンテナを起動
docker compose up -d

# 4. データベースを準備
docker compose exec web rails db:create db:migrate db:seed

# 5. ブラウザでアクセス
open http://localhost:3000
```

## ブランチ構成

| ブランチ | 説明 |
|---------|------|
| `main` | 暗号化なしのベース版 |
| `step/01-setup-encryption` | encryption設定を有効化 |
| `step/02-add-encrypts` | モデルに`encrypts`を追加 |
| `step/03-deterministic-demo` | deterministic暗号化でクエリ可能に |
| `step/04-key-rotation` | 鍵ローテーションの実装 |

## 便利なコマンド

```bash
# Railsコンソール
docker compose exec web rails console

# MySQLに直接接続
docker compose exec db mysql -u root -ppassword security_dojo_development

# テスト実行
docker compose exec web bundle exec rspec

# ログを確認
docker compose logs -f web
```

## デモシナリオ

詳細な発表手順は [DEMO_SCRIPT.md](./DEMO_SCRIPT.md) を参照してください。

## 参考資料

- [docs/cheatsheet.md](./docs/cheatsheet.md) - ActiveRecord::Encryption チートシート
- [docs/references.md](./docs/references.md) - 公式ドキュメント・参考リンク集
