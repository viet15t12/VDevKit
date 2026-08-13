// ============================================================
// Buổi 3 — Thiết bị phần cứng và quy trình boot Linux
// Ghi chép tổng hợp từ slide + transcript buổi học
// ============================================================

#import "../style.typ": *

= Buổi 3 — Thiết bị phần cứng và quy trình boot Linux

== Tổng quan buổi học

Nội dung chính của buổi 3 tập trung vào hai nhóm kiến thức:

- Quy trình khởi động hệ điều hành Linux và cách xác định lỗi theo từng giai đoạn.
- Nhận diện, kiểm tra thiết bị phần cứng và tài nguyên hệ thống bằng các lệnh Linux.

#key[
Thứ tự 4 giai đoạn cần nhớ:

*BIOS / UEFI → GRUB Bootloader → Linux Kernel → systemd (PID 1)*
]

== Quy trình boot Linux — 4 giai đoạn

#table(
  columns: (0.55fr, 1.25fr, 2.9fr),
  stroke: 0.5pt + linecol,
  th([Bước]),
  th([Thành phần]),
  th([Nhiệm vụ chính]),

  cell([*1*]),
  cell([*BIOS / UEFI*]),
  cell([
    Chạy POST để kiểm tra phần cứng. BIOS đọc khu vực boot theo MBR;
    UEFI tìm file boot `.efi` trong phân vùng ESP.
  ]),

  cell([*2*]),
  cell([*GRUB2 Bootloader*]),
  cell([
    Hiển thị menu boot, cho phép chọn hệ điều hành/kernel và nạp
    Linux Kernel cùng `initramfs` vào RAM.
  ]),

  cell([*3*]),
  cell([*Linux Kernel*]),
  cell([
    Giải nén Kernel, sử dụng `initramfs` để có driver cần thiết,
    tìm và mount root filesystem thật, sau đó tiếp tục khởi tạo hệ thống.
  ]),

  cell([*4*]),
  cell([*systemd (PID 1)*]),
  cell([
    Khởi chạy tiến trình mẹ `systemd`, kích hoạt các services/targets
    và đưa hệ thống đến trạng thái làm việc/login.
  ]),
)

=== Ý nghĩa khi troubleshooting

Việc nhớ đúng 4 giai đoạn giúp khoanh vùng lỗi nhanh hơn:

- Dừng rất sớm ở BIOS/UEFI → ưu tiên kiểm tra firmware/phần cứng.
- Hiện GRUB nhưng không boot tiếp → kiểm tra khu vực bootloader/cấu hình GRUB.
- Qua GRUB nhưng xuất hiện lỗi trong lúc Kernel khởi động → kiểm tra Kernel,
  `initramfs`, driver, root filesystem và boot log.
- Kernel lên nhưng dịch vụ/login gặp vấn đề → kiểm tra `systemd` và các unit/service.

#note(
  "Tư duy xử lý lỗi",
  [
    Trước khi sửa lỗi, xác định máy đang dừng ở *giai đoạn nào*.
    Đây là cách rút ngắn phạm vi troubleshooting thay vì kiểm tra toàn hệ thống.
  ],
  color: purple,
)

== Firmware: BIOS và UEFI

=== BIOS / UEFI làm gì?

Firmware là lớp đầu tiên được chạy khi cấp nguồn. Nó kiểm tra phần cứng,
chuẩn bị môi trường ban đầu và chuyển quyền điều khiển sang bootloader.

POST (*Power-On Self-Test*) được dùng để kiểm tra phần cứng cơ bản trước khi boot.

=== So sánh BIOS (Legacy) và UEFI (Modern)

