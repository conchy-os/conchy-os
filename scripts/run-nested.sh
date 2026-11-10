#!/usr/bin/env bash
# run-nested.sh - Запуск композитора во вложенном Wayland-окне на хосте
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${SCRIPT_DIR}/scripts/nested-config.kdl"

# Добавляем пути к локально собранным бинарникам conchy (shell, shot, compositor) в PATH
if [ -d "${SCRIPT_DIR}/shell/target/release" ]; then
    export PATH="${SCRIPT_DIR}/shell/target/release:${PATH}"
elif [ -d "${SCRIPT_DIR}/shell/target/debug" ]; then
    export PATH="${SCRIPT_DIR}/shell/target/debug:${PATH}"
fi

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

export RUST_LOG="${RUST_LOG:-info,niri=debug}"
exec "$BIN" --config "$CONFIG" "$@"
