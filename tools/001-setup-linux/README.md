# setup-linux

Bộ công cụ cài môi trường Linux theo mô hình **Python orchestrator + Bash helpers**.
Python chịu trách nhiệm nhận diện distro, đọc cấu hình, chọn nhóm, dry-run, log và
tổng kết lỗi. Các quy trình sát hệ thống như thêm repository, cài Fcitx5 Lotus,
driver NVIDIA hoặc KVM vẫn nằm trong các module Bash đã có.

## Yêu cầu

- Python 3.10 trở lên (chỉ dùng standard library)
- `sudo` và package manager của distro
- Fedora/RHEL, Debian/Ubuntu, Arch/Manjaro, openSUSE hoặc Void Linux

## Sử dụng

Chạy menu tương tác:

```bash
python3 setup.py
```

Xem các nhóm có thể cài và mô phỏng trước khi chạy thật:

```bash
python3 setup.py --list-groups
python3 setup.py --only dev --dry-run
python3 setup.py --only base,network --dry-run
```

Cài một hoặc nhiều nhóm:

```bash
python3 setup.py --only development
python3 setup.py --only desktop --only media
python3 setup.py --all
```

`--all` không tự cài các nhóm được đánh dấu tùy chọn, hiện gồm driver NVIDIA.
Chỉ dùng `--all --include-optional` khi chắc chắn phần cứng phù hợp. Log mặc định
được ghi vào `setup-linux.log`; có thể đổi bằng `--log-file PATH`.

## Cấu trúc

```text
setup-linux/
├── setup.py                 # entry point và điều phối chính
├── config/
│   ├── common.json          # nhóm dùng chung + ánh xạ Bash helper
│   ├── fedora.json          # package riêng Fedora/RHEL
│   ├── ubuntu.json          # package riêng Debian/Ubuntu
│   └── arch.json            # package riêng Arch/Manjaro
├── installers/
│   ├── common.py            # distro detection, runner, package installer
│   ├── fedora.py
│   ├── ubuntu.py
│   ├── flatpak.py
│   └── services.py
├── modules/                 # các Bash helper đặc thù, tiếp tục tái sử dụng
└── fedora-dev-installer.sh  # menu Bash cũ, vẫn chạy độc lập
```

Config distro được merge lên `common.json`; các danh sách `packages`, `flatpaks`,
`services` và `helpers` được nối và loại trùng. Vì vậy có thể thêm package mới mà
không phải sửa code Python.

## Tương thích với luồng cũ

Menu Bash hiện hữu vẫn dùng được:

```bash
./fedora-dev-installer.sh
```

Python gọi từng module qua Bash, nên logic repository và hướng dẫn hậu cài đặt
không bị sao chép sang `subprocess.run()` trong một file lớn. Có thể chuyển dần
logic dùng chung sang `installers/` mà không cần rewrite toàn bộ repo một lần.
