--Câu lệnh SELECT DISTINCT
-- SELECT DISTINCT column1, column2,...
-- FROM table_name;
-- Lấy các dữ liệu riêng biệt, không trùng lặp

--VÍ DỤ 1 Viết câu lệnh SQL lấy ra tên các quốc gia (Country) khác nhau từ bảng khách hàng - Customers
SELECT DISTINCT country
FROM customers;

--VÍ DỤ 2 Viết câu lệnh SQL lấy ra tên các mã số bưu điện (PostalCode) khác nhau
--từ bảng Nhà cung cấp - Suppliers
SELECT postal_code
FROM suppliers;

--VÍ DỤ 3 Viết câu lệnh SQL lấy ra các dữ liệu khác nhau về họ của nhân viên (LastName)
-- và cách gọi danh hiệu lịch sự (TitleOfCourtesy) của nhân viên từ bảng Employees
SELECT DISTINCT last_name, title_of_courtesy
FROM employees;

-- BÀI TẬP: Viết câu lệnh SQL lấy ra mã đơn vị vận chuyển (Ship Via) khác nhau của các đơn hang - Orders
SELECT DISTINCT  ship_via
FROM orders;