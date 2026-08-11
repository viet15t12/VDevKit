-- AND - VÀ
-- SELECT column1, column2,
-- FROM table_name ...
-- WHERE condition1 AND condition2 AND condition3
-- Hiển thị một bản ghi nếu tất cả các điều kiện được phân
-- tách bằng AND đều có giá trị TRUE
--
-- OR - HOẶC
-- SELECT column1, column2, ...
-- FROM table_name
-- WHERE condition1 OR condition2 OR condition3
-- Hiển thị một bản ghi nếu nếu có ít nhất 1 điều kiện được
-- phân tách bằng OR có giá trị TRUE

-- NOT – PHỦ ĐỊNH
-- SELECT column1, column2, ...
-- FROM table_name
-- WHERE NOT Condition;
-- Hiển thị một bản ghi nếu nếu điều kiện có giá trị không
-- đúng - FALSE

-- VÍ DỤ 1
-- Bạn hãy liệt kê tất cả các sản phẩm có số lượng trong kho (UnitsInStock) thuộc khoảng nhỏ hơn 50 hoặc lớn hơn 100.

SELECT *
FROM Products
WHERE units_in_stock < 50 OR units_in_stock > 100;

-- VÍ DỤ 2
-- Bạn hãy liệt kê tất các đơn hàng được giao đến Brazil, đã bị giao muộn,
-- biết rằng ngày cần phải giao hàng là RequiredDate, ngày giao hàng thực tế là ShippedDate.

SELECT *
FROM orders
WHERE ship_country = 'Brazil' AND
      shipped_date > required_date;

-- VÍ DỤ 3
-- Lấy ra tất cả các sản phẩm có giá dưới 100$ và mã thể loại khác 1.
-- Lưu ý: dùng NOT

SELECT *
FROM products
WHERE NOT (unit_price >= 100 AND category_id =1);

-- BÀI TẬP 1
-- Hãy liệt kê tất cả các đơn hàng có giá vận chuyển Freight trong khoảng [50,100] đô la.

SELECT *
FROM orders
WHERE freight >= 50 AND  freight <= 100;

-- BÀI TẬP 2
-- Hãy liệt các sản phẩm có SỐ lượng hàng trong kho (UnitsInStock) lớn hơn 20
-- và số lượng hàng trong đơn hàng (UnitsOnOrder) nhỏ hơn 20.

SELECT *
FROM products
WHERE units_in_stock > 20 AND  units_on_order < 20;