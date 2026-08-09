# Kiểm tra xem chuỗi có phải là palindrome hay không bằng hai con trỏ.
def checkPalindrome(inputString):
    l = 0
    r = len(inputString) - 1
    while not (l > r):
        if inputString[l] != inputString[r]:
            return False
        l += 1
        r -= 1
    return True
