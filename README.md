# Drupal PHP 8

```yalm
version: '3'

services:

  db:
    image: hasangnu/mariadb
    container_name: hasangnu-8-mariadb
    environment:
      MYSQL_ROOT_PASSWORD: 'drupal'
      MYSQL_DATABASE: 'drupal'
      MYSQL_USER: 'drupal'
      MYSQL_PASSWORD: 'drupal'
    volumes:
      - ./mariadb-data/mysql:/var/lib/mysql

  drupal:
    image: hasangnu/php8-drupal
    container_name: hasangnu-8-drupal
    ports:
      - 8384:80
      - 8433:443
    volumes:
      - ./drupal-data:/var/www/html
    restart: always

  adminer:
    image: hasangnu/adminer
    restart: always
    ports:
      - 8385:8080
```

```
docker-compose up -d
```
