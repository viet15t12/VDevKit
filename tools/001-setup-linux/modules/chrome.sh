#!/usr/bin/env bash
#
# chrome.sh - Cài Google Chrome (repo/gói chính thức Google khi có thể).

_chrome_install_dnf() {
    info "Nhập khóa GPG của Google..."
    if ! sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub; then
        error "Không thể nhập khóa GPG của Google."
        return 1
    fi

    info "Tạo repository Google Chrome..."
    if ! sudo tee /etc/yum.repos.d/google-chrome.repo >/dev/null <<'EOF'
[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF
    then
        error "Không thể tạo repository Google Chrome."
        return 1
    fi

    install_package google-chrome-stable "Google Chrome"
}

_chrome_install_apt() {
    if ! ensure_curl; then
        return 1
    fi

    info "Cài gpg (nếu chưa có)..."
    command_exists gpg || install_package gpg "gpg" || return 1

    info "Nhập khóa GPG của Google..."
    sudo install -d -m 755 /etc/apt/keyrings
    if ! curl -fsSL https://dl.google.com/linux/linux_signing_key.pub |
        gpg --dearmor |
        sudo tee /etc/apt/keyrings/google-chrome.gpg >/dev/null
    then
        error "Không thể nhập khóa GPG của Google."
        return 1
    fi
    sudo chmod 644 /etc/apt/keyrings/google-chrome.gpg

    info "Tạo repository Google Chrome..."
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" |
        sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null

    _apt_update_once
    sudo apt-get update -qq || true

    install_package google-chrome-stable "Google Chrome"
}

_chrome_install_zypper() {
    info "Nhập khóa GPG của Google..."
    if ! sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub; then
        error "Không thể nhập khóa GPG của Google."
        return 1
    fi

    info "Thêm repository Google Chrome..."
    sudo zypper --non-interactive ar -f \
        https://dl.google.com/linux/chrome/rpm/stable/x86_64 google-chrome || true
    sudo zypper --non-interactive refresh

    install_package google-chrome-stable "Google Chrome"
}

install_chrome() {
    printf '\n%s=== Google Chrome ===%s\n' "$BOLD" "$RESET"

    if command_exists google-chrome-stable || command_exists google-chrome; then
        warning "Google Chrome đã được cài."
        google-chrome-stable --version 2>/dev/null || google-chrome --version 2>/dev/null || true
        return 0
    fi

    case "$PKG_MANAGER" in
        dnf)    _chrome_install_dnf ;;
        apt)    _chrome_install_apt ;;
        zypper) _chrome_install_zypper ;;
        pacman)
            warning "Arch: Google Chrome chỉ có trên AUR, cần AUR helper (paru/yay), ví dụ:"
            warning "  paru -S google-chrome"
            return 1
            ;;
        xbps)
            warning "Void Linux chưa có gói Google Chrome chính thức. Cân nhắc dùng Chromium:"
            warning "  sudo xbps-install -Sy chromium"
            return 1
            ;;
        *)
            error "Package manager không được hỗ trợ: ${PKG_MANAGER}"
            return 1
            ;;
    esac
}
