# Đếm số ký tự khác nhau trong chuỗi.
def differentSymbolsNaive(s):
    ls = [x for x in s]
    ls.sort()
    d = 1
    for i in range(1, len(s)):
        if ls[i] != ls[i - 1]:
            d += 1
    return d


print(differentSymbolsNaive("bcaba"))
