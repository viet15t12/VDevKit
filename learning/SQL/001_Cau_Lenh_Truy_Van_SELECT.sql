-- Câu lệnh SELECT
-- SELECT column1, column2, ...
-- FROM table_name;
-- Câu lệnh SELECT được sử dụng để chọn dữ liệu từ cơ sở dữ liệu.
-- Dữ liệu trả về được lưu trữ trong một bảng kết quả, được gọi là tập hợp kết quả.
-- Các cột1, cột2, ... là tên trường của bảng mà bạn muốn chọn dữ liệu

-- VÍ DỤ 1 Viết câu lệnh SQL lấy ra tên của tất cả các sản phẩm
SELECT product_name
FROM products;

-- VÍ DỤ 2 Viết câu lệnh SQL lấy ra tên sản phẩm, giá bán trên mỗi đơn vị, số lượng sản phẩm trên đơn vị
SELECT product_name, unit_price, quantity_per_unit
FROM products;

-- VÍ DỤ 3 Viết câu lệnh SQL lấy ra tên công ty khách hàng và quốc gia của các khách hàng đó
SELECT company_name,country
FROM customers;

-- BÀI TẬP 1. Viết câu lệnh SQL lấy ra tên công ty và số điện thoại của tất cả các nhà cung cấp hàng.
SELECT  company_name, phone
FROM suppliers;

-- SELECT *
-- FROM table_name;
-- * : lấy tất cả các cột

--VÍ DỤ 1 Viết câu lệnh SQL lấy ra tất cả dữ liệu từ bảng Products
SELECT *
FROM products;

--VÍ DỤ 2 Viết câu lệnh SQL lấy ra tất cả dữ liệu từ bảng khách hàng - Customers
SELECT *
FROM customers;

-- BÀI TẬP 1. Viết câu lệnh SQL lấy tất cả dữ liệu từ bảng nhà cung cấp - Suppliers
SELECT *
FROM suppliers;