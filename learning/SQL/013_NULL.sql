-- IS NULL
-- SELECT column_name(s)
-- FROM table_name
-- WHERE column_name IS NULL;
-- Giá trị của column bị NULL.

-- IS NOT NULL
-- SELECT column_name(s)
-- FROM table_name
-- WHERE column_name IS NOT NULL;
-- Giá trị của column khác NULL.

-- VÍ DỤ 1
-- Lấy ra tất cả các đơn hàng chưa được giao hàng.
-- (ShippedDate => NULL)

SELECT *
FROM orders
WHERE shipped_date IS NULL;

SELECT COUNT(*)
FROM orders
WHERE shipped_date IS NULL;

-- VÍ DỤ 2
-- Lấy danh sách các khách hàng có khu vực (Region) không bị NULL.

SELECT *
FROM customers
WHERE region IS NOT NULL;

SELECT COUNT(*)
FROM customers
WHERE region IS NOT NULL;

-- VÍ DỤ 3
-- Lấy danh sách các khách hàng không có tên công ty
-- (Company Name).

SELECT *
FROM customers
WHERE company_name IS null;

-- BÀI TẬP 1
-- Hãy lấy ra tất cả các đơn hàng chưa được giao hàng
-- và có khu vực giao hàng (ShipRegion) không bị NULL.

SELECT *
FROM orders
WHERE shipped_date IS NULL OR
      ship_region IS NOT NULL;