def findPath(matrix):
    y = len(matrix)
    x = len(matrix[0])
    x1 = y1 =-1
    for i in range(y):
        for j in range(x):
            if matrix[i][j] == 1:
                y1,x1 = i,j
    if x1 == -1 or y1 == -1: return False
    count = 2
    while count <= x *y:
        if 0 <= x1 +1 <x and int(matrix[y1][x1+1]) == count:
            count += 1
            x1 += 1
        elif 0 <= x1 -1 <x and int(matrix[y1][x1-1]) == count:
            count += 1
            x1 -= 1
        elif 0 <= y1 +1 <y and int(matrix[y1+1][x1]) == count:
            count += 1
            y1 += 1
        elif 0 <= y1 -1 <y and int(matrix[y1-1][x1]) == count:
            count += 1
            y1 -= 1
        else:
            return False
    return True