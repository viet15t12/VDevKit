-- NOT IN
-- SELECT column_name(s)
-- FROM table_name
-- WHERE column_name NOT IN (value1, value2, ...);
-- Giá trị của column khác với các giá trị đã được chỉ định.

-- VÍ DỤ 1
-- Hãy lọc ra tất cả các đơn hàng với điều kiện:
-- a, Đơn hàng được giao đến Germany, UK, Brazil
-- b, Đơn hàng được giao đến các quốc gia khác Germany, UK, Brazil

-- SELECT *
-- FROM orders
-- WHERE ship_country = 'Germany' OR
--       ship_country = 'Brazil' OR
--       ship_country = 'UK';

SELECT *
FROM orders
WHERE ship_country IN ( 'Germany', 'Brazil', 'UK');

SELECT *
FROM orders
WHERE ship_country NOT IN ( 'Germany', 'Brazil', 'UK');

-- VÍ DỤ 2
-- Lấy ra các sản phẩm có mã thể loại khác với 2, 3 và 4.

SELECT *
FROM products
WHERE category_id NOT IN ( 2,3,4);

-- VÍ DỤ 3
-- 1. Hãy liệt kê các nhân viên không phải là nữ từ bảng nhân viên.
-- 2. Hãy liệt kê các nhân viên là nữ từ bảng nhân viên.

SELECT *
FROM employees
WHERE title_of_courtesy NOT IN ('Ms.','Mrs.');

SELECT *
FROM employees
WHERE title_of_courtesy IN ('Ms.','Mrs.');
--
-- BÀI TẬP 1
-- Hãy lấy ra tất cả các khách hàng đến từ các thành phố sau đây:
-- Berlin
-- London
-- Warszawa

SELECT *
FROM customers
WHERE city IN  ('Berlin', 'London', 'Warszawa');