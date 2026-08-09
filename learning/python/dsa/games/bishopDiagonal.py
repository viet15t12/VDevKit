def check(bishop1, bishop2):
    return abs(ord(bishop1[0]) - ord(bishop2[0])) == abs(
        int(bishop1[1]) - int(bishop2[1])
    )


def toado(bishop1):
    x = ord(bishop1[0]) - ord("a")
    y = int(bishop1[1]) - 1

    return x, y


def bishopDiagonal(bishop1, bishop2):
    if check(bishop1, bishop2):
        x1, y1 = toado(bishop1)
        x2, y2 = toado(bishop2)

        # Hướng từ tượng 1 đến tượng 2
        dx = 1 if x2 > x1 else -1
        dy = 1 if y2 > y1 else -1

        # Tượng 1 đi ngược hướng tượng 2
        while 0 <= x1 - dx < 8 and 0 <= y1 - dy < 8:
            x1 -= dx
            y1 -= dy

        # Tượng 2 tiếp tục đi theo hướng hiện tại
        while 0 <= x2 + dx < 8 and 0 <= y2 + dy < 8:
            x2 += dx
            y2 += dy

        bishop1 = chr(x1 + ord("a")) + str(y1 + 1)
        bishop2 = chr(x2 + ord("a")) + str(y2 + 1)

    return sorted([bishop1, bishop2])


print(bishopDiagonal("d7", "f5"))  # ['c8', 'h3']
print(bishopDiagonal("b1", "d3"))  # ['a0'?]
