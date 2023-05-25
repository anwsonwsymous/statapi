FROM bitnami/php-fpm:8.1

ARG UID=1000
ARG GID=1000
RUN groupadd -f -g $GID www && \
    useradd -u $UID -g $GID -m www

# Install Supervisor and Php redis ext
RUN apt-get update && \
    apt-get install -y supervisor php-dev && \
    pecl install redis -n && \
    rm -rf /var/lib/apt/lists/*

RUN chown -R www:www ../opt

USER www

CMD ["php-fpm", "--nodaemonize"]
