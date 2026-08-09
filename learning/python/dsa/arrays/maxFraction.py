# Chọn chỉ số của phân số lớn nhất dựa trên giá trị so sánh.
def maxFraction(numerators, denominators):
    cs = 0
    for i in range(1, len(numerators)):
        if numerators[cs] * denominators[i] < numerators[i] * denominators[cs]:
            cs = i
    return cs
