# Tính tổng các ước nguyên tố của số n.
def sole(n):
    sum = 0
    i = 2
    while i * i <= n:
        while n % i == 0:
            sum += i
            n //= i
        i += 1
    if n > 1:
        sum += n
    return sum


def factorSum(n):
    while True:
        s = sole(n)
        if n == s:
            return s
        n = s
    return n
