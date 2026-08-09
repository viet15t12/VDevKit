# Đếm số giá trị khác nhau trong bảng nhân n x m.
def differentValuesInMultiplicationTable2(n, m):
    res = set()
    for i in range(1, n + 1):
        for j in range(1, m + 1):
            res.add(i * j)
    return len(res)


print(differentValuesInMultiplicationTable2(3, 2))
