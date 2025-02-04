# PHP 8.2 を使用
FROM php:8.2-fpm

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    locales \
    zip \
    unzip \
    cron \
    curl \
    redis \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && docker-php-ext-install pdo pdo_mysql


# Composer をインストール（公式の Composer イメージからコピーする方法）
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 作業ディレクトリを設定
WORKDIR /var/www/html

# ホストの Laravel ソースコードをコンテナ内にコピー（docker-compose でボリュームマウントしている場合は省略可）
COPY . /var/www/html

# 必要なディレクトリを作成
RUN mkdir -p /var/www/html/storage/framework/{sessions,views,cache}

# 権限の設定
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 777 /var/www/html/storage /var/www/html/bootstrap/cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# コンテナ内で PHP-FPM がリッスンするポート（※通常は内部ポートとして使用）
EXPOSE 9000

# コンテナ起動時に PHP-FPM を実行
CMD ["php-fpm"]
