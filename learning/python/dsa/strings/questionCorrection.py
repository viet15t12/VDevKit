# Sửa câu hỏi bằng cách chuẩn hóa dấu câu và loại bỏ ký tự không hợp lệ.
import re


def questionCorrection(question):
    s = question

    # 1. Luật chung: chỉ giữ chữ cái, chữ số, dấu phẩy, dấu cách, dấu hỏi.
    #    Kí tự khác -> thay bằng dấu cách
    s = re.sub(r"[^a-zA-Z0-9, ?]", " ", s)

    # 2. Luật dấu hỏi: tạm thời bỏ HẾT các dấu ? hiện có
    #    (vì "?" giữa câu phải bị thay bằng dấu cách, còn "?" cuối câu
    #    sẽ tự thêm lại ở bước cuối cùng nên không cần giữ dấu ? nào lúc này)
    s = s.replace("?", " ")

    # 3. Luật dấu phẩy - gộp các dấu phẩy liên tiếp (có thể xen kẽ dấu cách)
    #    thành 1 dấu phẩy duy nhất, vd: "a,, b" hoặc "a , , b" -> "a, b"
    s = re.sub(r"[ ,]*,[ ,]*", ",", s)

    # 4. Sau mỗi dấu phẩy luôn có đúng 1 dấu cách
    s = re.sub(r",", ", ", s)

    # 5. Luật dấu cách: gộp nhiều dấu cách liên tiếp thành 1, xóa đầu/cuối
    s = re.sub(r"\s+", " ", s).strip()

    # 6. Xóa dấu phẩy đứng ở đầu câu (vì trước nó không có chữ cái/chữ số)
    while s.startswith(","):
        s = s[1:].strip()

    # 7. Xóa dấu phẩy/dấu cách thừa ở cuối câu
    #    (vì trước dấu ? kết thúc luôn phải là chữ cái hoặc chữ số)
    while s.endswith(",") or s.endswith(" "):
        s = s[:-1]
    s = s.strip()

    # 8. Luật hoa/thường: chữ cái đầu câu viết hoa, còn lại viết thường
    if s:
        s = s[0].upper() + s[1:].lower()

    # 9. Luôn kết thúc câu bằng đúng 1 dấu ?
    s = (s + "?") if s else "?"

    return s
