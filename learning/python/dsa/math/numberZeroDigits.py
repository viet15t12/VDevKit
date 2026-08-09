# Đếm số chữ số 0 ở cuối của giai thừa n.
def numberZeroDigits(n):
    res = 0
    while n:
        n //= 5
        res += n
    return res
