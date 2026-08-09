-- ĐẾM SỐ LƯỢNG – COUNT()
-- SELECT COUNT(column_name)
-- FROM table_name
-- Đếm số lượng dữ liệu (khác NULL) trong một cột.
-- Sử dụng COUNT(*) khi muốn đếm số lượng bản ghi.

-- TÍNH TỔNG – SUM()
-- SELECT SUM(column_name)
-- FROM table_name;
-- Tính tổng giá trị của một cột.
-- Nếu bất kỳ giá trị trong cột là NULL, kết quả của hàm
-- SUM sẽ là NULL.

-- TÍNH TRUNG BÌNH – AVG()
-- SELECT AVG(column_name)
-- FROM table_name;
-- Tính giá trị trung bình cho một cột.
-- Nếu tất cả các giá trị trong cột là NULL, kết quả của hàm AVG sẽ là NULL.
-- Nếu chỉ một vài giá trị là NULL, AVG sẽ bỏ qua các giá trị NULL và tính trung bình cho các giá trị khác.

-- VÍ DỤ 1
-- Hãy đếm số lượng khách hàng CÓ trong bảng (Customers).
SELECT COUNT(*) AS "NumberOfCustomers"
FROM customers;
-- Hoặc
SELECT COUNT(customer_id) AS "NumberOfCustomers"
FROM  customers;

-- VÍ DỤ 2
-- Tính tổng số tiền vận chuyển (Freight) của tất cả các đơn đặt hàng.
SELECT SUM(freight) AS "SumFreight"
FROM orders;

-- VÍ DỤ 3
-- Tính trung bình số lượng đặt hàng (Quantity)
-- của tất cả các sản phẩm trong bảng [Order Details]
SELECT AVG(quantity)
FROM order_details;

SELECT CEIL(AVG(quantity)) -- CEIL là hàm làm tròn
FROM order_details;

-- VÍ DỤ 4
-- Đếm số lượng, tính tổng số lượng hàng tồn kho
-- và trung bình giá của các sản phẩm có trong bảng Product.
SELECT COUNT(product_id) AS "số lượng hàng tồn kho",
       SUM(units_in_stock) AS"tổng số lượng hàng tồn kho",
       AVG(unit_price) AS"trung bình giá của các sản phẩm"
FROM products;