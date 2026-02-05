# 参考リンク集

## 公式ドキュメント

- [Active Record Encryption — Ruby on Rails Guides](https://guides.rubyonrails.org/active_record_encryption.html)
- [ActiveRecord::Encryption API Documentation](https://api.rubyonrails.org/classes/ActiveRecord/Encryption.html)

## Rails公式ブログ・リリースノート

- [Rails 7.0 Release Notes - Active Record Encryption](https://edgeguides.rubyonrails.org/7_0_release_notes.html#active-record-encryption)

## 技術記事

### 日本語

- [Rails 7 の Active Record Encryption を試す](https://techracho.bpsinc.jp/hachi8833/2022_01_13/114667)
- [ActiveRecord::Encryption で DB の暗号化をやってみる](https://zenn.dev/because_and/articles/9d5e9b5c9c7c4f)

### 英語

- [Securing Rails Applications - OWASP](https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/10-Business_Logic_Testing/09-Test_Upload_of_Malicious_Files)
- [Database Encryption Best Practices](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html)

## 関連トピック

### 暗号化全般

- [OWASP Cryptographic Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html)
- [NIST Cryptographic Standards](https://csrc.nist.gov/projects/cryptographic-standards-and-guidelines)

### コンプライアンス

- [GDPR - 個人データの暗号化](https://gdpr.eu/data-encryption/)
- [個人情報保護法 - 安全管理措置](https://www.ppc.go.jp/personalinfo/legal/)

## ツール・ライブラリ

### attr_encrypted（旧来の選択肢）

- [attr_encrypted gem](https://github.com/attr-encrypted/attr_encrypted)
- Rails 7以降は ActiveRecord::Encryption を推奨

### lockbox（alternative）

- [lockbox gem](https://github.com/ankane/lockbox)
- ファイル暗号化やActive Storage対応が必要な場合

## セキュリティ監査

- [Brakeman - Rails Security Scanner](https://brakemanscanner.org/)
- [bundler-audit - Gem脆弱性チェック](https://github.com/rubysec/bundler-audit)

## 質問・ディスカッション

- [Ruby on Rails Discussions](https://discuss.rubyonrails.org/)
- [Stack Overflow - activerecord-encryption tag](https://stackoverflow.com/questions/tagged/activerecord-encryption)
