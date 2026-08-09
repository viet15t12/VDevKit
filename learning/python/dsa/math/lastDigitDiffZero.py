# Tìm chữ số cuối cùng khác 0 của giai thừa n.
def lastDigitDiffZero(n):
    res = 1
    for i in range(2, n + 1):
        res *= i
        while res % 10 == 0:
            res //= 10
        res %= 1000
    while res % 10 == 0:
        res //= 10
    return res % 10
