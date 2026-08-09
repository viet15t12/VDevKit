# Kiểm tra xem hai chuỗi có thể tạo thành chuỗi mục tiêu bằng cách thay thế từng vị trí không.
def check(l1, l2, s, n):
    for i in range(n):
        if l1[i] != s[i] and l2[i] != s[i]:
            return False
    return True


def stringsCrossover(inputArray, result):
    n = len(result)
    m = len(inputArray)
    res = 0
    for i in range(m):
        for j in range(i + 1, m):
            if check(inputArray[i], inputArray[j], result, n):
                res += 1
    return res