#table(
  columns: (1.3fr, 2.35fr, 2.35fr),
  stroke: 0.5pt + linecol,
  th([Tiêu chí]),
  th([BIOS — Legacy Firmware]),
  th([UEFI — Modern Firmware]),

  cell([*Kiểu phân vùng*]),
  cell([
    Theo slide: dùng *MBR (Master Boot Record)*,
    tối đa 4 primary partitions.
  ]),
  cell([
    Theo slide: hỗ trợ *GPT (GUID Partition Table)*,
    tối đa 128 phân vùng chính.
  ]),

  cell([*Giới hạn dung lượng*]),
  cell([
    Theo slide: tối đa khoảng *2 TB*.
  ]),
  cell([
    Theo slide: tối đa khoảng *9.4 ZB*.
  ]),

  cell([*Kiến trúc / chế độ*]),
  cell([
    16-bit Real Mode, không gian bộ nhớ rất hạn chế.
  ]),
  cell([
    32-bit hoặc 64-bit, môi trường firmware hiện đại hơn.
  ]),

  cell([*Boot security*]),
  cell([
    Không có cơ chế Secure Boot.
  ]),
  cell([
    Hỗ trợ *Secure Boot*.
  ]),

  cell([*Boot / giao diện*]),
  cell([
    Mô hình legacy, giao diện đơn giản.
  ]),
  cell([
    Có thể có giao diện đồ họa và cơ chế boot linh hoạt hơn.
  ]),
)

#warn[
Bảng trên giữ nguyên các con số/ý chính theo slide buổi học.
Mục tiêu của phần này là nhớ sự khác nhau giữa *MBR ↔ GPT*,
*Legacy BIOS ↔ UEFI* và việc UEFI hỗ trợ *Secure Boot*.
]

== GRUB2 và initramfs

=== Vai trò của GRUB2

GRUB2 là bootloader được dùng để:

- Hiển thị menu boot.
- Chọn hệ điều hành hoặc kernel.
- Nạp `vmlinuz` (Linux Kernel) vào bộ nhớ.
- Nạp `initramfs` / `initrd`.
- Truyền các tham số kernel cần thiết trước khi chuyển quyền điều khiển cho Kernel.

=== Các file thường thấy trong `/boot`

Ảnh thực hành trong buổi học cho thấy `/boot` có các thành phần như:

- `vmlinuz-<version>` — ảnh Linux Kernel.
- `initrd.img-<version>` — initial RAM disk / initramfs.
- `System.map-<version>` — symbol map của Kernel.
- `config-<version>` — cấu hình build Kernel.
- `grub/` — thư mục dữ liệu/cấu hình GRUB.
- Các symlink như `vmlinuz`, `initrd.img`, `vmlinuz.old`, `initrd.img.old`.

#command(
  "Quan sát thư mục boot",
  [
    `ll /boot/`
    \
    `ll /boot/grub/`
  ],
)

=== Cấu hình GRUB2

Theo slide:

- File cấu hình GRUB đang dùng: `/boot/grub/grub.cfg`
- Cấu hình được sinh từ:
  - `/etc/default/grub`
  - `/etc/grub.d/`

Ảnh demo `/etc/default/grub` có các biến như:

- `GRUB_TIMEOUT`
- `GRUB_DEFAULT`
- `GRUB_DISABLE_SUBMENU`
- `GRUB_TERMINAL_OUTPUT`
- `GRUB_CMDLINE_LINUX`
- `GRUB_DISABLE_RECOVERY`
- `GRUB_ENABLE_BLSCFG`

#note(
  "Quan sát từ bài demo",
  [
    Khi mở `/etc/default/grub` bằng user không có quyền ghi,
    nano hiển thị trạng thái *“File '/etc/default/grub' is unwritable”*.
  ],
  color: orange,
)

=== initramfs dùng để làm gì?

`initramfs` là filesystem tạm trong RAM, chứa các module/driver cần thiết
ở giai đoạn rất sớm của quá trình boot.

Nó giúp Kernel:

- Nhận diện thiết bị cần thiết để truy cập root filesystem.
- Hỗ trợ các kiểu lưu trữ/phân vùng cần driver trước khi root thật được mount.
- Tìm root filesystem thật và chuyển sang filesystem đó để tiếp tục boot.

#key[
Chuỗi cần nhớ ở giai đoạn GRUB:

*GRUB → nạp `vmlinuz` + `initramfs` → Kernel khởi chạy → tìm root filesystem thật*
]

