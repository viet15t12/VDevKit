-- ============================================
-- CÁC PHÉP TOÁN (Arithmetic Operators trong SQL)
-- ============================================
--
-- | Phép toán | Description | Giải thích       | Ví dụ       |
-- |-----------|-------------|-------------------|-------------|
-- |    +      | Add         | Cộng              | 1+1=2       |
-- |    -      | Subtract    | Trừ               | 1-1=0       |
-- |    *      | Multiply    | Nhân              | 5*2=10      |
-- |    /      | Divide      | Chia              | 5/2=2.5     |
-- |    %      | Modulo      | Chia lấy phần dư  | 5%2=1       |
--
-- ============================================

-- VÍ DỤ 1
-- Tính số lượng sản phẩm còn lại trong kho (UnitsInStock)
-- sau khi bán hết các sản phẩm đã được đặt hàng (UnitsOnOrder) .
-- StockRemaining = UnitsInStock - UnitsOnOrder

SELECT product_id,
       product_name,
       units_in_stock,
       units_on_order,
       units_in_stock - units_on_order as StockRemaining
FROM products;

-- VÍ DỤ 2
-- Tính giá trị đơn hàng chi tiết cho tất cả các sản phẩm trong bảng OrderDetails
-- OrderDetailValue = UnitPrice x Quantity

SELECT *, unit_price * quantity as OrderDetailValue
FROM order_details;

-- VÍ DỤ 3
-- Tính tỷ lệ giá vận chuyển đơn đặt hàng (Freight) trung bình
-- của các đơn hàng trong bảng Orders so với giá trị vận chuyển của đơn hàng lớn nhất (MaxFreight)
-- FreightRatio = AVG(Freight)/ MAX(Freight)

SELECT AVG(freight) as AvgFreight,
       MAX(freight) as MaxFreight,
       AVG(freight) / MAX(freight) as FreightRatio
FROM orders;

-- BÀI TẬP 1
-- Hãy liệt kê danh sách các sản phẩm, và giá (UnitPrice) của từng sản phẩm sẽ được giảm đi 10%.
-- Cách 1: dùng phép nhân + phép chia

SELECT product_id,
       product_name,
       unit_price * 90 / 100 as UnitPrice
FROM products;

-- Cách 2: chỉ được dùng phép nhân

SELECT product_id,
       product_name,
       unit_price * 0.9 as UnitPrice
FROM products;