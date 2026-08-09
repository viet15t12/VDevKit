#!/usr/bin/env bash
#
# lotus.sh - Cài Fcitx5 Lotus (bộ gõ tiếng Việt) + cấu hình môi trường.

_lotus_autostart_hint() {
    local de="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-}}"

    case "$de" in
        *GNOME*)
            printf '  GNOME Tweaks → Startup Applications → Add → Fcitx 5\n' ;;
        *KDE*)
            printf '  System Settings → Autostart → Add... → Add Application... → Fcitx 5\n' ;;
        *XFCE*)
            printf '  Settings → Session and Startup → Application Autostart → Add → Fcitx 5\n' ;;
        *Cinnamon*)
            printf '  System Settings → Startup Applications → + → Choose application → Fcitx 5\n' ;;
        *MATE*)
            printf '  Control Center → Startup Applications → Add (Name: Fcitx 5, Command: fcitx5)\n' ;;
        *Pantheon*)
            printf '  System Settings → Applications → Startup → Add Startup App... → Fcitx 5\n' ;;
        *Budgie*)
            printf '  Budgie Desktop Settings → Autostart → + → Add application → Fcitx 5\n' ;;
        *LXQt*)
            printf '  LXQt Configuration Center → Session Settings → Autostart → LXQt Autostart → Add (Name: Fcitx 5, Command: fcitx5)\n' ;;
        *COSMIC*)
            printf '  COSMIC Settings → Applications → Startup Applications → Add app → Fcitx 5\n' ;;
        *i3*)
            printf "  Thêm 'exec --no-startup-id fcitx5 -d' vào ~/.config/i3/config\n" ;;
        *sway*|*Sway*)
            printf "  Thêm 'exec --no-startup-id fcitx5 -d' vào ~/.config/sway/config\n" ;;
        *[Hh]yprland*)
            printf "  Thêm 'exec-once = fcitx5 -d' vào ~/.config/hypr/hyprland.conf\n" ;;
        *[Nn]iri*)
            printf '  Thêm spawn-sh-at-startup "fcitx5 -d" vào ~/.config/niri/config.kdl\n' ;;
        *)
            warning "  Không nhận diện được desktop environment (XDG_CURRENT_DESKTOP='${de}')."
            printf '  Tự tìm mục "Startup Applications"/"Autostart" trong cài đặt hệ thống và thêm fcitx5.\n' ;;
    esac
}

_lotus_wayland_hint() {
    local session_type="${XDG_SESSION_TYPE:-}"
    [[ "$session_type" == "wayland" ]] || return 0

    local de="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-}}"

    printf '\n%s=== Lưu ý Wayland ===%s\n' "$BOLD" "$RESET"
    printf '  Phiên đăng nhập hiện tại: Wayland.\n'
    printf '  Khuyến nghị chung: bật Xwayland dù chỉ dùng app Wayland native — nếu bảng\n'
    printf '  gõ client-side không hoạt động, Fcitx sẽ chuyển sang cửa sổ X11 để hiển thị\n'
    printf '  đúng vị trí thay vì một cửa sổ Wayland ngẫu nhiên.\n'

    case "$de" in
        *KDE*)
            printf '  KDE Plasma: vào System Settings → Keyboard → Virtual Keyboard → chọn Fcitx 5.\n' ;;
        *sway*|*Sway*)
            printf '  Sway: hỗ trợ text-input-v3 và zwp_input_method_v2 (từ bản 1.10+).\n'
            printf '  Qt < 6.8.2 cần QT_IM_MODULE=fcitx do Sway chưa hỗ trợ text-input-v2.\n'
            printf '  Yêu cầu Sway 1.10 trở lên.\n' ;;
        *weston*|*Weston*)
            printf '  Weston: đặt GTK_IM_MODULE=fcitx và QT_IM_MODULE=fcitx, và trong\n'
            printf '  ~/.config/weston.ini:\n'
            printf '    [core]\n    xwayland=true\n\n    [input-method]\n    path=/usr/bin/fcitx5\n'
            printf '  Do thiếu text-input-v3, IM module là giải pháp duy nhất cho Gtk/Qt.\n' ;;
        *[Nn]iri*)
            printf '  Niri: nên cài thêm xwayland-satellite (niri không hỗ trợ Xorg trực tiếp).\n' ;;
        *)
            ;;
    esac
}