== Phân tích Boot và Kernel Log

=== `systemd-analyze`

Các lệnh xuất hiện trong slide:

#table(
  columns: (2.1fr, 3.9fr),
  stroke: 0.5pt + linecol,
  th([Lệnh]),
  th([Ý nghĩa]),

  cell([`systemd-analyze`]),
  cell([Xem tổng thời gian khởi động Kernel + userspace.]),

  cell([`systemd-analyze blame`]),
  cell([Liệt kê các unit/dịch vụ theo thời gian khởi động; dùng để tìm thành phần làm boot chậm.]),

  cell([`systemd-analyze critical-chain`]),
  cell([Hiển thị chuỗi phụ thuộc quan trọng trong quá trình khởi động.]),

  cell([`systemd-analyze plot > boot.svg`]),
  cell([Xuất sơ đồ timeline quá trình boot thành file SVG.]),
)

=== `dmesg` — thông điệp Kernel

`dmesg` dùng để xem ring buffer / thông điệp của Kernel, đặc biệt hữu ích khi
kiểm tra quá trình nhận diện phần cứng và lỗi trong lúc boot.

#table(
  columns: (2fr, 4fr),
  stroke: 0.5pt + linecol,
  th([Lệnh]),
  th([Mục đích]),

  cell([`dmesg -T`]),
  cell([Hiển thị log Kernel với mốc thời gian dễ đọc hơn.]),

  cell([`dmesg | less`]),
  cell([Duyệt log Kernel theo từng trang.]),

  cell([`dmesg -l err`]),
  cell([Lọc thông điệp mức Error.]),

  cell([`dmesg -l warn`]),
  cell([Lọc thông điệp mức Warning.]),
)

== Quản lý log bằng `journalctl`

`journalctl` là công cụ đọc log của systemd journal. Trong bài học,
nó được dùng để xem log theo lần boot, kernel, unit và thời gian.

=== Lọc theo lần boot

#table(
  columns: (2fr, 4fr),
  stroke: 0.5pt + linecol,
  th([Lệnh]),
  th([Ý nghĩa]),

  cell([`journalctl -b`]),
  cell([Xem log của phiên boot hiện tại.]),

  cell([`journalctl --list-boots`]),
  cell([Liệt kê các lần boot đã được lưu.]),

  cell([`journalctl -b -1`]),
  cell([Xem log của lần boot trước đó.]),

  cell([`journalctl -b -p err`]),
  cell([Lọc log mức Error trong phiên boot.]),
)

=== Nguồn log và real-time

#table(
  columns: (2fr, 4fr),
  stroke: 0.5pt + linecol,
  th([Lệnh]),
  th([Ý nghĩa]),

  cell([`journalctl -k`]),
  cell([Xem riêng log Kernel.]),

  cell([`journalctl -e`]),
  cell([Nhảy đến phần cuối journal.]),

  cell([`journalctl -f`]),
  cell([Theo dõi log liên tục theo thời gian thực.]),

  cell([`journalctl -fu sshd`]),
  cell([Theo dõi real-time log của unit `sshd`.]),
)

=== Lọc theo thời gian / unit

#table(
  columns: (2.35fr, 3.65fr),
  stroke: 0.5pt + linecol,
  th([Lệnh]),
  th([Ý nghĩa]),

  cell([`journalctl --since "1 hour ago"`]),
  cell([Xem log phát sinh trong 1 giờ gần đây.]),

  cell([`journalctl --since "08:00:00"`]),
  cell([Xem log kể từ 08:00.]),

  cell([`journalctl -u <unit>`]),
  cell([Lọc log theo một systemd unit cụ thể.]),

  cell([`journalctl -x`]),
  cell([Bổ sung thông tin giải thích từ catalog khi có.]),
)

#key[
Ba lệnh nên phản xạ nhanh khi troubleshooting:

`journalctl -b` — log phiên boot hiện tại

`journalctl -k` — log Kernel

`journalctl -fu <unit>` — theo dõi real-time một service/unit
]

== Nhận diện thiết bị phần cứng

