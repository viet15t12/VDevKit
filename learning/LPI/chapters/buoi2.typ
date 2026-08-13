// ============================================================
// Buổi 2 — Cấu trúc thư mục Linux & các lệnh cơ bản
// ============================================================

#import "../style.typ": *

= Buổi 2 — Cấu trúc thư mục Linux & các lệnh cơ bản

== Cấu trúc thư mục hệ thống

=== `/` — Root

Thư mục gốc của toàn bộ hệ thống file. Mọi thư mục, ổ đĩa, thiết bị đều
nằm dưới `/` (kể cả khi được mount từ ổ đĩa/phân vùng khác).

=== `/etc`

Chứa các file *cấu hình hệ thống* (configuration files) — cấu hình của
hệ điều hành và các dịch vụ/ứng dụng cài trên máy. Ví dụ: `/etc/passwd`,
`/etc/hostname`, `/etc/fstab`. Đây là các file text, thường chỉ `root`
mới có quyền sửa.

=== `/home`

Chứa thư mục cá nhân (home directory) của từng *user thường* trên hệ
thống, dạng `/home/<tên_user>`. Mỗi user chỉ có toàn quyền trong thư
mục home của mình.

=== `/root`

Thư mục home riêng của user *root* (superuser). Không nằm trong
`/home` vì lý do bảo mật/khởi động — hệ thống cần truy cập được thư
mục của root ngay cả khi `/home` (có thể ở phân vùng/ổ khác) chưa
được mount.

#v(0.5em)
#line(length: 100%, stroke: 0.5pt + linecol)
#v(0.5em)

== Các lệnh cơ bản

=== Thông tin & định vị lệnh

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + linecol,
  th([Lệnh]), th([Chức năng]),
  cell([`pwd`]), cell([In ra đường dẫn thư mục hiện tại (print working directory).]),
  cell([`pwd -L`]), cell([In đường dẫn *logic* — giữ nguyên symlink như đã `cd` vào (không resolve link).]),
  cell([`pwd -P`]), cell([In đường dẫn *vật lý* (physical) — resolve hết symlink, trả về đường dẫn thật.]),
  cell([`whatis <lệnh>`]), cell([In một dòng mô tả ngắn gọn về lệnh, lấy từ man page (tương đương `man -f`).]),
  cell([`which <lệnh>`]), cell([Tìm và in ra đường dẫn file thực thi của lệnh, theo biến `$PATH`.]),
  cell([`whereis <lệnh>`]), cell([Tìm đường dẫn file thực thi, mã nguồn (source) và man page của lệnh.]),
  cell([`type <lệnh>`]), cell([Cho biết lệnh là gì: alias, shell builtin, function, hay file thực thi (và đường dẫn nếu có).]),
)

#pagebreak()

=== Chuyển user & thoát

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + linecol,
  th([Lệnh]), th([Chức năng]),
  cell([`su <user>`]), cell([Chuyển sang user khác, *giữ nguyên môi trường (shell)* hiện tại. Không đổi thư mục làm việc/biến môi trường của user mới.]),
  cell([`su - <user>`]), cell([Chuyển sang user khác *kèm theo login shell đầy đủ* — nạp lại biến môi trường, `cd` về home directory của user đó (giống hệt như đăng nhập mới).]),
  cell([`exit`]), cell([Thoát khỏi shell hiện tại (hoặc thoát phiên `su` để quay lại user trước đó).]),
)

=== Sao chép & tắt máy

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + linecol,
  th([Lệnh]), th([Chức năng]),
  cell([`cp <src> <dst>`]), cell([Sao chép file.]),
  cell([`cp -r <src> <dst>`]), cell([Sao chép *đệ quy* (recursive) — dùng khi copy cả thư mục (kèm nội dung bên trong).]),
  cell([`shutdown`]), cell([Tắt máy theo lịch (mặc định thường sau 1 phút, tùy hệ thống).]),
  cell([`shutdown -r`]), cell([*Reboot* — tắt rồi khởi động lại máy thay vì tắt hẳn.]),
)

