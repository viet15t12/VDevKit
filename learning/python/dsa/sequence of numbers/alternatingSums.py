def alternatingSums(a):
    x =y=0
    for i in range(0,len(a),2): x += a[i]
    for i in range(1,len(a),2): y += a[i]
    return [x,y]

s= [50, 60, 60, 45, 70]
print(alternatingSums(s))