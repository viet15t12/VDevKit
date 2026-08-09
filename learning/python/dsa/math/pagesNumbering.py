# Tính tổng số chữ số cần dùng để đánh số từ 1 đến n.
def pagesNumbering(n):
    digits = len(str(n))
    ans = 0

    for k in range(1, digits):
        ans += 9 * (10 ** (k - 1)) * k

    ans += (n - 10 ** (digits - 1) + 1) * digits

    return ans
