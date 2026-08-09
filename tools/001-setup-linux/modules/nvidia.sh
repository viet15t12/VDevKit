#!/usr/bin/env bash
#
# nvidia.sh - Cài driver NVIDIA. Cách cài khác nhau đáng kể tùy distro,
# nên mỗi nhánh dưới đây làm theo phương thức khuyến nghị chính thức
# của distro đó thay vì dùng chung một lệnh.

_nvidia_install_dnf() {
    info "Kích hoạt RPM Fusion (free & nonfree)..."
    if ! sudo dnf install -y \
        "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${DISTRO_VERSION}.noarch.rpm" \
        "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${DISTRO_VERSION}.noarch.rpm"
    then
        error "Không thể kích hoạt RPM Fusion."
        return 1
    fi

    info "Cài core kernel headers/dev tools cần cho akmod..."
    if ! sudo dnf install -y kernel-devel kernel-headers gcc make dkms acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig; then
        warning "Một số gói phụ trợ có thể chưa cài được, tiếp tục thử cài driver..."
    fi

    if ! install_package akmod-nvidia "NVIDIA driver (akmod-nvidia)"; then
        return 1
    fi

    info "Cài thêm NVIDIA CUDA support..."
    install_package xorg-x11-drv-nvidia-cuda "NVIDIA CUDA" || true

    cat <<'EOF'

CÁC BƯỚC CÒN LẠI (Fedora):
  1. Chờ akmod build kernel module (thường vài phút):
       sudo akmods --force
       modinfo -F version nvidia
  2. Khởi động lại máy để nạp driver:
       sudo reboot
  3. Sau khi reboot, kiểm tra:
       nvidia-smi

Lưu ý: Secure Boot phải được tắt trong BIOS, hoặc phải tự
enroll MOK key cho kernel module (akmods sẽ hướng dẫn khi build).
EOF
}

_nvidia_install_apt() {
    _apt_update_once

    if command_exists ubuntu-drivers; then
        info "Phát hiện Ubuntu — dùng ubuntu-drivers để tự chọn driver phù hợp..."
        if ! sudo ubuntu-drivers autoinstall; then
            error "ubuntu-drivers autoinstall thất bại."
            return 1
        fi
    else
        info "Cài driver NVIDIA từ kho Debian (contrib/non-free phải được bật)..."
        if ! sudo apt-get install -y nvidia-driver; then
            error "Không cài được nvidia-driver. Kiểm tra đã bật kho contrib/non-free"
            error "trong /etc/apt/sources.list chưa (Debian yêu cầu bật thủ công)."
            return 1
        fi
    fi

    cat <<'EOF'

CÁC BƯỚC CÒN LẠI (Debian/Ubuntu):
  1. Khởi động lại máy để nạp driver:
       sudo reboot
  2. Sau khi reboot, kiểm tra:
       nvidia-smi

Lưu ý: Secure Boot phải được tắt trong BIOS, hoặc tự enroll MOK key
cho kernel module nếu bật Secure Boot.
EOF
}

_nvidia_install_pacman() {
    info "Cài nvidia + nvidia-utils + nvidia-settings..."
    if ! sudo pacman -S --noconfirm --needed nvidia nvidia-utils nvidia-settings; then
        error "Không cài được driver NVIDIA qua pacman."
        return 1
    fi

    cat <<'EOF'

CÁC BƯỚC CÒN LẠI (Arch):
  1. Nếu dùng kernel không phải "linux" mặc định (vd linux-lts, linux-zen),
     cài thêm gói nvidia-dkms hoặc nvidia-<kernel> tương ứng.
  2. Khởi động lại máy để nạp driver:
       sudo reboot
  3. Sau khi reboot, kiểm tra:
       nvidia-smi

Lưu ý: Secure Boot phải được tắt trong BIOS, hoặc tự enroll MOK key
cho kernel module nếu bật Secure Boot.
EOF
}

install_nvidia() {
    printf '\n%s=== NVIDIA Driver ===%s\n' "$BOLD" "$RESET"

    if command_exists nvidia-smi; then
        warning "Driver NVIDIA có vẻ đã được cài."
        modinfo -F version nvidia 2>/dev/null || true
        return 0
    fi

    case "$PKG_MANAGER" in
        dnf)    _nvidia_install_dnf ;;
        apt)    _nvidia_install_apt ;;
        pacman) _nvidia_install_pacman ;;
        zypper)
            warning "openSUSE: cần thêm repo NVIDIA cộng đồng (khác nhau theo phiên bản)."
            warning "Khuyến nghị làm theo YaST → Software Repositories → thêm repo NVIDIA,"
            warning "hoặc xem hướng dẫn chính thức: https://en.opensuse.org/SDB:NVIDIA_drivers"
            return 1
            ;;
        xbps)
            info "Cài nvidia + nvidia-libs..."
            sudo xbps-install -Sy nvidia nvidia-libs || {
                error "Không cài được driver NVIDIA qua xbps."
                return 1
            }
            ;;
        *)
            error "Package manager không được hỗ trợ: ${PKG_MANAGER}"
            return 1
            ;;
    esac

    success "Đã cài xong phần package của NVIDIA driver."
}
