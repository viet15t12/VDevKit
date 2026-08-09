def spiralNumbers(n):
    # Khởi tạo ma trận NxN với giá trị 0
    matrix = [[0] * n for _ in range(n)]

    # Các biên: trên, dưới, trái, phải
    top, bottom = 0, n - 1
    left, right = 0, n - 1

    num = 1
    while top <= bottom and left <= right:
        # Đi từ trái sang phải (hàng trên)
        for i in range(left, right + 1):
            matrix[top][i] = num
            num += 1
        top += 1

        # Đi từ trên xuống dưới (cột phải)
        for i in range(top, bottom + 1):
            matrix[i][right] = num
            num += 1
        right -= 1

        # Đi từ phải sang trái (hàng dưới)
        if top <= bottom:
            for i in range(right, left - 1, -1):
                matrix[bottom][i] = num
                num += 1
            bottom -= 1

        # Đi từ dưới lên trên (cột trái)
        if left <= right:
            for i in range(bottom, top - 1, -1):
                matrix[i][left] = num
                num += 1
            left += 1

    return matrix

