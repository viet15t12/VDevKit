--TÌM GIÁ TRỊ NHỎ NHẤT
-- SELECT MIN(column_name)
-- FROM table_name;
-- Tìm ra giá trị nhỏ nhất của một cột.
-- Có thể kết hợp với ALIAS để thay đổi tên cột.

-- TÌM GIÁ TRỊ LỚN NHẤT
-- SELECT MAX(column_name)
-- FROM table_name;
-- Tìm ra giá trị lớn nhất của một cột.
-- Có thể kết hợp với ALIAS để thay đổi tên cột.

--VÍ DỤ 1
-- Viết câu lệnh SQL tìm giá thấp nhất của các sẩn phẩm trong bảng Products.
SELECT MIN(unit_price)
FROM products;

--VÍ DỤ 2
-- Viết câu lệnh lấy ra ngày đặt hàng gần đây nhất từ bảng Orders.
SELECT MAX(order_date) AS "minOrderDate"
FROM orders;

--VÍ DỤ 3
--- Viết câu lệnh SQL tìm số lượng hàng trong kho (UnitsInStock) lớn nhất.
SELECT MAX(units_in_stock) AS "maxUnitsInStock)"
FROM products;

-- BÀI TẬP 1
-- Hãy cho biết tuổi đời của nhân viên lớn nhất công ty.
-- Gợi ý: ai có ngày sinh càng nhỏ thì người đó càng lớn tuổi.

SELECT MIN(birth_date) AS "minBirthDate"
FROM employees;