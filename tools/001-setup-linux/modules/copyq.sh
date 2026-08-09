#!/usr/bin/env bash
#
# copyq.sh - Cài CopyQ (clipboard manager) từ kho chính thức của distro.

install_copyq() {
    printf '\n%s=== CopyQ ===%s\n' "$BOLD" "$RESET"

    if command_exists copyq; then
        warning "CopyQ đã được cài."
        copyq --version 2>/dev/null | head -n 1 || true
        return 0
    fi

    local package="copyq"
    [[ "$PKG_MANAGER" == "xbps" ]] && package="CopyQ"

    install_package "$package" "CopyQ"
}
