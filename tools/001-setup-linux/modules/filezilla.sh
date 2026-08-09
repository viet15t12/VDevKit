#!/usr/bin/env bash
#
# filezilla.sh - Cài FileZilla (SFTP/FTP client) từ kho chính thức của distro.

install_filezilla() {
    printf '\n%s=== FileZilla ===%s\n' "$BOLD" "$RESET"

    if command_exists filezilla; then
        warning "FileZilla đã được cài."
        return 0
    fi

    install_package filezilla "FileZilla SFTP client"
}
