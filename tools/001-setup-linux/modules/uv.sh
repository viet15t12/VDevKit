#!/usr/bin/env bash
#
# uv.sh - Cài uv (Python package manager) bằng installer chính thức Astral.

install_uv() {
    printf '\n%s=== uv ===%s\n' "$BOLD" "$RESET"

    if command_exists uv || [[ -x "$HOME/.local/bin/uv" ]]; then
        warning "uv đã được cài."
        if command_exists uv; then
            uv --version || true
        else
            "$HOME/.local/bin/uv" --version || true
        fi
        return 0
    fi

    if ! ensure_curl; then
        return 1
    fi

    info "Đang cài uv bằng installer chính thức của Astral..."
    if curl -LsSf https://astral.sh/uv/install.sh | sh; then
        success "Đã cài uv."

        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            warning 'Mở terminal mới hoặc chạy: export PATH="$HOME/.local/bin:$PATH"'
        fi

        "$HOME/.local/bin/uv" --version 2>/dev/null || true
        return 0
    fi

    error "Không cài được uv."
    return 1
}