_lotus_is_installed() {
    case "$PKG_MANAGER" in
        dnf)    rpm -q fcitx5-lotus >/dev/null 2>&1 ;;
        apt)    dpkg -s fcitx5-lotus >/dev/null 2>&1 ;;
        zypper) rpm -q fcitx5-lotus >/dev/null 2>&1 ;;
        pacman) pacman -Qq fcitx5-lotus-bin >/dev/null 2>&1 || pacman -Qq fcitx5-lotus-git >/dev/null 2>&1 ;;
        *)      return 1 ;;
    esac
}

_lotus_install_dnf() {
    local releasever
    releasever="$(grep '^VERSION_ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')"

    if [[ -z "$releasever" ]]; then
        error "Không xác định được VERSION_ID."
        return 1
    fi

    info "Nhập khóa GPG của Fcitx5 Lotus..."
    if ! sudo rpm --import https://fcitx5-lotus.pages.dev/pubkey.gpg; then
        error "Không thể nhập khóa GPG của Fcitx5 Lotus."
        return 1
    fi

    info "Thêm repository Fcitx5 Lotus..."
    if ! sudo dnf config-manager addrepo \
        --from-repofile="https://fcitx5-lotus.pages.dev/rpm/fedora/fcitx5-lotus-${releasever}.repo"
    then
        error "Không thể thêm repository Fcitx5 Lotus."
        return 1
    fi

    install_package fcitx5-lotus "Fcitx5 Lotus"
}

_lotus_install_apt() {
    local codename
    codename="$(grep -E '^(VERSION_CODENAME|UBUNTU_CODENAME)=' /etc/os-release | head -n1 | cut -d'=' -f2)"

    if [[ -z "$codename" ]]; then
        error "Không xác định được codename (VERSION_CODENAME/UBUNTU_CODENAME)."
        return 1
    fi

    info "Codename=${codename}"

    if ! ensure_curl; then
        return 1
    fi

    sudo mkdir -p /etc/apt/keyrings
    info "Nhập khóa GPG của Fcitx5 Lotus..."
    if ! curl -fsSL https://fcitx5-lotus.pages.dev/pubkey.gpg |
        sudo gpg --dearmor -o /etc/apt/keyrings/fcitx5-lotus.gpg
    then
        error "Không thể nhập khóa GPG của Fcitx5 Lotus."
        return 1
    fi

    info "Thêm repository Fcitx5 Lotus..."
    echo "deb [signed-by=/etc/apt/keyrings/fcitx5-lotus.gpg] https://fcitx5-lotus.pages.dev/apt/${codename} ${codename} main" |
        sudo tee /etc/apt/sources.list.d/fcitx5-lotus.list >/dev/null

    _apt_update_once
    sudo apt-get update -qq || true

    install_package fcitx5-lotus "Fcitx5 Lotus"
}

_lotus_install_zypper() {
    info "Nhập khóa GPG của Fcitx5 Lotus..."
    if ! sudo rpm --import https://fcitx5-lotus.pages.dev/pubkey.gpg; then
        error "Không thể nhập khóa GPG của Fcitx5 Lotus."
        return 1
    fi

    info "Thêm repository Fcitx5 Lotus (openSUSE Tumbleweed)..."
    sudo zypper --non-interactive ar -f \
        https://fcitx5-lotus.pages.dev/rpm/opensuse/fcitx5-lotus-tumbleweed.repo || true
    sudo zypper --non-interactive refresh

    install_package fcitx5-lotus "Fcitx5 Lotus"
}

