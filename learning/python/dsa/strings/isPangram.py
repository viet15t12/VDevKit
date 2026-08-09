# Kiểm tra xem chuỗi có chứa đủ 26 chữ cái tiếng Anh hay không.
def isPangram(sentence):
    return len({c for c in sentence.lower() if "a" <= c <= "z"}) == 26
