#!/usr/bin/env bash
#
# vscode.sh - Cài Visual Studio Code (repo chính thức Microsoft khi cần).

_vscode_install_dnf() {
    info "Nhập khóa GPG của Microsoft..."
    if ! sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc; then
        error "Không thể nhập khóa GPG của Microsoft."
        return 1
    fi

    info "Tạo repository Visual Studio Code..."
    if ! sudo tee /etc/yum.repos.d/vscode.repo >/dev/null <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
    then
        error "Không thể tạo repository Visual Studio Code."
        return 1
    fi

    install_package code "Visual Studio Code"
}

_vscode_install_apt() {
    if ! ensure_curl; then
        return 1
    fi

    info "Cài gpg (nếu chưa có)..."
    command_exists gpg || install_package gpg "gpg" || return 1

    info "Nhập khóa GPG của Microsoft..."
    sudo install -d -m 755 /etc/apt/keyrings
    if ! curl -fsSL https://packages.microsoft.com/keys/microsoft.asc |
        gpg --dearmor |
        sudo tee /etc/apt/keyrings/packages.microsoft.gpg >/dev/null
    then
        error "Không thể nhập khóa GPG của Microsoft."
        return 1
    fi
    sudo chmod 644 /etc/apt/keyrings/packages.microsoft.gpg

    info "Tạo repository Visual Studio Code..."
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |
        sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null

    _apt_update_once
    sudo apt-get update -qq || true

    install_package code "Visual Studio Code"
}

_vscode_install_zypper() {
    info "Nhập khóa GPG của Microsoft..."
    if ! sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc; then
        error "Không thể nhập khóa GPG của Microsoft."
        return 1
    fi

    info "Thêm repository Visual Studio Code..."
    sudo zypper --non-interactive ar -f https://packages.microsoft.com/yumrepos/vscode vscode || true
    sudo zypper --non-interactive refresh

    install_package code "Visual Studio Code"
}

_vscode_install_pacman() {
    info "Arch: thử cài gói 'code' (build mã nguồn mở, không có nhãn hiệu Microsoft) từ repo chính thức..."
    if install_package code "Visual Studio Code (OSS build)"; then
        return 0
    fi

    warning "Không cài được qua pacman. Bản chính thức của Microsoft (visual-studio-code-bin)"
    warning "chỉ có trên AUR — cần AUR helper (paru/yay), ví dụ:"
    warning "  paru -S visual-studio-code-bin"
    return 1
}

install_vscode() {
    printf '\n%s=== Visual Studio Code ===%s\n' "$BOLD" "$RESET"

    if command_exists code; then
        warning "Visual Studio Code đã được cài."
        code --version | head -n 1 || true
        return 0
    fi

    case "$PKG_MANAGER" in
        dnf)    _vscode_install_dnf ;;
        apt)    _vscode_install_apt ;;
        zypper) _vscode_install_zypper ;;
        pacman) _vscode_install_pacman ;;
        xbps)
            warning "Void Linux chưa có gói VS Code chính thức. Cân nhắc dùng bản Flatpak:"
            warning "  flatpak install flathub com.visualstudio.code"
            return 1
            ;;
        *)
            error "Package manager không được hỗ trợ: ${PKG_MANAGER}"
            return 1
            ;;
    esac
}
