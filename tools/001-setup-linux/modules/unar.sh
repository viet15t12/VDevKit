#!/usr/bin/env bash
#
# unar.sh - Cài unar (giải nén đa định dạng) từ kho chính thức của distro.
# Lưu ý: gói chứa binary `unar` tên khác nhau tùy distro
# (Arch/Void đóng gói chung trong "unarchiver").

install_unar() {
    printf '\n%s=== unar ===%s\n' "$BOLD" "$RESET"

    if command_exists unar; then
        warning "unar đã được cài."
        unar -v 2>/dev/null | head -n 1 || true
        return 0
    fi

    local package="unar"
    case "$PKG_MANAGER" in
        pacman|xbps) package="unarchiver" ;;
    esac

    install_package "$package" "unar"
}