=== `lspci`

`lspci` liệt kê thiết bị trên bus PCI/PCIe, ví dụ:

- Card mạng.
- VGA/GPU.
- Storage controller.
- Sound card.
- Các controller PCI/PCIe khác.

Các tùy chọn trong slide:

- `lspci -v` — hiển thị chi tiết.
- `lspci -vv` — chi tiết hơn.
- `lspci -k` — xem Kernel driver/module đang xử lý thiết bị.
- `lspci -s <bus:dev>` — chọn một thiết bị PCI cụ thể.

#command(
  "Ví dụ",
  [
    `lspci`
    \
    `lspci -k`
    \
    `lspci -vv`
  ],
)

=== `lsusb`

`lsusb` liệt kê thiết bị USB đang được hệ thống nhận diện, ví dụ:

- Chuột, bàn phím.
- USB Storage.
- Webcam.
- Wi-Fi dongle.
- Các USB device khác.

Tùy chọn quan trọng:

- `lsusb -v` — thông tin chi tiết.
- `lsusb -t` — hiển thị topology theo dạng cây.
- `lsusb -d <vendor:product>` — lọc theo Vendor ID / Product ID.

=== `lsblk`

`lsblk` hiển thị block devices và cấu trúc phân vùng, ví dụ:

- HDD / SSD.
- NVMe.
- Partition.
- Mount point.

Tùy chọn trong slide:

- `lsblk -f` — filesystem type, label, UUID, mountpoint.
- `lsblk -m` — thông tin quyền/owner/group của block device.
- `lsblk -a` — hiển thị cả các block device có kích thước 0.

#command(
  "Ví dụ",
  [
    `lsblk`
    \
    `lsblk -f`
  ],
)

== UUID, mount point và `/etc/fstab`

Phần demo dùng `lsblk -f` để xem filesystem và UUID của partition.

Ý chính của bài:

- Linux có thể dùng UUID để nhận diện filesystem/partition.
- Một filesystem có thể được gắn vào một *mount point*.
- Nếu chỉ mount tạm thời, sau reboot mount đó có thể không còn.
- `/etc/fstab` được dùng để duy trì cấu hình mount khi hệ thống khởi động.

#note(
  "Luồng xử lý ổ đĩa mới trong phần giảng",
  [
    Nhận diện ổ → chuẩn bị/định dạng filesystem → tạo mount point →
    mount vào hệ thống → cấu hình `/etc/fstab` nếu muốn mount lại sau reboot.
  ],
  color: purple,
)

== Pseudo filesystem: `/proc` và `/sys`

Theo slide, `/proc` và `/sys` là các filesystem ảo cung cấp thông tin runtime
về process, hardware và device/driver.

Các file thường dùng trong bài:

- `/proc/cpuinfo` — thông tin CPU.
- `/proc/meminfo` — thông tin bộ nhớ.

#command(
  "Ví dụ",
  [
    `cat /proc/cpuinfo`
    \
    `cat /proc/meminfo`
  ],
)

== Kiểm tra RAM và dung lượng đĩa

=== `free`

Trong phần demo transcript, `free` được dùng để kiểm tra:

- Tổng RAM.
- RAM đã dùng.
- RAM còn khả dụng (`available`).
- Swap.

Phần demo có nhắc tùy chọn `-m` để hiển thị đơn vị MB.

#command(
  "Kiểm tra bộ nhớ",
  [
    `free`
    \
    `free -m`
  ],
)

#note(
  "Cách đọc nhanh",
  [
    Trong vận hành, bài giảng nhấn mạnh quan sát các cột *used*
    và *available* để biết RAM đang dùng bao nhiêu và còn có thể sử dụng bao nhiêu.
  ],
)

=== `df`

`df` dùng để xem dung lượng các filesystem đã mount.

Trong phần demo:

- `df` hiển thị thông tin dung lượng.
- `df -h` hiển thị đơn vị dễ đọc hơn.
- Cần chú ý các filesystem chứa dữ liệu thực tế như `/`, `/home` hoặc data mount.

