# Làm sạch chuỗi bằng cách loại bỏ khoảng trắng thừa.
def formatString(input):
    s = str(input)
    res = ""
    prev_space = True  # để tự động bỏ khoảng trắng đầu
    for c in s:
        if c == " ":
            if not prev_space:
                res += c
            prev_space = True
        else:
            res += c
            prev_space = False
    return res.rstrip()  # xóa khoảng trắng cuối nếu có
