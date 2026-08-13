// ============================================================
// style.typ
// Style dùng chung cho toàn bộ ghi chép LPIC (Buổi 2, 3, 4, 5, ...)
// Chỉ chứa: bảng màu + các hàm block dùng chung.
//
// Cách dùng trong mỗi file buổi (đặt trong chapters/):
//   #import "../style.typ": *
// ============================================================

#let blue = rgb("#1f9ee8")
#let cyan = rgb("#0ea5e9")
#let green = rgb("#16a34a")
#let orange = rgb("#d97706")
#let purple = rgb("#9333ea")
#let red = rgb("#dc2626")
#let ink = rgb("#0f172a")
#let muted = rgb("#475569")
#let linecol = rgb("#cbd5e1")
#let soft = rgb("#f1f5f9")
#let codebg = rgb("#111827")

#let note(title, body, color: blue) = block(
  width: 100%,
  fill: color.lighten(91%),
  stroke: (left: 3pt + color),
  radius: 5pt,
  inset: 10pt,
  [
    #text(weight: "bold", fill: color)[#title]
    #v(3pt)
    #body
  ],
)

#let key(body) = note(
  "Trọng tâm LPIC-1",
  body,
  color: green,
)

#let warn(body) = note(
  "Lưu ý",
  body,
  color: orange,
)

#let command(title, body) = block(
  width: 100%,
  fill: codebg,
  radius: 6pt,
  inset: 10pt,
  [
    #text(fill: cyan, weight: "bold")[#title]
    #v(4pt)
    #text(fill: white, size: 9.2pt)[#body]
  ],
)

#let th(body) = table.cell(
  fill: rgb("#e2e8f0"),
  inset: 7pt,
  text(weight: "bold", fill: ink)[#body],
)

#let cell(body) = table.cell(
  inset: 7pt,
  body,
)
