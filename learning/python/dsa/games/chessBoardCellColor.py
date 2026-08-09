# Kiểm tra xem hai ô trên bàn cờ có cùng màu hay không.
def chessBoardCellColor(cell1, cell2):
    color1 = (ord(cell1[0]) - ord("a") + int(cell1[1])) % 2
    color2 = (ord(cell2[0]) - ord("a") + int(cell2[1])) % 2
    return color1 == color2
