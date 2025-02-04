# 軽量な Node.js イメージを使用
FROM node:18-alpine

# 作業ディレクトリを設定
WORKDIR /usr/src/app

# package.json と package-lock.json をコンテナにコピー
COPY package.json package-lock.json ./

# node_modules をコンテナ内に閉じ込める
RUN npm ci

# 残りのプロジェクトファイルをコピー
COPY . .

# ポート公開
EXPOSE 5173

# コンテナ起動時に Vite サーバーを起動
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "5173"]
