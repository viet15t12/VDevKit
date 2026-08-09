# Đếm số xâu con khác nhau của một chuỗi.
def differentSubstringsTrie(inputString):
    mySet = set()

    for i in range(len(inputString)):
        for j in range(i + 1, len(inputString) + 1):
            mySet.add(inputString[i:j])

    return len(mySet)


print(differentSubstringsTrie("abac"))
