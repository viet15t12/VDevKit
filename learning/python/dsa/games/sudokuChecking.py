def check_x(x):
    check = [False] * 9

    for i in range(9):
        if x[i] != ".":
            index = int(x[i]) - 1
            if check[index]:
                return False
            check[index] = True

    return True


def check_y(grid, y):
    check = [False] * 9

    for i in range(9):
        if grid[i][y] != ".":
            index = int(grid[i][y]) - 1
            if check[index]:
                return False
            check[index] = True

    return True

def check_3x3(grid, x, y):
    check = [False] * 9

    for i in range(x, x + 3):
        for j in range(y, y + 3):
            if grid[i][j] != ".":
                index = int(grid[i][j]) - 1
                if check[index]:
                    return False
                check[index] = True

    return True

def sudokuChecking(grid):
    if grid is None or len(grid) != 9:
        return False

    if any(len(x) != 9 for x in grid):
        return False

    # Kiểm tra hàng và cột
    for i in range(9):
        if not check_x(grid[i]):
            return False

        if not check_y(grid, i):
            return False

    # Kiểm tra 9 ô 3x3
    for i in range(0, 9, 3):
        for j in range(0, 9, 3):
            if not check_3x3(grid, i, j):
                return False

    return True