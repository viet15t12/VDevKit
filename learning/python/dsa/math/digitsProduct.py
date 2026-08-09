# Tạo số nhỏ nhất từ tích các chữ số bằng cách phân tích thừa số.
def digitsProduct(product):
    if product == 1:
        return 1
    if product == 0:
        return 10

    ans = 0

    for i in range(9, 1, -1):
        while product % i == 0:
            ans = ans * 10 + i
            product //= i

    if product != 1:
        return -1

    rev = 0
    while ans:
        rev = rev * 10 + ans % 10
        ans //= 10

    return rev
