def is_collinear(a, b, c):
    x1, y1 = a
    x2, y2 = b
    x3, y3 = c

    return (x2 - x1) * (y3 - y1) == (y2 - y1) * (x3 - x1)

def countTriangles(x,y):
    n = len(x)
    count = 0
    for i in range(n):
        for j in range(i+1,n):
            for k in range(j+1,n):
                a = [x[i], y[i]]
                b = [x[j], y[j]]
                c = [x[k], y[k]]
                if not is_collinear(a,b,c): count += 1
    return count

x , y = [0, 0, 1, 1],[0, 1, 1, 0]
print(countTriangles(x,y))