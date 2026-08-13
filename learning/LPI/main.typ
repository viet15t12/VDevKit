// ============================================================
// LPIC | Ghi chép tổng hợp
// File chính — import style dùng chung + gộp các buổi học.
// Biên dịch (compile) file này để ra PDF đầy đủ.
//
// Muốn thêm Buổi 4 / Buổi 5: xem hướng dẫn ở cuối file này.
// ============================================================

#import "style.typ": *

#set page(
  paper: "a4",
  margin: (x: 1.7cm, y: 1.7cm),
  numbering: "1",
)

#set text(
  size: 10.5pt,
  lang: "vi",
)

#set par(
  leading: 0.72em,
  justify: true,
)

#set heading(numbering: "1.")
#set list(indent: 1.1em, body-indent: 0.55em)

// ------------------------------------------------------------
// Trang bìa
// ------------------------------------------------------------

#align(center)[
  #v(3.1cm)

  #text(size: 15pt, weight: "bold", fill: blue)[LPIC — GHI CHÉP HỌC TẬP]

  #v(0.45cm)

  #text(size: 29pt, weight: "bold", fill: ink)[
    Tổng hợp các buổi học
  ]

  #v(0.9cm)

  #line(length: 70%, stroke: 1pt + linecol)

  #v(0.55cm)

  #text(size: 11pt, fill: muted)[
    Buổi 2 • Buổi 3
  ]

  #v(3.2cm)

  #note(
    "Mục tiêu",
    [
      Tài liệu tổng hợp ghi chép các buổi học LPIC, dùng chung một bộ
      style (màu sắc, khối ghi chú, bảng lệnh) để tiện theo dõi và ôn tập.
    ],
  )
]

#pagebreak()

#outline(title: [Mục lục], depth: 2)

#pagebreak()

// ------------------------------------------------------------
// Các buổi học — mỗi buổi là 1 file trong thư mục chapters/
// ------------------------------------------------------------

#include "chapters/buoi2.typ"

#pagebreak()

#include "chapters/buoi3.typ"

// #pagebreak()
// #include "chapters/buoi4.typ"

// #pagebreak()
// #include "chapters/buoi5.typ"

// ============================================================
// HƯỚNG DẪN THÊM BUỔI 4 / BUỔI 5
// ============================================================
// 1. Tạo file mới: chapters/buoi4.typ
//    - Dòng đầu file bắt buộc:  #import "../style.typ": *
//    - Bắt đầu nội dung bằng 1 heading cấp 1, ví dụ:
//        = Buổi 4 — <tên chủ đề>
//      Các mục con dùng == , === (không dùng lại =set page/#set text/
//      #set heading — những cái đó đã được cấu hình sẵn ở main.typ).
//    - Dùng các hàm dùng chung từ style.typ để đồng bộ giao diện:
//        note("Tiêu đề", [...])            // khối ghi chú màu xanh dương
//        key[...]                           // khối "Trọng tâm LPIC-1" (xanh lá)
//        warn[...]                          // khối "Lưu ý" (cam)
//        command("Tiêu đề", [`lệnh`])       // khối code nền tối
//        #table(columns: (...), stroke: 0.5pt + linecol,
//          th([Cột 1]), th([Cột 2]),
//          cell([...]), cell([...]),
//        )                                  // bảng lệnh đồng bộ style
//
// 2. Trong file main.typ này, bỏ comment (xóa dấu //) ở 2 dòng:
//        #pagebreak()
//        #include "chapters/buoi4.typ"
//
// 3. (Tuỳ chọn) Cập nhật dòng "Buổi 2 • Buổi 3" ở trang bìa phía trên
//    thành "Buổi 2 • Buổi 3 • Buổi 4" cho khớp nội dung.
//
// 4. Làm tương tự bước 1–3 cho chapters/buoi5.typ.
// ============================================================
