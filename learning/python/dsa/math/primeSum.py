# Tính tổng các số nguyên tố nhỏ hơn hoặc bằng n.
from snt import snt


def primeSum(n):

    if n < 2:
        return 0

    MOD = 22082018
    res = 0
    e = list(snt(n + 1))
    for c in e:
        res = (res + c) % MOD

    return res % MOD
