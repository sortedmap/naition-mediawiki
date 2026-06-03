# MediaWiki — локальный запуск в Docker

Проект: **MediaWiki 1.26.3** с **VisualEditor**, PHP 5.6.40, Nginx, MySQL 5.7.42, Parsoid.

## Требования

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (или Docker Engine + Compose v2)
- Git
- ~2 GB свободной RAM
- Интернет при **первом** запуске (скачивание VisualEditor и сборка Parsoid)

## Быстрый старт

```bash
git clone <URL-репозитория>
cd <имя-папки-репозитория>

cp .env.example .env

docker compose up -d --build
```

Первый запуск занимает несколько минут: собираются образы, создаётся база, устанавливается wiki.

Откройте в браузере: **http://localhost:8080**

| Параметр | Значение по умолчанию |
|----------|------------------------|
| Логин администратора | `admin` |
| Пароль | `adminpass` |

Пароли и URL можно изменить в файле `.env` (см. `.env.example`).

## Работа с проектом

### Остановить окружение

```bash
docker compose down
```

Данные wiki в базе сохраняются в Docker-volume `mysql_data`.

### Запустить снова

```bash
docker compose up -d
```

Пересборка не нужна, если вы меняли только PHP/JS/CSS в папке `mediawiki/`.

### Править код и проверять изменения

1. Остановите контейнеры (по желанию): `docker compose down`
2. Редактируйте файлы в каталоге **`mediawiki/`** в вашем редакторе
3. Запустите снова: `docker compose up -d`

Код wiki монтируется в контейнер с диска — изменения видны сразу после перезапуска (для PHP обычно достаточно `docker compose restart app`).

После добавления расширений или изменений схемы БД:

```bash
docker compose exec app php maintenance/update.php --quick
```

### Полностью сбросить базу (чистая установка)

```bash
docker compose down -v
docker compose up -d --build
```

Флаг `-v` удаляет volume с MySQL; wiki установится заново.

## Полезные команды

```bash
# Логи
docker compose logs -f app
docker compose logs -f parsoid

# Список PHP-модулей
docker compose exec app php -m

# Проверка модулей по списку php-modules.txt
docker compose exec app /docker/verify-php-modules.sh /php-modules.txt

# Версии
docker compose exec app php -v
docker compose exec db mysql --version
```

## Структура репозитория

| Путь | Описание |
|------|----------|
| `mediawiki/` | Исходный код MediaWiki (редактируете здесь) |
| `docker/` | Конфигурация Nginx, PHP, скрипты запуска |
| `Dockerfile` | Образ с PHP 5.6.40 и Nginx |
| `docker-compose.yml` | Сервисы `app`, `db`, `parsoid` |
| `.env.example` | Пример настроек (скопируйте в `.env`) |

## Сервисы

| Сервис | Назначение |
|--------|------------|
| `app` | Nginx + PHP-FPM + MediaWiki |
| `db` | MySQL 5.7.42 |
| `parsoid` | Сервис для VisualEditor |

Расширение **VisualEditor** при первом запуске автоматически клонируется в `mediawiki/extensions/VisualEditor` (нужен интернет).

## Развёртывание на VPS

В `.env` укажите публичный URL wiki (тот же хост и порт, что в `docker-compose.yml`):

```bash
MW_SERVER=http://ВАШ_IP:8080
```

После изменения `.env` пересоздайте контейнер `app` (обычный `restart` не подхватывает новые переменные):

```bash
docker compose up -d --force-recreate app
```

## Частые проблемы

**Connection refused на :8080** — порт не слушается, пока контейнер `app` не в статусе `Up`. Проверьте:

```bash
docker compose ps
docker compose logs --tail=80 app
```

Если `app` в цикле `Restarting`, смотрите последние строки логов (частая причина — неполная папка `mediawiki/`, в том числе отсутствует `includes/cache/`). После исправления кода: `docker compose up -d --build`.

**Порт 8080 занят** — в `docker-compose.yml` измените `"8080:80"` на другой порт, например `"8888:80"`, и укажите тот же URL в `.env`: `MW_SERVER=http://localhost:8888`.

**Apple Silicon (M1/M2)** — в compose указано `platform: linux/amd64`; первый запуск может быть медленнее.

**Ошибка Parsoid / VisualEditor** — дождитесь полного старта: `docker compose ps` (все сервисы `running`), затем обновите страницу. Проверьте логи: `docker compose logs parsoid`.