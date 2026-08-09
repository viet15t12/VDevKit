def isRectangle(points):
    vectors = []
    """
    toạ độ các đường vector 
    """

    for i in range(4):
        next_i = (i + 1) % 4

        dx = points[next_i][0] - points[i][0]
        dy = points[next_i][1] - points[i][1]

        vectors.append((dx, dy))
    """
    dinh ly cosi
    """
    for i in range(4):
        x1, y1 = vectors[i]
        x2, y2 = vectors[(i + 1) % 4]

        if x1 * x2 + y1 * y2 != 0:
            return False

    return True