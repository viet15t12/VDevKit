# Kiểm tra mật khẩu có đủ mạnh theo các điều kiện chữ hoa, chữ thường, số và ký tự đặc biệt không.
def checkStrongPassword(n):
    if len(n) < 6:
        return False
    p = "!@#$%^&*()-+"
    kt1 = False
    kt2 = False
    kt3 = False
    kt4 = False
    for c in n:
        if c.islower():
            kt1 = True
        if c.isupper():
            kt2 = True
        if c in p:
            kt3 = True
        if c.isdigit:
            kt4 = True
    return kt1 and kt2 and kt3 and kt4
