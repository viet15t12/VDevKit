# Phiên bản mã hóa chuỗi dùng để thử nghiệm nhanh.
def lineEncoding(s):
    res = ""
    k = 1
    for i in range(len(s)):
        if i + 1 == len(s):
            res = res + s[i]
            if k > 1:
                res += str(k)
        else:
            if s[i] == s[i + 1]:
                k += 1
            else:
                res = res + s[i]
                if k > 1:
                    res += str(k)
                k = 1
    return res


print(lineEncoding("aabbbc"))
