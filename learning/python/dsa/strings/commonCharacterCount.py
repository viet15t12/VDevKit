# Đếm số ký tự chung giữa hai chuỗi bằng cách đếm tần suất từng ký tự.
def commonCharacterCount(s1, s2):
    a = [0] * 256
    b = [0] * 256

    for c in s1:
        a[ord(c)] += 1
    for c in s2:
        b[ord(c)] += 1

    d = 0
    for i in range(ord("a"), ord("z") + 1):
        d += min(a[i], b[i])

    return d
