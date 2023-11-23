-- Bài 1: Tạo CSDL[20 điểm]:
CREATE DATABASE quanlybanhang;
USE quanlybanhang;
CREATE TABLE customers(
customer_id VARCHAR(4) NOT NULL PRIMARY KEY ,
name VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
phone VARCHAR(25) UNIQUE NOT NULL,
address VARCHAR(255) NOT NULL
);

CREATE TABLE orders(
order_id VARCHAR(4) NOT NULL PRIMARY KEY,
customer_id VARCHAR(4) NOT NULL,
FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
order_date DATE NOT NULL,
total_amount DOUBLE NOT NULL
);

CREATE TABLE products(
product_id VARCHAR(4) NOT NULL PRIMARY KEY,
name VARCHAR(100) NOT NULL,
description TEXT,
price DOUBLE NOT NULL,
status BIT(1) DEFAULT 1 NOT NULL 
);

CREATE TABLE orders_details(
order_id VARCHAR(4) NOT NULL,
FOREIGN KEY (order_id) REFERENCES orders(order_id),
product_id VARCHAR(4) NOT NULL,
FOREIGN KEY (product_id) REFERENCES products(product_id),
price DOUBLE NOT NULL,
quantity INT(11) NOT NULL,
PRIMARY KEY(order_id, product_id)
);

-- Bài 2: Thêm dữ liệu [20 điểm]:
insert into customers values('C001','Nguyễn Trung Mạnh','manhnt@gmail.com','984756322','Cầu Giấy,Hà Nội');
insert into customers values('C002','Hồ Hải Nam','namhh@gmail.com','984875926','Ba Vì,Hà Nội');
insert into customers values('C003','Tô Ngọc Vũ','vutn@gmail.com','904725784','Mộc Châu,Sơn La');
insert into customers values('C004','Phạm Ngọc Anh','anhpn@gmail.com','984635365','Vinh,Nghệ An');
insert into customers values('C005','Trương Minh Cường','cuongtm@gmail.com','989735624','Hai Bà Trưng,Hà Nội');

insert into products (product_id,name,description,price) values 
('P001','Iphone 13 ProMax','Bản 512GB, xanh lá',22999999),
('P002','Dell Vostro V3510','Core i5, RAM 8GB',14999999),
('P003','Macbook Pro M2','8 CPU 10GPU 8GB 256GB',28999999),
('P004','Apple Watch Ultra','Titanium Alpine Loop Smail',18999999),
('P005','Airpods 2 2022','Spatial Audio',4090000);

insert into orders values('H001','C001','2023-2-22',52999997);
insert into orders values('H002','C001','2023-3-11',80999997);
insert into orders values('H003','C002','2023-1-22',54309995);
insert into orders values('H004','C003','2023-3-14',102999995);
insert into orders values('H005','C003','2023-3-12',80999997);

insert into orders values('H006','C004','2023-2-1',110449994);
insert into orders values('H007','C004','2023-3-29',79999996);
insert into orders values('H008','C005','2023-2-14',29999998);
insert into orders values('H009','C005','2023-1-10',28999999);
insert into orders values('H010','C005','2023-1-4',149999994);

INSERT INTO orders_details (order_id, product_id, price, quantity) VALUES
	('H001','P002',14999999,1),
    ('H001','P004',18999999,2),
    ('H002','P001',22999999,1),
    ('H002','P003',28999999,2),
    ('H003','P004',18999999,2),
    ('H003','P005',4090000,4),
    ('H004','P002',14999999,3),
    ('H004','P003',28999999,2),
    ('H005','P001',22999999,1),
    ('H005','P003',28999999,2),
    ('H006','P005',4090000,5),
    ('H006','P002',14999999,6),
    ('H007','P004',18999999,3),
    ('H007','P001',22999999,1),
    ('H008','P002',14999999,2),
    ('H009','P003',28999999,1),
    ('H010','P003',28999999,2),
    ('H010','P001',22999999,4);
    
    -- Bài 3: Truy vấn dữ liệu [30 điểm]:
    SELECT name, email, phone, address FROM customers;
    
    SELECT c.name, c.phone, c.address
    FROM orders o
    LEFT JOIN customers c
    ON o.customer_id =  c.customer_id
    WHERE MONTH(o.order_date) = 3 AND YEAR(o.order_date) = 2023;
    
    SELECT MONTH(order_date) AS thang , SUM(total_amount) as total_amount FROM orders GROUP BY thang;
    
SELECT name, address, email, phone
FROM CUSTOMERS
WHERE customer_id NOT IN (
    SELECT customer_id
    FROM Orders
    WHERE MONTH(order_date) = 2 AND YEAR(order_date) = 2023
);

