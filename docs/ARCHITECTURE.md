# Архитектура Desktop Environment

## Структура репозитория

```
my-linux/
├── compositor/           # Патченный композитор на базе Niri + Smithay (HDR, Tearing, Vulkan, SyncObj)
├── smithay/              # Модифицированная библиотека Smithay (Colorop, DRM atomic, HDR connectors)
├── session/              # Rust Session Manager (супервизия процессов под Void/runit, импорт D-Bus)
├── shell/                # Desktop Shell & Bar (панель, OSD, Quick Settings, App Launcher)
├── packages/             # Шаблоны сборки xbps-src для Void Linux
└── docs/                 # Документация, спецификации и журнал решений (Memory Log)
```

## Компоненты окружения

### 1. Compositor (`compositor/`)
- Ядро: Скроллинг-тайлинг на базе Smithay.
- Особенности:
  - Поддержка HDR и протокола `wp_color_management_v1`.
  - Явная синхронизация `linux-drm-syncobj-v1` (плавная работа на Intel Xe3 и Nvidia).
  - Поддержка `wp_tearing_control_v1` для игровых окон с низкой задержкой.
  - Нативное сворачивание окон (Minimizing).
  - Вложенный режим (Nested Wayland) для мгновенной разработки на хосте.

### 2. Session Orchestrator (`session/`)
- Заменяет `systemd --user` на Void Linux.
- Запуск D-Bus сессии и передача переменных окружения (`WAYLAND_DISPLAY`, `XDG_CURRENT_DESKTOP=niri`).
- Диспетчеризация процессов: композитор, шелл, порталы (`xdg-desktop-portal`), PipeWire, Polkit agent.
- Автоматический перезапуск упавших сервисов и корректный выход из сессии.

### 3. Desktop Shell (`shell/`)
- Статус-бар: индикация воркспейсов, трей (StatusNotifierItem), часы, сетевой апплет, батарея.
- Панель быстрых настроек (Quick Settings): переключатели Wi-Fi, Bluetooth, профилей производительности, ночной подсветки, HDR.
- OSD: всплывающие уведомления изменения громкости, яркости экрана и Caps Lock.
- Интеграция с порталами рабочего стола.
