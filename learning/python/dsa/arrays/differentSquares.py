# Đếm số hình vuông 2x2 khác nhau trong ma trận.
def differentSquares(matrix):
    mySet = set()
    if len(matrix) < 2 or len(matrix[0]) < 2:
        return 0
    for i in range(len(matrix) - 1):
        for j in range(len(matrix[0]) - 1):
            tmp_ls = (
                str(matrix[i][j])
                + " "
                + str(matrix[i + 1][j])
                + " "
                + str(matrix[i][j + 1])
                + " "
                + str(matrix[i + 1][j + 1])
            )
            mySet.add(tmp_ls)
    return len(mySet)
