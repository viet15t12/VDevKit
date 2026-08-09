def prefixSums(a):
    result = [a[0]]
    for i in range(1,len(a)):
        result.append(a[i]+result[i-1])
    return result