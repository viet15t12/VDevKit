#!/usr/bin/env bash
#
# Linux application installer (đa distro)
#
# Hỗ trợ: Fedora/RHEL (dnf), Debian/Ubuntu (apt), Arch/Manjaro (pacman),
# openSUSE (zypper). Void (xbps) được hỗ trợ một phần — xem từng module.
#
# Bao gồm:
#   1. Visual Studio Code
#   2. CopyQ
#   3. uv
#   4. Fcitx5 Lotus
#   5. FileZilla (SFTP/FTP client)
#   6. unar
#   7. OBS Studio
#   8. Google Chrome
#   9. NVIDIA Driver (cách cài khác nhau theo distro)
#   10. virt-manager + QEMU/KVM
#   11. SSH Key cho Git/GitHub (submenu riêng: tạo key, ssh-agent,
#       config, test kết nối, kiểm tra trạng thái tổng hợp)
#
# Cấu trúc:
#   fedora-dev-installer.sh   <- main script (menu, install_all, show_status)
#   modules/common.sh         <- hàm dùng chung (log, màu, nhận diện distro,
#                                 cài gói đa distro)
#   modules/<ten-app>.sh      <- mỗi app một file install_<ten-app>(),
#                                 tự rẽ nhánh theo $PKG_MANAGER khi cần
#
# Chạy:
#   chmod +x fedora-dev-installer.sh
#   ./fedora-dev-installer.sh
#
# Lưu ý:
#   - Thư mục modules/ phải nằm cùng cấp với script này.
#   - Sau khi cài Fcitx5 Lotus, cần đăng xuất và đăng nhập lại hoàn toàn.
#   - Một số ứng dụng (VS Code chính thức, Google Chrome, Fcitx5 Lotus) trên
#     Arch chỉ có qua AUR — cần cài sẵn AUR helper (paru/yay).

set -uo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
readonly MODULES_DIR="${SCRIPT_DIR}/modules"

# ---------- Nạp các module ----------
if [[ ! -d "$MODULES_DIR" ]]; then
    printf '[ERROR] Không tìm thấy thư mục modules tại: %s\n' "$MODULES_DIR" >&2
    exit 1
fi

# common.sh phải nạp trước tiên (định nghĩa info/success/warning/error, màu, v.v.)
# shellcheck source=modules/common.sh
source "${MODULES_DIR}/common.sh"

for module in vscode copyq uv lotus filezilla unar obs chrome nvidia virt github_ssh; do
    module_file="${MODULES_DIR}/${module}.sh"
    if [[ ! -r "$module_file" ]]; then
        error "Không tìm thấy module: ${module_file}"
        exit 1
    fi
    # shellcheck source=/dev/null
    source "$module_file"
done
unset module module_file

install_all() {
    local failed=0

    printf '\n%s=== CÀI TẤT CẢ ===%s\n' "$BOLD" "$RESET"

    install_vscode || failed=$((failed + 1))
    install_copyq || failed=$((failed + 1))
    install_uv || failed=$((failed + 1))
    install_lotus || failed=$((failed + 1))
    install_filezilla || failed=$((failed + 1))
    install_unar || failed=$((failed + 1))
    install_obs || failed=$((failed + 1))
    install_chrome || failed=$((failed + 1))
    install_nvidia || failed=$((failed + 1))
    install_virt || failed=$((failed + 1))

    printf '\n'
    if (( failed == 0 )); then
        success "Đã xử lý xong tất cả ứng dụng."
    else
        warning "Hoàn tất nhưng có ${failed} mục cài đặt thất bại."
    fi
}

show_status() {
    printf '\n%s=== TRẠNG THÁI CÀI ĐẶT ===%s\n' "$BOLD" "$RESET"

    local item command_name package_name
    while IFS='|' read -r item command_name package_name; do
        if command_exists "$command_name" ||
            { [[ -n "$package_name" ]] && package_installed "$package_name"; }
        then
            printf '  %s[ĐÃ CÀI]%s %s\n' "$GREEN" "$RESET" "$item"
        else
            printf '  %s[CHƯA CÀI]%s %s\n' "$YELLOW" "$RESET" "$item"
        fi
    done <<'EOF'
Visual Studio Code|code|code
CopyQ|copyq|copyq
uv|uv|
Fcitx5 Lotus|fcitx5|fcitx5-lotus
FileZilla|filezilla|filezilla
unar|unar|unar
OBS Studio|obs|obs-studio
Google Chrome|google-chrome-stable|google-chrome-stable
NVIDIA Driver|nvidia-smi|akmod-nvidia
virt-manager/KVM|virt-manager|libvirt
EOF

    if [[ -x "$HOME/.local/bin/uv" ]] && ! command_exists uv; then
        printf '  %s[GHI CHÚ]%s uv nằm tại %s\n' \
            "$CYAN" "$RESET" "$HOME/.local/bin/uv"
    fi

    if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
        printf '  %s[GHI CHÚ]%s SSH key GitHub đã có tại %s (xem mục 11 để kiểm tra chi tiết)\n' \
            "$CYAN" "$RESET" "$HOME/.ssh/id_ed25519"
    else
        printf '  %s[GHI CHÚ]%s Chưa có SSH key GitHub, xem mục 11 để thiết lập\n' \
            "$CYAN" "$RESET"
    fi
}

show_menu() {
    clear 2>/dev/null || true

    cat <<EOF
${CYAN}${BOLD}==================================================
           LINUX APPLICATION INSTALLER
        (${DISTRO_PRETTY} — ${PKG_MANAGER})
==================================================${RESET}
  ${GREEN}1)${RESET} Cài Visual Studio Code
  ${GREEN}2)${RESET} Cài CopyQ
  ${GREEN}3)${RESET} Cài uv
  ${GREEN}4)${RESET} Cài Fcitx5 Lotus
  ${GREEN}5)${RESET} Cài FileZilla - SFTP client
  ${GREEN}6)${RESET} Cài unar
  ${GREEN}7)${RESET} Cài OBS Studio
  ${GREEN}8)${RESET} Cài Google Chrome
  ${GREEN}9)${RESET} Cài NVIDIA Driver
  ${GREEN}10)${RESET} Cài virt-manager + QEMU/KVM
  ${GREEN}11)${RESET} SSH Key cho Git/GitHub (submenu) »
  ${GREEN}12)${RESET} Cài tất cả
  ${GREEN}13)${RESET} Kiểm tra trạng thái
  ${RED}0)${RESET} Thoát
${CYAN}${BOLD}==================================================${RESET}
EOF
}

main() {
    detect_distro
    prepare_sudo

    while true; do
        show_menu
        read -rp "Nhập lựa chọn [0-13]: " choice

        case "$choice" in
            1)
                install_vscode
                pause_menu
                ;;
            2)
                install_copyq
                pause_menu
                ;;
            3)
                install_uv
                pause_menu
                ;;
            4)
                install_lotus
                pause_menu
                ;;
            5)
                install_filezilla
                pause_menu
                ;;
            6)
                install_unar
                pause_menu
                ;;
            7)
                install_obs
                pause_menu
                ;;
            8)
                install_chrome
                pause_menu
                ;;
            9)
                install_nvidia
                pause_menu
                ;;
            10)
                install_virt
                pause_menu
                ;;
            11)
                show_github_ssh_menu
                ;;
            12)
                install_all
                pause_menu
                ;;
            13)
                show_status
                pause_menu
                ;;
            0)
                success "Đã thoát ${SCRIPT_NAME}."
                exit 0
                ;;
            *)
                warning "Lựa chọn không hợp lệ: ${choice}"
                sleep 1
                ;;
        esac
    done
}

main "$@"
