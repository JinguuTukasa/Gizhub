# ./echo-server/Dockerfile
FROM node:18-alpine

# 作業ディレクトリの設定
WORKDIR /usr/src/app

# laravel-echo-server のグローバルインストール
RUN npm install -g laravel-echo-server

# 必要に応じてその他の依存ファイルをコピー
# ※ 設定ファイル laravel-echo-server.json は docker-compose のボリュームマウントで提供される前提です
COPY . .

# 必要なポートの公開（実際の構成に合わせて調整）
EXPOSE 6001

# laravel-echo-server の起動
CMD ["laravel-echo-server", "start"]
