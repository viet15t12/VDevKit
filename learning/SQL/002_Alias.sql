--ALIAS CÁC CỘT
-- SELECT column_name AS alias_name FROM table_name;
-- Đặt tên thay thế cho các cột.
-- Giúp cho việc đọc và hiểu câu lệnh SQL dễ dàng hơn

-- ALIAS TÊN BẢNG
-- SELECT column_name(s)
-- FROM table_name AS alias_name;
-- Đặt tên thay thế cho các bảng.
-- Giúp cho việc đọc và hiểu câu lệnh SQL dễ dàng hơn

-- VÍ DỤ 1
-- Viết câu lệnh SQL lấy "CompanyName” và đặt tên thay thế là “Công ty”;
-- "PostalCode" và đặt tên thay thế là “Mã bưu điện”
SELECT company_name AS "cong ty", postal_code AS "ma buu dien"
FROM customers;

--VÍ DỤ 2
-- Viết câu lệnh lấy ra "LastName" và đặt tên thay thế là "Họ";
-- "FirstName” và đặt tên thay thế là “Tên”.
SELECT last_name as "ho",
       first_name as "ten"
FROM employees;

--VÍ DỤ 3
-- Viết câu lệnh SQL lấy ra 15 dòng đầu tiên tất cả các cột trong bảng Orders,
-- đặt tên thay thế cho bảng Orders là "o".
SELECT *
FROM orders AS O
LIMIT  15;

--BÀI TẬP
-- Viết câu lệnh SQL lấy ra các cột và đặt tên thay thế như sau:
-- ProductName => Tên sản phẩm
-- SupplierID => Mã nhà cung cấp
-- CategoryID => Mã thể loại
-- Và đặt tên thay thế cho bảng Products là “p”, sử dụng tên thay thế khí truy vấn các cột bên trên.
-- Và chỉ lấy ra 5 sản phẩm đầu tiên trong bảng.
SELECT product_name AS "Tên sản phẩm",
       supplier_id AS "Mã nhà cung cấp",
       category_id AS "Mã thể loại"
FROM products
LIMIT 5;

