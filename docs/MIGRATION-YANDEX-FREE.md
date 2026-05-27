# Миграция edecorus.ru на Yandex Cloud (бесплатно)

План по [документации Yandex Object Storage](https://yandex.cloud/ru/docs/storage/pricing) и [хостингу в бакете](https://yandex.cloud/ru/docs/storage/operations/hosting/setup). Без Hugo — заливаем текущий HTML как есть.

## Сколько стоит

Для сайта Ёдекор (~десятки МБ, умеренный трафик) в месяц укладываемся в **free tier** Object Storage:

| Ресурс | Бесплатно в месяц |
|--------|-------------------|
| Хранение | 1 ГБ |
| Исходящий трафик | 100 ГБ |
| GET-запросы | 100 000 |
| PUT/POST и др. | 10 000 |

GitHub (репозиторий + Actions) — **0 ₽** для публичного репо.

**Не входит в бесплатный минимум:** Application Load Balancer + статический IP для [белого списка Минцифры](https://yandex.cloud/ru/docs/overview/concepts/info-for-federal-ip-whitelist) — это отдельный платный этап, не обязателен для обычной работы сайта.

## Архитектура после миграции

```
GitHub (main) --> GitHub Actions --> Yandex Object Storage (бакет edecorus.ru)
                                              |
DNS edecorus.ru ---- CNAME/ALIAS ------------+
```

Пока DNS указывает на GitHub Pages — работает старый хостинг. После переключения DNS — Yandex.

## Этап 0. Подготовка (уже в репозитории)

- [x] `404.html` для хостинга в бакете
- [x] `scripts/deploy-yandex-s3.ps1` — ручной деплой
- [x] `.github/workflows/deploy-yandex.yml` — автодеплой при push
- [x] `scripts/yandex-deploy-config.example.ps1`

## Этап 1. Yandex Cloud (один раз, ~15 мин)

**Пошагово «куда кликать»:** [YC-SETUP-CLICKS.md](YC-SETUP-CLICKS.md)  
**Чеклист в браузере:** откройте файл [SETUP-START.html](../SETUP-START.html) из папки проекта.

1. Регистрация: [console.yandex.cloud](https://console.yandex.cloud/) (нужна карта для аккаунта; списания в пределах free tier — копейки или 0).
2. **Object Storage** → **Создать бакет**:
   - Имя: `edecorus.ru` (как домен).
   - Регион: `ru-central1`.
   - Доступ: **Публичный** на чтение объектов и списка.
   - **Без** шифрования бакета (иначе хостинг сайта недоступен).
3. Бакет → **Настройки** → **Веб-сайт** → **Хостинг**:
   - Главная: `index.html`
   - Ошибка: `404.html`
4. Проверка: `https://edecorus.ru.website.yandexcloud.net`
5. **IAM** → сервисный аккаунт → роль `storage.editor` → **статический ключ** (Access Key + Secret).

## Этап 2. Деплой с компьютера (проверка)

```powershell
pip install awscli
aws configure --profile yc
# Access Key, Secret, region ru-central1

copy scripts\yandex-deploy-config.example.ps1 scripts\yandex-deploy-config.local.ps1
# при необходимости поправить имя бакета

.\scripts\deploy-yandex-s3.ps1
```

Откройте тестовый URL бакета и проверьте страницы, MAX, метрику.

## Этап 3. Автодеплой из GitHub

В репозитории **Settings → Secrets and variables → Actions**:

| Secret | Значение |
|--------|----------|
| `YC_SA_ACCESS_KEY_ID` | ключ сервисного аккаунта |
| `YC_SA_SECRET_ACCESS_KEY` | секрет |

Опционально **Variable** `YC_BUCKET` = `edecorus.ru`.

После push в `main` workflow **Deploy to Yandex Cloud** зальёт файлы в бакет.

## Этап 4. Свой домен edecorus.ru

Документация: [Собственный домен](https://yandex.cloud/ru/docs/storage/operations/hosting/setup), [HTTPS](https://yandex.cloud/ru/docs/storage/concepts/https).

1. В бакете включить **поддержку своего домена** (консоль → Веб-сайт / домен).
2. У регистратора DNS (где куплен edecorus.ru):
   - Удалить записи на **GitHub Pages** (`185.199.x.x` или `*.github.io`).
   - Добавить **CNAME** `edecorus.ru` → `edecorus.ru.website.yandexcloud.net`  
     или **ANAME/ALIAS** на этот же хост (если поддерживает reg.ru).
3. Подождать 15 мин – 24 ч, проверить `https://edecorus.ru`.
4. В GitHub: **Settings → Pages** → отключить custom domain (чтобы не конфликтовало).

Файл `CNAME` в репозитории для GitHub Pages после миграции можно удалить (отдельным коммитом).

## Этап 5. Откат (если что-то не так)

Вернуть DNS на GitHub Pages, включить Pages снова — сайт на старом хостинге. Бакет Yandex можно оставить как резерв.

## Чеклист после переключения

- [ ] Главная, контакты, каталог открываются
- [ ] `https` работает
- [ ] Яндекс.Метрика (счётчик 80298997)
- [ ] Кнопка MAX на contact.html
- [ ] `robots.txt`, `sitemap.xml`

## Связь с «белым списком»

Размещение в Yandex Cloud **не добавляет** сайт в федеральный список Минцифры. Для этого нужны статический IP, заявка/ходатайство и социальная значимость — см. [оценку статьи Flag Soft](../CONTEXT.md) и [доку YC](https://yandex.cloud/ru/docs/overview/concepts/info-for-federal-ip-whitelist).

Текущая миграция даёт: **хостинг в РФ**, низкая стоимость, автодеплой — без гарантии доступности при ограничениях мобильного интернета.
