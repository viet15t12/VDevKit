def makeArrayConsecutive(sequence):
    n = min(sequence)
    m = max(sequence)
    result = []
    for i in range(n,m):
        if i not in sequence:
            result.append(i)
    return result

s = [-1, 3]




print(makeArrayConsecutive(s))