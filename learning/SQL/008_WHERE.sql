-- MỆNH ĐỀ WHERE
-- SELECT column1, column2, ...
-- FROM table_name
-- WHERE condition;
-- Mệnh WHEREđề được sử dụng để lọc các bản ghi.
-- Nó được sử dụng để chỉ trích xuất những bản ghi đáp ứng một điều kiện cụ thể.

-- Các phép so sánh (Comparison Operators)
-- | Operator | Description                 | Mô tả                |
-- |----------|-----------------------------|----------------------|
-- |    =     | Equal                       | So sánh bằng         |
-- |    >     | Greater than                | Lớn hơn              |
-- |    <     | Less than                   | Bé hơn               |
-- |   >=     | Greater than or equal       | Lớn hơn hoặc bằng    |
-- |   <=     | Less than or equal          | Bé hơn hoặc bằng     |
-- |   <>     | Not equal (một số phiên bản dùng !=) | Khác        |

-- VÍ DỤ 1
-- Bạn hãy liệt kê tất cả các nhân viên đến từ thành phố London.

SELECT *
FROM employees
WHERE city = 'London'
ORDER BY last_name ASC;

-- VÍ DỤ 2
-- Bạn hãy liệt kê tất các đơn hàng bị giao muộn,
-- biết rằng ngày cần phải giao hàng là RequiredDate, ngày giao hàng thực tế là ShippedDate.

SELECT *
FROM orders
WHERE shipped_date >required_date;

SELECT COUNT(*) "so don bi giao tre"
FROM orders
WHERE shipped_date >required_date;

-- VÍ DỤ 3
-- Lấy ra tất cả các đơn hàng chi tiết được giảm giá nhiều hơn 10%.
-- (Discount > 0.1)

SELECT *
FROM order_details
WHERE discount >0.1;

-- BÀI TẬP 1
-- Hãy liệt kê tất cả các đơn hàng được gửi đến quốc gia là "France"

SELECT  *
FROM  orders
WHERE ship_country = 'France'