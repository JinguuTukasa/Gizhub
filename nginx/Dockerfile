# ./nginx/Dockerfile
FROM nginx:alpine

# ※ docker-compose.yml で default.conf をボリュームマウントしているため、
#    ここでのコピーは必須ではありませんが、初期設定として残しておく例です。
COPY default.conf /etc/nginx/conf.d/default.conf

# ポートの公開（docker-compose でポートマッピングしているので必須ではありませんが記載例）
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
