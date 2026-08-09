#!/usr/bin/env bash
#
# github_ssh.sh - Thiết lập SSH Key cho Git/GitHub (đa distro).
# Dựa theo README: cài git+openssh, tạo key ED25519, ssh-agent,
# cấu hình ~/.ssh/config, set git identity, test kết nối GitHub.
#
# Cung cấp 1 submenu riêng (show_github_ssh_menu) + 1 hàm test/kiểm tra
# trạng thái tổng hợp (gh_ssh_status) để biết cái nào đã hoạt động.

readonly GH_SSH_KEY="${HOME}/.ssh/id_ed25519"
readonly GH_SSH_PUB="${HOME}/.ssh/id_ed25519.pub"
readonly GH_SSH_CONFIG="${HOME}/.ssh/config"

# ---------- 1. Cài git + openssh + wl-clipboard ----------
gh_ssh_install_deps() {
    printf '\n%s=== Cài git + openssh + wl-clipboard ===%s\n' "$BOLD" "$RESET"

    local openssh_pkgs
    case "$PKG_MANAGER" in
        dnf)    openssh_pkgs="openssh openssh-clients" ;;
        apt)    openssh_pkgs="openssh-client" ;;
        pacman) openssh_pkgs="openssh" ;;
        zypper) openssh_pkgs="openssh" ;;
        xbps)   openssh_pkgs="openssh" ;;
        *)      openssh_pkgs="openssh" ;;
    esac

    local pkgs=()
    command_exists git || pkgs+=(git)
    # shellcheck disable=SC2206
    command_exists ssh || pkgs+=($openssh_pkgs)
    command_exists wl-copy || pkgs+=(wl-clipboard)

    if [[ ${#pkgs[@]} -eq 0 ]]; then
        warning "git, openssh và wl-clipboard đều đã được cài."
        return 0
    fi

    local failed=0
    for pkg in "${pkgs[@]}"; do
        install_package "$pkg" "$pkg" || failed=$((failed + 1))
    done

    if [[ "$failed" -eq 0 ]]; then
        success "Đã cài xong dependencies."
        return 0
    fi

    warning "wl-clipboard có thể không có trên một số distro — sẽ tự dùng xclip khi copy public key nếu thiếu."
    return 1
}

# ---------- 2. Tạo thư mục ~/.ssh ----------
gh_ssh_ensure_dir() {
    printf '\n%s=== Thư mục ~/.ssh ===%s\n' "$BOLD" "$RESET"

    if [[ -d "$HOME/.ssh" ]]; then
        warning "Thư mục ~/.ssh đã tồn tại."
    else
        info "Tạo thư mục ~/.ssh..."
        mkdir -p "$HOME/.ssh"
        success "Đã tạo ~/.ssh."
    fi

    chmod 700 "$HOME/.ssh"
}

# ---------- 3. Tạo SSH Key ED25519 ----------
gh_ssh_generate_key() {
    printf '\n%s=== Tạo SSH Key ED25519 ===%s\n' "$BOLD" "$RESET"

    if [[ -f "$GH_SSH_KEY" ]]; then
        warning "Đã có key tại ${GH_SSH_KEY}, bỏ qua tạo mới."
        return 0
    fi

    local email
    read -rp "Nhập email dùng cho GitHub (vd: viet@gmail.com): " email
    if [[ -z "$email" ]]; then
        error "Email không được để trống."
        return 1
    fi

    gh_ssh_ensure_dir

    info "Đang tạo SSH key ED25519 (có thể đặt passphrase hoặc để trống)..."
    if ssh-keygen -t ed25519 -C "$email" -f "$GH_SSH_KEY"; then
        success "Đã tạo key: ${GH_SSH_KEY}"
    else
        error "Tạo SSH key thất bại."
        return 1
    fi
}

# ---------- 4. Khởi động ssh-agent & add key ----------
gh_ssh_start_agent() {
    printf '\n%s=== ssh-agent & ssh-add ===%s\n' "$BOLD" "$RESET"

    if [[ ! -f "$GH_SSH_KEY" ]]; then
        error "Chưa có SSH key tại ${GH_SSH_KEY}. Hãy tạo key trước (mục 3)."
        return 1
    fi

    if ! ssh-add -l >/dev/null 2>&1; then
        local rc=$?
        if [[ $rc -eq 2 ]]; then
            info "Không có ssh-agent đang chạy, khởi động agent mới..."
            eval "$(ssh-agent -s)" >/dev/null
        fi
    fi

    if ssh-add "$GH_SSH_KEY"; then
        success "Đã thêm key vào ssh-agent."
    else
        error "Không thêm được key vào ssh-agent."
        return 1
    fi

    info "Danh sách key hiện có trong agent:"
    ssh-add -l || true
}

# ---------- 5. Hiển thị / copy Public Key ----------
gh_ssh_show_pubkey() {
    printf '\n%s=== Public Key ===%s\n' "$BOLD" "$RESET"

    if [[ ! -f "$GH_SSH_PUB" ]]; then
        error "Không tìm thấy ${GH_SSH_PUB}. Hãy tạo key trước (mục 3)."
        return 1
    fi

    printf '%s\n' "$(cat "$GH_SSH_PUB")"

    if command_exists wl-copy; then
        wl-copy <"$GH_SSH_PUB" && success "Đã copy public key vào clipboard (wl-copy)."
    elif command_exists xclip; then
        xclip -selection clipboard <"$GH_SSH_PUB" && success "Đã copy public key vào clipboard (xclip)."
    else
        warning "Chưa có wl-copy/xclip, hãy tự copy nội dung ở trên."
    fi

    cat <<'EOF'

Dán key này vào:
  GitHub -> Settings -> SSH and GPG Keys -> New SSH key
EOF
}

# ---------- 6. Cấu hình ~/.ssh/config ----------
gh_ssh_configure_config() {
    printf '\n%s=== Cấu hình ~/.ssh/config ===%s\n' "$BOLD" "$RESET"

    gh_ssh_ensure_dir

    if [[ -f "$GH_SSH_CONFIG" ]] && grep -q '^Host github.com' "$GH_SSH_CONFIG" 2>/dev/null; then
        warning "~/.ssh/config đã có block 'Host github.com', bỏ qua ghi đè."
    else
        info "Thêm block Host github.com vào ~/.ssh/config..."
        {
            printf '\nHost github.com\n'
            printf '    HostName github.com\n'
            printf '    User git\n'
            printf '    IdentityFile %s\n' "$GH_SSH_KEY"
            printf '    IdentitiesOnly yes\n'
        } >>"$GH_SSH_CONFIG"
        success "Đã thêm cấu hình github.com vào ~/.ssh/config."
    fi

    chmod 600 "$GH_SSH_CONFIG"
}

# ---------- 7. Thiết lập git user.name / user.email ----------
gh_ssh_set_git_identity() {
    printf '\n%s=== Git user.name / user.email ===%s\n' "$BOLD" "$RESET"

    local current_name current_email name email
    current_name="$(git config --global user.name 2>/dev/null || true)"
    current_email="$(git config --global user.email 2>/dev/null || true)"

    if [[ -n "$current_name" && -n "$current_email" ]]; then
        warning "Đã cấu hình: ${current_name} <${current_email}>"
        read -rp "Đổi lại? (y/N): " confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || return 0
    fi

    read -rp "Nhập git user.name: " name
    read -rp "Nhập git user.email: " email

    if [[ -z "$name" || -z "$email" ]]; then
        error "user.name/user.email không được để trống."
        return 1
    fi

    git config --global user.name "$name"
    git config --global user.email "$email"
    success "Đã thiết lập: ${name} <${email}>"
}

# ---------- 8. Sửa quyền file ----------
gh_ssh_fix_permissions() {
    printf '\n%s=== Sửa quyền thư mục/file SSH ===%s\n' "$BOLD" "$RESET"

    [[ -d "$HOME/.ssh" ]] && chmod 700 "$HOME/.ssh"
    [[ -f "$GH_SSH_KEY" ]] && chmod 600 "$GH_SSH_KEY"
    [[ -f "$GH_SSH_PUB" ]] && chmod 644 "$GH_SSH_PUB"
    [[ -f "$GH_SSH_CONFIG" ]] && chmod 600 "$GH_SSH_CONFIG"

    success "Đã đặt lại quyền: ~/.ssh (700), key (600), .pub (644), config (600)."
}

# ---------- 9. Test kết nối GitHub ----------
gh_ssh_test_connection() {
    printf '\n%s=== Test kết nối SSH tới GitHub ===%s\n' "$BOLD" "$RESET"

    if ! command_exists ssh; then
        error "Chưa cài OpenSSH client."
        return 1
    fi

    info "Đang chạy: ssh -T git@github.com ..."
    local output
    output="$(ssh -o StrictHostKeyChecking=accept-new -o BatchMode=yes -T git@github.com 2>&1)"

    if grep -qi "successfully authenticated" <<<"$output"; then
        success "Kết nối SSH tới GitHub thành công."
        printf '%s\n' "$output"
        return 0
    fi

    warning "Chưa xác thực được với GitHub. Chi tiết:"
    printf '%s\n' "$output"

    if grep -qi "permission denied" <<<"$output"; then
        error "Permission denied — key chưa được thêm lên GitHub hoặc chưa nạp vào ssh-agent."
    fi
    return 1
}

# ---------- 10. Kiểm tra toàn bộ trạng thái (hàm test tổng hợp) ----------
gh_ssh_status() {
    printf '\n%s=== TRẠNG THÁI SSH KEY CHO GITHUB ===%s\n' "$BOLD" "$RESET"

    _gh_ssh_row() {
        local label="$1" ok="$2"
        if [[ "$ok" == "1" ]]; then
            printf '  %s[OK]%s %s\n' "$GREEN" "$RESET" "$label"
        else
            printf '  %s[THIẾU]%s %s\n' "$YELLOW" "$RESET" "$label"
        fi
    }

    command_exists git && _gh_ssh_row "git đã cài ($(git --version 2>/dev/null | head -n1))" 1 \
        || _gh_ssh_row "git chưa cài" 0

    command_exists ssh && _gh_ssh_row "OpenSSH client đã cài" 1 \
        || _gh_ssh_row "OpenSSH client chưa cài" 0

    [[ -d "$HOME/.ssh" ]] && _gh_ssh_row "Thư mục ~/.ssh tồn tại" 1 \
        || _gh_ssh_row "Thư mục ~/.ssh chưa tồn tại" 0

    [[ -f "$GH_SSH_KEY" ]] && _gh_ssh_row "Private key ${GH_SSH_KEY} tồn tại" 1 \
        || _gh_ssh_row "Private key ${GH_SSH_KEY} chưa tồn tại" 0

    [[ -f "$GH_SSH_PUB" ]] && _gh_ssh_row "Public key ${GH_SSH_PUB} tồn tại" 1 \
        || _gh_ssh_row "Public key ${GH_SSH_PUB} chưa tồn tại" 0

    if ssh-add -l >/dev/null 2>&1; then
        _gh_ssh_row "ssh-agent đang chạy và có key nạp sẵn" 1
    else
        _gh_ssh_row "ssh-agent chưa chạy hoặc chưa nạp key" 0
    fi

    [[ -f "$GH_SSH_CONFIG" ]] && grep -q '^Host github.com' "$GH_SSH_CONFIG" 2>/dev/null \
        && _gh_ssh_row "~/.ssh/config đã có block github.com" 1 \
        || _gh_ssh_row "~/.ssh/config chưa có block github.com" 0

    local gname gemail
    gname="$(git config --global user.name 2>/dev/null || true)"
    gemail="$(git config --global user.email 2>/dev/null || true)"
    if [[ -n "$gname" && -n "$gemail" ]]; then
        _gh_ssh_row "git identity: ${gname} <${gemail}>" 1
    else
        _gh_ssh_row "git identity (user.name/user.email) chưa thiết lập" 0
    fi

    unset -f _gh_ssh_row

    printf '\n'
    read -rp "Có muốn test kết nối thật tới GitHub ngay bây giờ không? (y/N): " do_test
    if [[ "$do_test" =~ ^[Yy]$ ]]; then
        gh_ssh_test_connection
    fi
}

# ---------- 11. Chạy toàn bộ từ đầu ----------
gh_ssh_full_setup() {
    printf '\n%s=== THIẾT LẬP SSH KEY CHO GITHUB - TOÀN BỘ ===%s\n' "$BOLD" "$RESET"

    gh_ssh_install_deps
    gh_ssh_ensure_dir
    gh_ssh_generate_key || return 1
    gh_ssh_start_agent
    gh_ssh_show_pubkey
    printf '\n'
    read -rp "Đã dán public key lên GitHub xong chưa? Nhấn Enter để tiếp tục test..." _
    gh_ssh_test_connection
    gh_ssh_configure_config
    gh_ssh_set_git_identity
    gh_ssh_fix_permissions

    printf '\n'
    success "Hoàn tất quy trình thiết lập SSH key cho GitHub."
}

# ---------- Submenu điều khiển ----------
show_github_ssh_menu() {
    while true; do
        clear 2>/dev/null || true
        cat <<EOF
${CYAN}${BOLD}==================================================
       SSH KEY CHO GIT / GITHUB - SUBMENU
==================================================${RESET}
  ${GREEN}1)${RESET} Cài git + openssh + wl-clipboard
  ${GREEN}2)${RESET} Tạo thư mục ~/.ssh
  ${GREEN}3)${RESET} Tạo SSH Key ED25519
  ${GREEN}4)${RESET} Khởi động ssh-agent & add key
  ${GREEN}5)${RESET} Hiển thị / copy Public Key
  ${GREEN}6)${RESET} Cấu hình ~/.ssh/config
  ${GREEN}7)${RESET} Thiết lập git user.name / user.email
  ${GREEN}8)${RESET} Sửa quyền file (chmod)
  ${GREEN}9)${RESET} Test kết nối GitHub (ssh -T)
  ${GREEN}10)${RESET} Kiểm tra toàn bộ trạng thái (test tổng hợp)
  ${GREEN}11)${RESET} Chạy toàn bộ từ đầu
  ${RED}0)${RESET} Quay lại menu chính
${CYAN}${BOLD}==================================================${RESET}
EOF
        read -rp "Nhập lựa chọn [0-11]: " gh_choice

        case "$gh_choice" in
            1) gh_ssh_install_deps; pause_menu ;;
            2) gh_ssh_ensure_dir; pause_menu ;;
            3) gh_ssh_generate_key; pause_menu ;;
            4) gh_ssh_start_agent; pause_menu ;;
            5) gh_ssh_show_pubkey; pause_menu ;;
            6) gh_ssh_configure_config; pause_menu ;;
            7) gh_ssh_set_git_identity; pause_menu ;;
            8) gh_ssh_fix_permissions; pause_menu ;;
            9) gh_ssh_test_connection; pause_menu ;;
            10) gh_ssh_status; pause_menu ;;
            11) gh_ssh_full_setup; pause_menu ;;
            0) return 0 ;;
            *)
                warning "Lựa chọn không hợp lệ: ${gh_choice}"
                sleep 1
                ;;
        esac
    done
}
