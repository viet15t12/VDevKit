# Kiểm tra xem hai quân tượng và tốt có ở cùng một đường chéo không.
def bishopAndPawn(bishop, pawn):
    return (
        abs(ord(bishop[0]) - ord(pawn[0])) == abs(int(bishop[1]) - int(pawn[1]))
        and bishop[0] != pawn[0]
    )
