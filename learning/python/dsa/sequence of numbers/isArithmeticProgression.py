def isArithmeticProgression(sequence):
    d =sequence[0]
    x=sequence [1] - d

    for i in range(2,len(sequence)):
        if not (d + i*x == sequence[i]):
            return False
    return True

s =[-10, -5, 0]
print(isArithmeticProgression(s))