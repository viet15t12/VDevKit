#!/usr/bin/env bash
#
# virt.sh - Cài virt-manager + QEMU/KVM, cấu hình libvirtd và mạng NAT mặc định.

_virt_install_packages() {
    case "$PKG_MANAGER" in
        dnf)
            info "Cài nhóm gói Virtualization (qemu-kvm, libvirt, virt-manager...)..."
            sudo dnf install -y @virtualization
            ;;
        apt)
            _apt_update_once
            info "Cài qemu-kvm, libvirt, virt-manager, bridge-utils..."
            sudo apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients \
                bridge-utils virt-manager
            ;;
        pacman)
            info "Cài qemu-full, libvirt, virt-manager, dnsmasq..."
            sudo pacman -S --noconfirm --needed qemu-full libvirt virt-manager \
                dnsmasq iptables-nft dmidecode edk2-ovmf
            ;;
        zypper)
            info "Cài pattern kvm_server + kvm_tools..."
            sudo zypper --non-interactive install -t pattern kvm_server kvm_tools
            ;;
        xbps)
            info "Cài qemu, libvirt, virt-manager..."
            sudo xbps-install -Sy qemu libvirt libvirt-python3 virt-manager dnsmasq
            ;;
        *)
            error "Package manager không được hỗ trợ: ${PKG_MANAGER}"
            return 1
            ;;
    esac
}

install_virt() {
    printf '\n%s=== virt-manager + QEMU/KVM ===%s\n' "$BOLD" "$RESET"

    if command_exists virt-manager && command_exists virsh; then
        warning "virt-manager và QEMU/KVM đã được cài."
        return 0
    fi

    info "Kiểm tra hỗ trợ ảo hóa phần cứng (CPU)..."
    if [[ -r /proc/cpuinfo ]] && ! grep -Eq '(vmx|svm)' /proc/cpuinfo; then
        warning "Không phát hiện cờ vmx/svm trong /proc/cpuinfo."
        warning "Cần bật Intel VT-x / AMD-V trong BIOS/UEFI trước khi dùng KVM."
    fi

    if ! _virt_install_packages; then
        error "Không cài được các gói virtualization."
        return 1
    fi

    if command_exists systemctl; then
        info "Kích hoạt và khởi động libvirtd..."
        if ! sudo systemctl enable --now libvirtd; then
            error "Không kích hoạt được dịch vụ libvirtd."
            return 1
        fi
    else
        warning "Không tìm thấy systemctl (distro dùng init khác) — hãy tự bật dịch vụ libvirtd."
    fi

    info "Thêm user $(whoami) vào nhóm libvirt..."
    if ! sudo usermod -aG libvirt "$(whoami)"; then
        warning "Không thêm được user vào nhóm libvirt."
    fi

    if command_exists virsh; then
        info "Kiểm tra mạng NAT mặc định (default) của libvirt..."
        if ! sudo virsh net-info default >/dev/null 2>&1; then
            sudo virsh net-define /usr/share/libvirt/networks/default.xml 2>/dev/null || true
        fi
        sudo virsh net-autostart default 2>/dev/null || true
        sudo virsh net-start default 2>/dev/null || true
    fi

    success "Đã cài xong virt-manager + QEMU/KVM."

    cat <<'EOF'

CÁC BƯỚC CÒN LẠI:
  1. Log out và login lại (hoặc reboot) để nhóm libvirt có hiệu lực.
  2. Kiểm tra hệ thống đã sẵn sàng ảo hóa:
       virt-host-validate
  3. Mở virt-manager để tạo máy ảo:
       virt-manager
EOF
}
