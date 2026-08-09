

def longestSequence(a):
    n = len(a)

    # Trường hợp đặc biệt: mảng chỉ có 1 phần tử
    # -> không có cặp (i, j) nào để xét, dãy con dài nhất chính là 1 phần tử đó
    if n <= 1:
        return n

    # Khởi tạo bảng dp kích thước n x n, mọi cặp (i, j) hợp lệ mặc định = 2
    # (vì bất kỳ 2 phần tử nào cũng luôn tạo thành 1 "cấp số cộng" độ dài 2)
    dp = [[2] * n for _ in range(n)]

    answer = 2  # vì n >= 2 nên đáp số tối thiểu luôn là 2

    # Duyệt j từ trái sang phải, j là phần tử "cuối cùng" đang xét
    for j in range(1, n):
        # i là phần tử "áp chót", đứng trước j
        for i in range(j):
            d = a[j] - a[i]  # công sai giữa a[i] và a[j]

            # Tìm k < i sao cho a[i] - a[k] == d
            # Nếu tìm thấy nhiều k, ta muốn lấy dp[k][i] lớn nhất
            # để dp[i][j] = dp[k][i] + 1 đạt giá trị lớn nhất
            for k in range(i):
                if a[i] - a[k] == d:
                    # a[k], a[i], a[j] nối tiếp được -> nối dài dãy dp[k][i]
                    if dp[k][i] + 1 > dp[i][j]:
                        dp[i][j] = dp[k][i] + 1

            # Cập nhật đáp số lớn nhất toàn cục
            if dp[i][j] > answer:
                answer = dp[i][j]

    return answer