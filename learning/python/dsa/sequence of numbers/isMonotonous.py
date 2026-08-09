def isMonotonous(sequence):
    n = len(sequence)

    if n == 1:
        return True

    if n == 2:
        return sequence[0] != sequence[1]

    for i in range(2, n):
        if (sequence[i - 1] - sequence[i - 2]) * (sequence[i] - sequence[i - 1]) <= 0:
            return False

    return True