-- TOÁN TỬ LIKE
-- SELECT column1, column2, ...
-- FROM table_name
-- WHERE columnN LIKE pattern;
-- Có hai ký tự đại diện thường được sử dụng cùng với LIKE:
-- Dấu phần trăm (%) đại diện cho không, một hoặc nhiều ký tự
-- Dấu gạch dưới (_) đại diện cho một ký tự đơn

-- VÍ DỤ 1
-- Hãy lọc ra tất cả các khách hàng đến từ các quốc gia (Country) bắt đầu bằng chữ 'A'

SELECT *
FROM customers
WHERE country LIKE  'A%';

-- VÍ DỤ 2
-- Lấy danh sách các đơn đặt được gửi đến các thành phố có chứa chữ 'a'.

SELECT *
FROM orders
WHERE ship_city LIKE '%a%';

-- VÍ DỤ 4
-- Hãy lọc ra tất cả các đơn hàng với điều kiện:
-- ShipCountry LIKE 'U_'
-- ShipCountry LIKE 'U%'

SELECT *
FROM orders
WHERE ship_country LIKE 'U_';

SELECT *
FROM orders
WHERE ship_country LIKE 'U%';

-- BÀI TẬP 1
-- Hãy lấy ra tất cả các nhà cung cấp hàng có chữ chữ 'b' trong tên của công ty

SELECT *
FROM suppliers
WHERE company_name LIKE '%b%';


