#!/usr/bin/env bash
# run-nested.sh - Запуск композитора во вложенном Wayland-окне на хосте
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${SCRIPT_DIR}/scripts/nested-config.kdl"

# Добавляем пути к локально собранным бинарникам conchy (shell, shot, config) в PATH
# Если дебажная сборка новее старого релиза, отдаём предпочтение свежему бинарнику
if [ -x "${SCRIPT_DIR}/shell/target/release/conchy-shell" ] && [ "${SCRIPT_DIR}/shell/target/release/conchy-shell" -nt "${SCRIPT_DIR}/shell/target/debug/conchy-shell" ]; then
    export PATH="${SCRIPT_DIR}/shell/target/release:${PATH}"
    echo "[*] Conchy Shell: используется релизный бинарник shell/target/release/conchy-shell"
elif [ -x "${SCRIPT_DIR}/shell/target/debug/conchy-shell" ]; then
    export PATH="${SCRIPT_DIR}/shell/target/debug:${PATH}"
    echo "[*] Conchy Shell: используется отладочный бинарник shell/target/debug/conchy-shell"
elif [ -x "${SCRIPT_DIR}/shell/target/release/conchy-shell" ]; then
    export PATH="${SCRIPT_DIR}/shell/target/release:${PATH}"
    echo "[*] Conchy Shell: используется бинарник shell/target/release/conchy-shell"
fi

if [ -d "${SCRIPT_DIR}/shot/target/release" ]; then
    export PATH="${SCRIPT_DIR}/shot/target/release:${PATH}"
elif [ -d "${SCRIPT_DIR}/shot/target/debug" ]; then
    export PATH="${SCRIPT_DIR}/shot/target/debug:${PATH}"
fi

if [ -d "${SCRIPT_DIR}/config/target/release" ]; then
    export PATH="${SCRIPT_DIR}/config/target/release:${PATH}"
elif [ -d "${SCRIPT_DIR}/config/target/debug" ]; then
    export PATH="${SCRIPT_DIR}/config/target/debug:${PATH}"
fi

# Изолируем окружение от родительского хостового композитора
unset HYPRLAND_INSTANCE_SIGNATURE
export XDG_CURRENT_DESKTOP="conchy:niri"

# Выбор релизного или дебажного бинарника
if [ -f "${SCRIPT_DIR}/compositor/target/release/conchy-wm" ]; then
    BIN="${SCRIPT_DIR}/compositor/target/release/conchy-wm"
    echo "[*] Используется оптимизированный релизный бинарник: target/release/conchy-wm"
elif [ -f "${SCRIPT_DIR}/compositor/target/release/niri" ]; then
    BIN="${SCRIPT_DIR}/compositor/target/release/niri"
    echo "[*] Используется оптимизированный релизный бинарник: target/release/niri"
elif [ -f "${SCRIPT_DIR}/compositor/target/debug/conchy-wm" ]; then
    BIN="${SCRIPT_DIR}/compositor/target/debug/conchy-wm"
    echo "[*] Используется отладочный бинарник: target/debug/conchy-wm"
elif [ -f "${SCRIPT_DIR}/compositor/target/debug/niri" ]; then
    BIN="${SCRIPT_DIR}/compositor/target/debug/niri"
    echo "[*] Используется отладочный бинарник: target/debug/niri"
else
    echo "[!] Ошибка: бинарник conchy-wm / niri не найден."
    echo "    Соберите проект: cd compositor && cargo build"
    exit 1
fi

echo "=================================================================="
echo "  Запуск вложенного Wayland-композитора (Nested Conchy WM)"
echo "  • Конфиг: $CONFIG"
echo "  • Управление в окне: клавиша Mod = Alt (не трогает Super в Hyprland)"
echo "  • Хоткеи внутри окна:"
echo "      Alt + Enter / Alt + T  -> Терминал (alacritty)"
echo "      Alt + D                -> Лаунчер Conchy Shell (Alt+Shift+D fuzzel)"
echo "      Alt + I                -> Центр управления Conchy Shell"
echo "      Alt + Q                -> Закрыть окно"
echo "      Alt + M                -> Свернуть окно (Minimize)"
echo "      Alt + Left / Right     -> Скролл колонок"
echo "      Alt + Tab              -> Обзор (Overview)"
echo "      Alt + Space            -> Floating переключатель"
echo "      Alt + Shift + E        -> Выход из вложенного окна"
echo "=================================================================="

export RUST_LOG="${RUST_LOG:-info,conchy_wm=debug,niri=debug}"
exec "$BIN" --config "$CONFIG" "$@"
