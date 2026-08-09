# Kiểm tra xem các phần tử trong mảng có xuất hiện với cùng tần suất không.
def checkEqualFrequency(inputArray):
    arr = sorted(inputArray)
    n = len(arr)

    if n <= 1:
        return True

    k = 1

    # Đếm nhóm đầu tiên
    while k < n and arr[k] == arr[k - 1]:
        k += 1

    # Nếu tất cả phần tử giống nhau
    if k == n:
        return True

    d = 1

    # Đếm các nhóm tiếp theo
    for i in range(k + 1, n):
        if arr[i] == arr[i - 1]:
            d += 1
        else:
            if d != k:
                return False
            d = 1

    # Kiểm tra nhóm cuối
    return d == k
