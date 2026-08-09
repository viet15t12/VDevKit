#!/usr/bin/env bash
#
# obs.sh - Cài OBS Studio từ kho chính thức của distro.

install_obs() {
    printf '\n%s=== OBS Studio ===%s\n' "$BOLD" "$RESET"

    if command_exists obs; then
        warning "OBS Studio đã được cài."
        return 0
    fi

    install_package obs-studio "OBS Studio"
}
