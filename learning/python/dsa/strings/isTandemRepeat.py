# Kiểm tra xem chuỗi có phải là lặp đôi hay không.
def isTandemRepeat(inputString):
    s = [c for c in inputString]
    n = len(s)
    if n % 2 == 1:
        return False
    n //= 2
    for i in range(n):
        if s[i] != s[n + i]:
            return False
    return True
