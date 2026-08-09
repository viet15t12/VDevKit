def chessKnight(Cell):
    k1 = [1, 2, 2, 1, -1, -2, -2, -1]
    k2 = [2, 1, -1, -2, -2, -1, 1, 2]

    d = 0

    for i in range(len(k1)):
        new_col = chr(ord(Cell[0]) + k1[i])  # cột mới, dạng ký tự
        new_row = int(Cell[1]) + k2[i]  # hàng mới, dạng số

        if ("a" <= new_col <= "h") and (1 <= new_row <= 8):
            d += 1

    return d
