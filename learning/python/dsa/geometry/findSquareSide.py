
def Pythagoras(x1,y1,x2,y2):
    return int(((x1-x2)**2+(y1-y2)**2))

def findSquareSide(x,y):
    c = [0]*3
    for i in range(1,4):
        c[i-1] = Pythagoras(x[0],y[0],x[i],y[i])
    res = min(c)
    return res