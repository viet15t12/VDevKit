# Mã hóa chuỗi bằng cách nhóm các ký tự lặp lại.
def lineEncoding(s):
    res = ""
    s = s + " "
    k = 1
    i = 0
    while s[i] != " ":
        if s[i] == s[i + 1]:
            k += 1
        else:
            if k > 1:
                res += str(k) + s[i]
            else:
                res = res + s[i]
            k = 1
        i += 1
    return res