#command(
  "Kiểm tra dung lượng filesystem",
  [
    `df`
    \
    `df -h`
  ],
)

#warn[
Slide “Cú pháp & Tùy chọn thường sử dụng” có dòng tóm tắt `df / free`
với tham số `-f / -h`; trong phần demo transcript lại sử dụng
`free -m` và `df -h`. Ghi chú này giữ cả hai nguồn để tránh làm mất
sự khác biệt trong học liệu.
]

== Bảng lệnh nhanh

#table(
  columns: (1.75fr, 1.8fr, 3.1fr),
  stroke: 0.5pt + linecol,
  th([Nhóm]),
  th([Lệnh]),
  th([Mục đích]),

  cell([Boot]),
  cell([`systemd-analyze`]),
  cell([Tổng thời gian khởi động.]),

  cell([Boot]),
  cell([`systemd-analyze blame`]),
  cell([Tìm unit/service làm boot chậm.]),

  cell([Kernel log]),
  cell([`dmesg -T`]),
  cell([Xem thông điệp Kernel với timestamp dễ đọc.]),

  cell([Journal]),
  cell([`journalctl -b`]),
  cell([Log của boot hiện tại.]),

  cell([Journal]),
  cell([`journalctl -k`]),
  cell([Log Kernel trong journal.]),

  cell([Journal]),
  cell([`journalctl -f`]),
  cell([Theo dõi log real-time.]),

  cell([PCI]),
  cell([`lspci -k`]),
  cell([Thiết bị PCI/PCIe + Kernel driver.]),

  cell([USB]),
  cell([`lsusb -t`]),
  cell([Topology USB dạng cây.]),

  cell([Storage]),
  cell([`lsblk -f`]),
  cell([Filesystem, UUID, mountpoint.]),

  cell([RAM]),
  cell([`free -m`]),
  cell([Kiểm tra RAM theo phần demo.]),

  cell([Disk]),
  cell([`df -h`]),
  cell([Dung lượng filesystem dạng dễ đọc.]),
)

== Trọng tâm ôn tập LPIC-1

#key[
Hãy nhớ chắc các ý sau:

- Trình tự boot: *BIOS/UEFI → GRUB → Kernel → systemd*.
- BIOS gắn với *MBR*; UEFI gắn với *GPT/ESP* và hỗ trợ *Secure Boot*.
- GRUB nạp *Kernel (`vmlinuz`)* và *`initramfs`*.
- `systemd` là tiến trình *PID 1* trong hệ thống được trình bày ở buổi học.
- `systemd-analyze` dùng phân tích thời gian boot.
- `dmesg` tập trung vào thông điệp Kernel.
- `journalctl` đọc systemd journal và có thể lọc theo boot, kernel, unit, thời gian.
- `lspci`, `lsusb`, `lsblk` lần lượt tập trung vào PCI/PCIe, USB và block device.
- `/proc` và `/sys` là pseudo filesystem cung cấp thông tin runtime.
- `free` kiểm tra bộ nhớ; `df` kiểm tra dung lượng filesystem đã mount.
]

== Câu hỏi tự kiểm tra

+ Bốn giai đoạn boot Linux trong bài học là gì?
+ POST chạy ở giai đoạn nào?
+ BIOS và UEFI khác nhau ở kiểu partition table như thế nào?
+ GRUB2 nạp những thành phần nào trước khi chuyển quyền cho Kernel?
+ `initramfs` có vai trò gì khi Kernel chưa truy cập được root filesystem thật?
+ `systemd-analyze blame` dùng để làm gì?
+ Khác nhau về trọng tâm giữa `dmesg` và `journalctl` là gì?
+ Dùng lệnh nào để xem log của lần boot trước?
+ Dùng lệnh nào để biết Kernel driver đang xử lý một thiết bị PCI?
+ `lsblk -f` giúp xem thêm thông tin gì?
+ Vì sao cần `/etc/fstab` nếu muốn mount ổ đĩa sau reboot?
+ Hai lệnh nào dùng để kiểm tra RAM và dung lượng filesystem?