=== Thông tin hệ thống — `uname`

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + linecol,
  th([Lệnh]), th([Chức năng]),
  cell([`uname -a`]), cell([In *toàn bộ* thông tin hệ thống (all): kernel name, hostname, kernel release, version, machine, OS...]),
  cell([`uname -r`]), cell([In kernel *release* (phiên bản kernel, vd `6.8.0-45-generic`).]),
  cell([`uname -n`]), cell([In *nodename/hostname* của máy.]),
  cell([`uname -s`]), cell([In tên kernel (system name), vd `Linux`.]),
  cell([`uname -m`]), cell([In kiến trúc phần cứng (machine hardware), vd `x86_64`.]),
)

=== Tạo & thao tác file/thư mục

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + linecol,
  th([Lệnh]), th([Chức năng]),
  cell([`mkdir <tên>`]), cell([Tạo thư mục mới.]),
  cell([`mkdir -p <a/b/c>`]), cell([Tạo thư mục *kèm các thư mục cha* nếu chưa tồn tại (parents); không báo lỗi nếu thư mục đã có sẵn.]),
  cell([`touch <file>`]), cell([Tạo file rỗng nếu chưa có. *Nếu file đã tồn tại*, `touch` không xóa nội dung — chỉ cập nhật lại timestamp (thời gian truy cập/sửa đổi) của file về thời điểm hiện tại.]),
  cell([`mv <src> <dst>`]), cell([Di chuyển file/thư mục sang vị trí khác.]),
  cell([`mv <old> <new>`]), cell([Cũng dùng để *đổi tên* (rename) — khi đích nằm cùng thư mục nguồn, `mv` thực chất chỉ đổi tên thay vì di chuyển vật lý.]),
  cell([`rm <file>`]), cell([Xóa file.]),
  cell([`rm -rf <thư_mục>`]), cell([Xóa *đệ quy, cưỡng bức* (recursive + force) — xóa cả thư mục và nội dung bên trong, không hỏi xác nhận. #text(fill: red)[Cẩn thận: không có thùng rác, xóa là mất luôn.]]),
)

=== Wildcard (ký tự đại diện)

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + linecol,
  th([Ký tự]), th([Ý nghĩa]),
  cell([`*`]), cell([Đại diện cho *0 hoặc nhiều* ký tự bất kỳ. Vd: `*.txt` khớp mọi file đuôi `.txt`.]),
  cell([`?`]), cell([Đại diện cho *đúng 1* ký tự bất kỳ. Vd: `file?.txt` khớp `file1.txt`, `fileA.txt`... nhưng không khớp `file10.txt`.]),
)

=== Xem nội dung file

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + linecol,
  th([Lệnh]), th([Chức năng]),
  cell([`cat <file>`]), cell([In toàn bộ nội dung file ra màn hình.]),
  cell([`head -n <số> <file>`]), cell([In *N dòng đầu* của file (mặc định 10 dòng nếu không có `-n`).]),
  cell([`tail -n <số> <file>`]), cell([In *N dòng cuối* của file (mặc định 10 dòng).]),
  cell([`tail -f <file>`]), cell([Theo dõi file *theo thời gian thực* (follow) — in thêm các dòng mới ngay khi file được ghi thêm. Dùng phổ biến để xem log thực tế đang chạy, vd `tail -f /var/log/syslog`.]),
)

=== Trình soạn thảo `nano`

- Mở/tạo file: `nano <tên_file>`
- Các phím tắt hay dùng (ký hiệu `^` = phím `Ctrl`):
  - `Ctrl + O` (WriteOut): lưu file
  - `Ctrl + X`: thoát nano (nếu chưa lưu sẽ hỏi có lưu không)
  - `Ctrl + K`: cắt (cut) cả dòng hiện tại
  - `Ctrl + U`: dán (paste/uncut) dòng vừa cắt
  - `Ctrl + W`: tìm kiếm (where is) trong file
  - `Ctrl + G`: mở trợ giúp (help)
- Quy trình thường dùng: `nano file.txt` → gõ nội dung → `Ctrl+O` rồi `Enter` để lưu → `Ctrl+X` để thoát.
