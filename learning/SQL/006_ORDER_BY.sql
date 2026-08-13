-- ORDER BY
-- SELECT column1, column2, ...
--     FROM table_name
-- ORDER BY column1, column2, ... ASC|DESC;
-- ASC: sắp xếp tăng dần (mặc định nếu không ghi)
-- DESC: sắp xếp giảm dần.

-- VÍ DỤ 1
-- Bạn hãy liệt kê tất cả các nhà cung cấp theo thứ tự tên đơn vị CompanyName) Từ A-Z

SELECT  *
FROM suppliers
ORDER BY company_name ASC ;

-- VÍ DỤ 2
-- Bạn hãy liệt kê tất cả các sản phẩm theo thứ tự giá giảm dần.

SELECT *
FROM  products
ORDER BY unit_price DESC;

-- VÍ DỤ 3
-- Bạn hãy liệt kê tất cả các nhân viên theo thứ tự họ và tên đệm A-Z.
-- Không dùng ASC | DESC

SELECT *
FROM employees
ORDER BY last_name, first_name;

SELECT *
FROM employees
ORDER BY last_name ASC , first_name ASC;

-- VÍ DỤ 4
-- Hãy lấy ra một sản phẩm có số lượng bán cao nhất từ bảng [Order Details].
-- Không được dùng MAX.

SELECT  *
FROM order_details
order by quantity DESC
LIMIT 1 OFFSET 0;

-- BÀI TẬP 1
-- Hãy liệt kê danh sách các đơn đặt hàng (OrderID)
-- trong bảng Orders theo thứ tự giảm dần của ngày đặt hàng (OrderDate).

SELECT *
FROM orders
ORDER BY order_date DESC;

-- BÀI TẬP 2
-- Hãy liệt kê tên, đơn giá, số lượng tồn kho (UnitsInStock)
-- của tất cả các sản phẩm trong bảng Products, theo thứ tự giảm dần của UnitsInStock.
SELECT product_name,unit_price,units_in_stock
FROM products
ORDER BY units_in_stock DESC ;