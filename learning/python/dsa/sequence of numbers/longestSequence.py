def longestSequence(a):
    n = len(a)
    if n <= 2:
        return n

    ans = 0

    for i in range(n - 2):
        for j in range(i + 1, n - 1):
            diff = a[j] - a[i]
            if diff == 0:
                continue

            length = 2
            last = a[j]

            for k in range(j + 1, n):
                if a[k] - last == diff:
                    last = a[k]
                    length += 1

            ans = max(ans, length)

    return ans