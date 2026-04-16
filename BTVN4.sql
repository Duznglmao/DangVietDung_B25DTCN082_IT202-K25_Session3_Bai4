/* 
BTVN4:
- Phân tích và đề xuất giải pháp
	+ Giải pháp 1: Hard Delete 
    Sử dụng lệnh DELETE để xóa sạch các đơn hàng có trạng thái 'Canceled' khỏi bảng chính. 
    Trước đó, ta sao lưu (backup) các dòng này sang một bảng phụ.
	
    + Giải pháp 2: Soft Delete (Xóa mềm)
	Không xóa dòng nào cả. 
    Thay vào đó, ta sử dụng một cột đánh dấu (ví dụ cột IsDeleted kiểu BIT có sẵn trong hình). 
    Khi "xóa", ta chỉ cập nhật IsDeleted = 1.
- So sánh:
	+ Giải phóng ổ cứng: Hard Delete hiệu quả hơn vì dữ liệu bị xóa khỏi bảng chính nên dung lượng giảm ngay; 
    trong khi đó Soft Delete kém hiệu quả vì dữ liệu vẫn tồn tại trong bảng.
	+ Tốc độ truy vấn: Hard Delete cho tốc độ nhanh hơn do bảng gọn nhẹ, ít dữ liệu cần quét; 
    còn Soft Delete chậm hơn vì phải thêm điều kiện WHERE IsDeleted = 0 trong hầu hết các truy vấn.
	+ Tính vẹn toàn kế toán: Hard Delete gây khó khăn vì phải truy xuất dữ liệu từ nơi lưu trữ khác khi cần đối soát;
    ngược lại, Soft Delete đảm bảo tốt vì dữ liệu vẫn nằm trong hệ thống, chỉ cần truy vấn là có thể sử dụng ngay.
*/ 

CREATE DATABASE IF NOT EXISTS BTVN4;
USE BTVN4;

CREATE TABLE ORDERS (
    OrderID INT PRIMARY KEY AUTO_INCREMENT, 
    CustomerName VARCHAR(100),
    OrderDate DATETIME,
    TotalAmount DECIMAL(18, 2),
    Status VARCHAR(20),
    IsDeleted BIT DEFAULT 0
);

CREATE TABLE ORDERS_BackUp (
    OrderID INT PRIMARY KEY, 
    CustomerName VARCHAR(100),
    OrderDate DATETIME,
    TotalAmount DECIMAL(18, 2),
    Status VARCHAR(20),
    IsDeleted BIT DEFAULT 0
);

INSERT INTO ORDERS (customerName, orderDate, totalAmount, status) 
VALUES
    ('Nguyễn Văn A', '2023-01-10', 500000, 'Completed'),
    ('Khách hàng vãng lai', '2023-02-15', 1200000, 'Canceled'), 
    ('Trần Thị B', '2023-05-20', 300000, 'Canceled'),
    ('Lê Văn C', '2024-01-05', 850000, 'Completed');

INSERT INTO ORDERS_BackUp (orderID, customerName, orderDate, totalAmount, status, isDeleted)
SELECT orderID, customerName, orderDate, totalAmount, status, isDeleted
FROM ORDERS
WHERE status = 'Canceled';

DELETE FROM ORDERS
WHERE status = 'Canceled';