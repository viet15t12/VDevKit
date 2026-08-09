#!/usr/bin/env bash
#
# common.sh - Hàm dùng chung: màu hiển thị, log, nhận diện distro/package
# manager, cài gói đa distro (dnf/apt/pacman/zypper/xbps).
# Được main script `source` vào, không tự chạy độc lập.

# ---------- Màu hiển thị ----------
if [[ -t 1 ]]; then
    readonly RED=$'\033[0;31m'
    readonly GREEN=$'\033[0;32m'
    readonly YELLOW=$'\033[1;33m'
    readonly BLUE=$'\033[0;34m'
    readonly CYAN=$'\033[0;36m'
    readonly BOLD=$'\033[1m'
    readonly RESET=$'\033[0m'
else
    readonly RED=""
    readonly GREEN=""
    readonly YELLOW=""
    readonly BLUE=""
    readonly CYAN=""
    readonly BOLD=""
    readonly RESET=""
fi

info() {
    printf '%s[INFO]%s %s\n' "$BLUE" "$RESET" "$*"
}

success() {
    printf '%s[OK]%s %s\n' "$GREEN" "$RESET" "$*"
}

warning() {
    printf '%s[WARN]%s %s\n' "$YELLOW" "$RESET" "$*"
}

error() {
    printf '%s[ERROR]%s %s\n' "$RED" "$RESET" "$*" >&2
}

pause_menu() {
    printf '\n'
    read -rp "Nhấn Enter để quay lại menu..." _
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ---------- Nhận diện distro & package manager ----------
# Sau khi gọi, các biến sau sẵn sàng dùng ở mọi module:
#   DISTRO_ID       - id trong /etc/os-release (fedora, ubuntu, arch, ...)
#   DISTRO_VERSION  - VERSION_ID (vd: 40, 24.04)
#   DISTRO_PRETTY   - PRETTY_NAME để hiển thị
#   PKG_MANAGER     - dnf | apt | pacman | zypper | xbps
#   FEDORA_VERSION  - giữ lại (= DISTRO_VERSION) để tương thích ngược, chỉ
#                     có ý nghĩa thật sự khi PKG_MANAGER=dnf trên Fedora.
detect_distro() {
    if [[ ! -r /etc/os-release ]]; then
        error "Không tìm thấy /etc/os-release."
        exit 1
    fi

    # shellcheck disable=SC1091
    source /etc/os-release

    readonly DISTRO_ID="${ID:-unknown}"
    readonly DISTRO_ID_LIKE="${ID_LIKE:-}"
    readonly DISTRO_VERSION="${VERSION_ID:-unknown}"
    readonly DISTRO_PRETTY="${PRETTY_NAME:-Không xác định}"

    local pkg_manager=""
    case "$DISTRO_ID" in
        fedora|rhel|centos|rocky|almalinux)
            pkg_manager="dnf" ;;
        debian|ubuntu|linuxmint|pop|elementary|zorin)
            pkg_manager="apt" ;;
        arch|endeavouros|manjaro|cachyos|garuda)
            pkg_manager="pacman" ;;
        opensuse*|sles|sled)
            pkg_manager="zypper" ;;
        void)
            pkg_manager="xbps" ;;
        *)
            case "$DISTRO_ID_LIKE" in
                *fedora*|*rhel*) pkg_manager="dnf" ;;
                *debian*)        pkg_manager="apt" ;;
                *arch*)          pkg_manager="pacman" ;;
                *suse*)          pkg_manager="zypper" ;;
            esac
            ;;
    esac

    if [[ -z "$pkg_manager" ]]; then
        error "Không nhận diện được distro được hỗ trợ."
        error "Distro hiện tại: ${DISTRO_PRETTY} (ID=${DISTRO_ID}, ID_LIKE=${DISTRO_ID_LIKE:-không có})"
        error "Các distro/package manager được hỗ trợ: Fedora/RHEL (dnf), Debian/Ubuntu (apt),"
        error "Arch/Manjaro (pacman), openSUSE (zypper), Void (xbps)."
        exit 1
    fi

    readonly PKG_MANAGER="$pkg_manager"

    if ! command_exists "$PKG_MANAGER"; then
        error "Không tìm thấy lệnh ${PKG_MANAGER} dù distro được nhận diện là ${DISTRO_PRETTY}."
        exit 1
    fi

    # Giữ tên biến cũ để các module chưa cập nhật (hoặc script bên ngoài) vẫn chạy được.
    readonly FEDORA_VERSION="$DISTRO_VERSION"

    success "Phát hiện ${DISTRO_PRETTY} (package manager: ${PKG_MANAGER})."
}

# Tên hàm cũ, giữ lại làm alias để không phải sửa chỗ gọi ở nơi khác.
check_fedora() {
    detect_distro
}

prepare_sudo() {
    info "Yêu cầu quyền sudo..."
    if ! sudo -v; then
        error "Không thể xác thực sudo."
        exit 1
    fi
}

# ---------- Cài gói đa distro ----------
# apt cần "update" trước lần install đầu tiên trong phiên chạy script.
_APT_UPDATED=0
_apt_update_once() {
    if [[ "$_APT_UPDATED" -eq 0 ]]; then
        info "Đang chạy apt-get update..."
        sudo apt-get update -qq || warning "apt-get update thất bại, vẫn thử cài tiếp."
        _APT_UPDATED=1
    fi
}

# install_package <package> [display_name]
# Cài một gói theo package manager đã nhận diện ở detect_distro.
# Dùng khi tên gói giống nhau trên các distro; nếu tên gói khác nhau,
# module gọi hàm này với tên gói tương ứng đã chọn theo $PKG_MANAGER.
install_package() {
    local package="$1"
    local display_name="${2:-$1}"
    local ok=1

    info "Đang cài ${display_name}..."

    case "$PKG_MANAGER" in
        dnf)
            sudo dnf install -y "$package" && ok=0 ;;
        apt)
            _apt_update_once
            sudo apt-get install -y "$package" && ok=0 ;;
        pacman)
            sudo pacman -S --noconfirm --needed "$package" && ok=0 ;;
        zypper)
            sudo zypper --non-interactive install "$package" && ok=0 ;;
        xbps)
            sudo xbps-install -Sy "$package" && ok=0 ;;
        *)
            error "Package manager không xác định: ${PKG_MANAGER}" ;;
    esac

    if [[ "$ok" -eq 0 ]]; then
        success "Đã cài ${display_name}."
        return 0
    fi

    error "Không cài được ${display_name}."
    return 1
}

# Alias tương thích ngược cho các chỗ gọi cũ tên install_dnf_package.
install_dnf_package() {
    install_package "$@"
}

# package_installed <package> - kiểm tra gói đã cài qua package manager
# hiện tại (dùng cho show_status, không thay thế các check command_exists).
package_installed() {
    local package="$1"
    case "$PKG_MANAGER" in
        dnf|zypper) rpm -q "$package" >/dev/null 2>&1 ;;
        apt)        dpkg -s "$package" >/dev/null 2>&1 ;;
        pacman)     pacman -Qq "$package" >/dev/null 2>&1 ;;
        xbps)       xbps-query "$package" >/dev/null 2>&1 ;;
        *)          return 1 ;;
    esac
}

ensure_curl() {
    if command_exists curl; then
        return 0
    fi

    install_package curl "curl"
}
