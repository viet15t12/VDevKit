-- TOÁN TỬ BETWEEN
-- SELECT column_name(s)
-- FROM table_name
-- WHERE column_name BETWEEN value1 AND value2;
-- Toán tử BETWEENtử chọn các giá trị trong một phạm vi nhất định. Các giá trị có thể là số, văn bản hoặc ngày tháng.
-- Toán tử BETWEEN bao gồm: giá trị bắt đầu và kết thúc.

-- VÍ DỤ 1
-- Lấy danh sách các sản phẩm có giá bán trong khoảng từ 10 đến 20 đô la.

SELECT *
FROM products
WHERE unit_price BETWEEN 10 AND 20;

-- VÍ DỤ 2
-- Lấy danh sách các đơn đặt
-- hàng được đặt trong khoảng thời gian từ ngày 1996-07-01 đến ngày 1996-07-31:

SELECT *
FROM orders
WHERE order_date BETWEEN  '1996-07-01' AND '1996-07-31';

-- VÍ DỤ 3
-- Tính tổng số tiền vận chuyển (Freight)
-- của các đơn đặt hàng được đặt trong khoảng thời gian từ ngày 1996-07-01 đến ngày 1996-07-31:

SELECT  SUM(freight)
FROM orders
WHERE order_date BETWEEN  '1996-07-01' AND '1996-07-31';

-- BÀI TẬP 1
-- Lấy danh sách các đơn đặt hàng có ngày đặt hàng trong khoảng từ ngày 1/1/1997 đến ngày 31/12/1997
-- và được vận chuyển bằng đường tàu thủy (ShipVia = 3)

SELECT  *
FROM orders
WHERE ship_via = 3 AND order_date BETWEEN '1997-1-1' AND '1997-12-31';