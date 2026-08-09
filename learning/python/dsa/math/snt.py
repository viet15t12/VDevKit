# Tạo danh sách các số nguyên tố nhỏ hơn n bằng thuật toán sàng Eratosthenes.
def snt(n):
    prime = [True] * n
    prime[0] = prime[1] = False

    i = 2
    while i * i < n:
        if prime[i]:
            for j in range(i * i, n, i):
                prime[j] = False
        i += 1

    return [i for i in range(2, n) if prime[i]]