SELECT p.product_id, p.name, COALESCE(SUM(od.quantity), 0) as 'số lượng bán ra'
FROM products p
LEFT JOIN orders_details od ON p.product_id = od.product_id
LEFT JOIN orders o ON od.order_id = o.order_id AND MONTH(o.order_date) = 3 AND YEAR(o.order_date) = 2023
WHERE MONTH(o.order_date) = 3 AND YEAR(o.order_date) = 2023
GROUP BY p.product_id, p.name;

SELECT c.customer_id, c.name, SUM(o.total_amount) AS mức_chi_tiêu
FROM Orders o
JOIN customers c 
ON o.customer_id = c.customer_id
WHERE YEAR(order_date) = 2023
GROUP BY c.customer_id, c.name
ORDER BY mức_chi_tiêu DESC;

SELECT c.name, o.total_amount, o.order_date, SUM(od.quantity) AS tổng_số_lượng_sản_phẩm
FROM Orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN ORDERS_DETAILS od ON o.order_id = od.order_id
GROUP BY o.order_id
HAVING tổng_số_lượng_sản_phẩm >= 5;

-- Bài 4: Tạo View, Procedure [30 điểm]:

CREATE VIEW show_order_info
AS
SELECT c.name,c.phone,c.address, o.total_amount, o.order_date
FROM orders o
LEFT JOIN customers c
ON o.customer_id = c.customer_id;
-- SELECT * FROM  show_order_info;

CREATE VIEW show_customer_info
AS
SELECT c.name,c.address,c.phone, COUNT(c.customer_id) AS 'Số đơn đã mua'
FROM customers c
LEFT JOIN orders o
ON o.customer_id = c.customer_id
GROUP BY c.name,c.address,c.phone;
-- SELECT * FROM show_customer_info;

CREATE VIEW product_sales_info AS
SELECT p.name AS product_name, p.description, p.price, COALESCE(SUM(od.quantity), 0) AS total_quantity_sold
FROM products p
LEFT JOIN orders_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.name, p.description, p.price;
-- SELECT * FROM product_sales_info;

ALTER TABLE customers
ADD INDEX idx_phone (phone);

ALTER TABLE customers
ADD INDEX idx_email (email);

DELIMITER //
CREATE PROCEDURE GetCustomerInfo(IN c_customer_id VARCHAR(4))
BEGIN
    SELECT * FROM customers WHERE customer_id = c_customer_id;
END;
//
-- CALL GetCustomerInfo('C003');

DELIMITER //
CREATE PROCEDURE GetAllProductInfo()
BEGIN
    SELECT * FROM products;
END;
//
-- CALL GetAllProductInfo;

DELIMITER //
CREATE PROCEDURE GetOrderInfo(IN c_customer_id VARCHAR(4))
BEGIN
    SELECT * FROM orders WHERE c_customer_id = customer_id;
END;
//
-- CALL GetOrderInfo('C001');

DELIMITER //
CREATE PROCEDURE CreateOrder(
    IN o_order_id VARCHAR(4),
     c_customer_id VARCHAR(4),
     o_total_amount DOUBLE,
     o_order_date DATE
)
BEGIN
    INSERT INTO orders (order_id, customer_id, order_date, total_amount)
    VALUES (o_order_id, c_customer_id, o_order_date, o_total_amount);
    SELECT o_order_id AS 'Mã đơn vừa tạo' FROM orders WHERE o_order_id = order_id;
END; 
//
-- CALL CreateOrder('H011','C003',149999999,'2023-1-6');

DELIMITER //
CREATE PROCEDURE SalesStatistics(
    IN o_start_date DATE,
    o_end_date DATE
)
BEGIN
    SELECT
        p.product_id,
        p.name AS product_name,
        COALESCE(SUM(od.quantity), 0) AS total_quantity_sold
    FROM
        products p
    LEFT JOIN
        orders_details od ON p.product_id = od.product_id
    LEFT JOIN
        orders o ON od.order_id = o.order_id
    WHERE
        o.order_date BETWEEN o_start_date AND o_end_date
    GROUP BY
        p.product_id, p.name;
END;
//
-- CALL SalesStatistics('2023-03-11','2023-04-11');

DELIMITER //
CREATE PROCEDURE MonthlySalesStatistics(
    IN o_month INT,
    IN o_year INT
)
BEGIN
    SELECT
        p.product_id,
        p.name AS product_name,
        SUM(od.quantity) AS total_quantity_sold
    FROM
        products p
    LEFT JOIN
        orders_details od ON p.product_id = od.product_id
    LEFT JOIN
        orders o ON od.order_id = o.order_id
    WHERE
        MONTH(o.order_date) = o_month
        AND YEAR(o.order_date) = o_year
    GROUP BY
        p.product_id, p.name
    ORDER BY
        total_quantity_sold DESC;
END;
//
-- CALL MonthlySalesStatistics(1, 2023);