_lotus_install_pacman() {
    if command_exists paru; then
        info "Cài fcitx5-lotus-bin qua paru (AUR)..."
        paru -S --noconfirm fcitx5-lotus-bin
    elif command_exists yay; then
        info "Cài fcitx5-lotus-bin qua yay (AUR)..."
        yay -S --noconfirm fcitx5-lotus-bin
    else
        error "Fcitx5 Lotus trên Arch chỉ có qua AUR (fcitx5-lotus-bin)."
        error "Cần cài AUR helper trước, ví dụ paru: https://github.com/Morganamilo/paru"
        return 1
    fi
}

install_lotus() {
    printf '\n%s=== Fcitx5 Lotus ===%s\n' "$BOLD" "$RESET"

    if _lotus_is_installed; then
        warning "Fcitx5 Lotus đã được cài. Script vẫn kiểm tra lại cấu hình."
    else
        case "$PKG_MANAGER" in
            dnf)    _lotus_install_dnf ;;
            apt)    _lotus_install_apt ;;
            zypper) _lotus_install_zypper ;;
            pacman) _lotus_install_pacman ;;
            xbps)
                error "Void Linux chưa có gói Fcitx5 Lotus chính thức — cần build from source."
                error "Xem hướng dẫn build tại: https://github.com/LotusInputMethod/fcitx5-lotus"
                return 1
                ;;
            *)
                error "Package manager không được hỗ trợ: ${PKG_MANAGER}"
                error "NixOS: cài qua flake, xem: https://github.com/LotusInputMethod/fcitx5-lotus"
                return 1
                ;;
        esac || return 1
    fi

    if ! command_exists systemctl; then
        warning "Không tìm thấy systemctl — hãy tự khởi động fcitx5-lotus-server theo init system của bạn."
    else
        info "Kích hoạt fcitx5-lotus-server..."
        if ! sudo systemctl enable --now "fcitx5-lotus-server@$(whoami).service"; then
            warning "Thử tạo lại system user rồi kích hoạt dịch vụ..."
            sudo systemd-sysusers || true

            if ! sudo systemctl enable --now "fcitx5-lotus-server@$(whoami).service"; then
                error "Không kích hoạt được fcitx5-lotus-server."
                return 1
            fi
        fi
    fi

    info "Tắt IBus nếu đang chạy..."
    killall ibus-daemon 2>/dev/null ||
        ibus exit 2>/dev/null ||
        warning "IBus không chạy, bỏ qua."

    info "Thiết lập biến môi trường..."
    mkdir -p "$HOME/.config/environment.d"

    cat >"$HOME/.config/environment.d/fcitx5.conf" <<'EOF'
GTK_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
QT_IM_MODULE=fcitx
QT_IM_MODULES=wayland;fcitx
GLFW_IM_MODULE=ibus
EOF

    command_exists systemctl && systemctl is-enabled "fcitx5-lotus-server@$(whoami).service" || true
    _lotus_is_installed && success "Gói fcitx5-lotus đã được xác nhận cài đặt." || true

    success "Đã hoàn tất phần cài đặt hệ thống của Fcitx5 Lotus."

    cat <<'EOF'

CÁC BƯỚC CÒN LẠI:
  1. Log out và login lại hoàn toàn.
  2. Mở: fcitx5-configtool
  3. Trong tab Input Method:
     - Tìm từ khóa: lotus
     - Đưa Lotus sang Current Input Method
     - Chọn Apply rồi OK
  4. Nhấn Ctrl+Space và thử:
       vieetj nam
     Kết quả đúng:
       việt nam
EOF

    printf '\n%s=== Bật tự khởi động cùng Desktop Environment ===%s\n' "$BOLD" "$RESET"
    _lotus_autostart_hint

    _lotus_wayland_hint

    cat <<'EOF'

Kiểm tra khi gặp lỗi:
  pgrep -a fcitx5
  fcitx5-remote
  fcitx5-diagnose | grep -i lotus
EOF
}
