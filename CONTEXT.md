# Контекст проекта edecorus.ru

Документ для разработчиков и AI-ассистентов: состояние сайта, пути на этом ПК, ограничения, открытые задачи.

**Обновлено:** 2026-05-27  
**Последний коммит в репозитории:** смотреть `git log -1` на ветке `main`.

---

## Организация и сайт

| Параметр | Значение |
|----------|----------|
| Юрлицо | ООО «Ёдекор» |
| ИНН | 2311246970 |
| ОГРН | 1172375087125 |
| КПП | 231101001 |
| Домен | https://edecorus.ru/ |
| Репозиторий | https://github.com/m11nic89co/edecorus |
| Ветка | `main` |
| Деплой (сейчас) | GitHub Pages (`CNAME` → edecorus.ru) |
| Деплой (план) | Yandex Object Storage, free tier — см. `docs/MIGRATION-YANDEX-FREE.md` |

**Деятельность:** производство и оптовые продажи (продукты питания, товары для дома, ковка, капельный полив, аксессуары для хранения).

---

## Рабочие папки на этом ПК (настроено)

| Путь | Назначение | Cursor / git |
|------|------------|----------------|
| **`C:\Users\AM\Projects\Y\edecorus.ru`** | основная разработка, коммиты, push | **да** |
| `C:\Users\AM\MYDISK\Yodekor\edecorus\` | архив на Google Drive: `site/`, `docs/` | нет |
| `C:\Users\AM\MYDISK\Projects\Y\edecorus.ru` | старая копия внутри синхронизации Drive | **не использовать** |

**Google Drive на этом компьютере:** диск `G:\` → ярлык «My Drive» → корень синхронизации **`C:\Users\AM\MYDISK`**.  
Любая папка под `MYDISK\` уходит в облако; одновременная работа Cursor + Drive в одной папке даёт блокировки и «conflicted copy».

Локальный конфиг (не в git): `scripts/workspace-paths.local.ps1`

```powershell
$LocalDevRoot = 'C:\Users\AM\Projects\Y\edecorus.ru'
$GoogleDriveRoot = 'C:\Users\AM\MYDISK\Yodekor\edecorus'
```

### Скрипты

| Скрипт | Действие |
|--------|----------|
| `scripts/setup-local-workspace.ps1` | однократно: клон в Projects, папка архива, `workspace-paths.local.ps1` |
| `scripts/check-google-drive-path.ps1` | проверка: проект не внутри MYDISK/Drive |
| `scripts/sync-to-google-drive.ps1` | копия сайта → `$GoogleDriveRoot\site\`, `drive-archive\` → `\docs\` |

**Источник правды для сайта:** GitHub `main`, не Google Drive.

### Google Drive: Stream и Mirror

- **Stream** — файлы в основном в облаке, локально кэш ([справка](https://support.google.com/drive/answer/13401938)).
- **Mirror** — полная копия на диске; при активном редактировании чаще блокировки.
- Папку с **git + Cursor** не добавлять в «Синхронизация папок с компьютера» в Drive.

---

## Технологии

- Статический сайт: HTML + Bootstrap 4.5.2 (CDN) + `css/styles.css`
- Без сборщика (webpack/vite нет)
- JS: `js/site-footer.js`, `js/max-config.js`, `js/max-chat-link.js`
- Шрифты: Google Fonts (Playfair Display), Font Awesome (kit)
- Метрика: Яндекс.Метрика на страницах с полным шаблоном
- Prettier в `.vscode/settings.json` (format on save)

---

## Структура страниц

| Файл | Назначение | Nav | Футер |
|------|------------|-----|-------|
| `index.html` | Главная | да | `site-footer.js` |
| `contact.html` | Контакты, MAX, реквизиты | да | да |
| `vacancies.html` | Вакансии | да | да |
| `kapelnyj-poliv.html` | Каталог | нет | да |
| `kovannye-podstavki-vazony.html` | Каталог | нет | да |
| `nabor-dlya-hraneniya.html` | Каталог | нет | да |
| `aksessuary-dlya-hraneniya-instrumentov.html` | Каталог | нет | да |

Каталог: класс `page-catalog`, единый футер через `site-footer.js`.

---

## Контакты на сайте

| Назначение | Значение |
|------------|----------|
| Горячая линия (кнопка на contact) | текст «+7 (963) 77 999 05», ссылка `tel:+79615305504` |
| Опт / sales | +7 (963) 77 999 05, sales@edecorus.ru |
| Сотрудничество | +7 (988) 247-23-55 |
| MAX (мессенджер) | +7 (988) 247-23-55 |
| Телефон в шапке (index, contact, vacancies) | 8(988)2472355 → `tel:+79882472355` |
| Бухгалтерия | buh@edecorus.ru |
| Руководство | ceo@edecorus.ru |

**Удалено по запросу:** домены и почты `edecorus.com.ru` — не восстанавливать без явной просьбы.

---

## MAX (мессенджер)

### Цель

По клику на иконку MAX на **мобильном** — сразу чат с сотрудником (+7 988 247-23-55). Бизнес-бот не используется.

### Ограничения

- `https://max.ru/chat?phone=...` — **не работает**.
- Публичной ссылки по номеру нет (нет `wa.me`).
- Рабочий вариант: **`https://max.ru/u/<код>`** (Пригласить друзей / Пригласить по ссылке).

