def truncateString(s):
    l = 0
    r = len(s) - 1
    while s[l : r + 1] != "" and not r < l:
        if int(s[l]) % 3 == 0:
            l += 1
        elif int(s[r]) % 3 == 0:
            r -= 1
        elif (int(s[r]) + int(s[l])) % 3 == 0:
            r -= 1
            l += 1
        else: return s[l:r+1]
    return s[l:r+1]
