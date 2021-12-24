# Drupal

```yalm
version: '3'

services:

  db:
    image: hasangnu/mariadb
    container_name: hasangnu-mariadb
    environment:
      MYSQL_ROOT_PASSWORD: 'drupal'
      MYSQL_DATABASE: 'drupal'
      MYSQL_USER: 'drupal'
      MYSQL_PASSWORD: 'drupal'
    volumes:
      - ./mariadb-data/mysql:/var/lib/mysql

  drupal:
    image: hasangnu/php-drupal
    container_name: hasangnu-drupal0
    ports:
      - 8880:80
    volumes:
      - ./drupal-data:/var/www/html
    restart: always

  adminer:
    image: hasangnu/adminer
    restart: always
    ports:
      - 8088:8080
```

```
docker-compose up -d
```
