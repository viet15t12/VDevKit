# Tìm ước số nguyên tố chung lớn nhất của hai số.
from snt import snt


def greatestCommonPrimeDivisor(a, b):
    e = list(snt(min(a, b) + 1))
    e.sort(reverse=True)
    for i in e:
        if a % i == 0 and b % i == 0:
            return i
    return -1
