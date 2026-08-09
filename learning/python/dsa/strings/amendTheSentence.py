# Chuyển chuỗi CamelCase về dạng chữ thường và thêm khoảng trắng giữa các từ.
def amendTheSentence(s):
    res = ""
    res += s[0]
    for ch in s[1:]:
        if ch.isupper():
            res = res + " "
        res += ch
    return res.lower()