### Код

- `js/max-config.js` — `profileUrl` (**пока пусто**), телефоны.
- `js/max-chat-link.js` — `[data-max-chat]`: с `profileUrl` → открытие MAX (Android: intent `ru.oneme.app`); без ссылки → копирование номера + модалка `#maxChatModal`.
- Иконка: `css/images/max-icon.png`, класс `.social-logo-max`.
- MAX только на `contact.html`.

### Получить profileUrl

1. Профиль → «Пригласить друзей» → «Скопировать ссылку».
2. Контакты → + → «Пригласить по ссылке» → себе в «Избранное».
3. web.max.ru → Профиль → Пригласить друзей.
4. Вставить в `js/max-config.js`: `profileUrl: 'https://max.ru/u/...'`.

---

## Ключевые файлы

```
js/max-config.js       — MAX: profileUrl, телефон
js/max-chat-link.js    — клик MAX, intent, модалка
js/site-footer.js      — футер + политика
css/styles.css         — стили, MAX, футер
contact.html           — контакты, MAX, реквизиты
CONTEXT.md             — этот файл
.gitignore             — workspace-paths.local.ps1 и др.
drive-archive/         — документы для копии на Drive (docs/)
scripts/               — Drive и проверка путей
```

---

## Git и деплой

```powershell
cd C:\Users\AM\Projects\Y\edecorus.ru
git status
git add ...
git commit -m "..."
git push origin main
```

После push: GitHub Pages через 1–3 мин, проверка Ctrl+F5.

Опционально бэкап на Drive:

```powershell
.\scripts\sync-to-google-drive.ps1
```

---

## Незавершено

- [ ] `profileUrl` в `max-config.js` (ждём ссылку `https://max.ru/u/...`).
- [ ] Миграция на Yandex Cloud: этапы 1–4 в `docs/MIGRATION-YANDEX-FREE.md` (нужны ключи в YC и GitHub Secrets).
- [ ] Открыть в Cursor папку `C:\Users\AM\Projects\Y\edecorus.ru`, если ещё открыта `MYDISK\Projects\...`.
- [ ] По желанию: иконка MAX на других страницах (сейчас только contact).

---

## Не делать без запроса

- Возврат `edecorus.com.ru`.
- Ссылки MAX `chat?phone=`.
- business.max.ru / боты / CRM без запроса.
- Работа в `MYDISK\Projects\Y\edecorus.ru` как в основной папке Cursor.

---

## История (кратко)

- WhatsApp → MAX, иконка max.ru.
- Телефон в шапке: 8(988)2472355.
- Отказ от `chat?phone=`, личная `profileUrl`, упрощённая модалка.
- Единый футер, политика конфиденциальности.
- Разделение: разработка в `Projects\`, архив в `MYDISK\Yodekor\edecorus\`, скрипты Drive, `CONTEXT.md`.

---

## Язык

Ответы пользователю — **на русском**.
