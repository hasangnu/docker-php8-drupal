FROM php:8.2-apache-bookworm

RUN set -eux; \
	\
	if command -v a2enmod; then \
		a2enmod rewrite; \
	fi; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libfreetype6-dev \
		libjpeg-dev \
		libpng-dev \
		libpq-dev \
		libwebp-dev \
		libzip-dev \
	; \
	\
	docker-php-ext-configure gd \
		--with-freetype \
		--with-jpeg=/usr \
		--with-webp \
	; \
	\
	docker-php-ext-install -j "$(nproc)" \
		gd \
		opcache \
		pdo_mysql \
		pdo_pgsql \
		zip \
	; \
	\
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); print so }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
	git \
	nano \
	unzip \
	wget \
	libxrender1 \
	libfontconfig1 \
	libxext6 \
	ssl-cert \
	&& rm -rf /var/lib/apt/lists/*

RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN { \
	echo 'upload_max_filesize = 16M'; \
	echo 'post_max_size = 16M'; \
	} > /usr/local/etc/php/conf.d/upload-recommended.ini

RUN a2enmod ssl

RUN a2ensite default-ssl.conf

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/

WORKDIR /opt/drupal

COPY composer.json /opt/drupal

RUN set -eux; \
	export COMPOSER_HOME="$(mktemp -d)"; \
	composer config --no-plugins allow-plugins.composer/installers true; \
	composer config --no-plugins allow-plugins.drupal/core-composer-scaffold true; \
	composer config --no-plugins allow-plugins.drupal/core-project-message true; \
	composer config --no-plugins allow-plugins.wikimedia/composer-merge-plugin true; \
	composer install; \
	rm -rf "$COMPOSER_HOME"

VOLUME /var/www/html

WORKDIR /var/www/html

COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["apache2-foreground"]

ENV PATH=${PATH}:/var/www/html/vendor/bin

# vim:set ft=dockerfile:
