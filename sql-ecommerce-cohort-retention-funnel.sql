CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    city VARCHAR(50),
    signup_date DATE
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
INSERT INTO customers VALUES
(1, 'Amit Sharma', 'Delhi', '2024-01-10'),
(2, 'Sara Khan', 'Mumbai', '2024-02-05'),
(3, 'John Mathew', 'Bangalore', '2024-03-15'),
(4, 'Priya Singh', 'Delhi', '2024-03-20');

INSERT INTO products VALUES
(101, 'Laptop', 'Electronics', 60000),
(102, 'Headphones', 'Electronics', 2000),
(103, 'Shoes', 'Fashion', 2500),
(104, 'Backpack', 'Fashion', 1500);

INSERT INTO orders VALUES
(1001, 1, '2024-04-01', 'Completed'),
(1002, 2, '2024-04-03', 'Completed'),
(1003, 1, '2024-05-05', 'Completed'),
(1004, 3, '2024-05-10', 'Cancelled'),
(1005, 4, '2024-06-01', 'Completed');

INSERT INTO order_items VALUES
(1, 1001, 101, 1),
(2, 1001, 102, 2),
(3, 1002, 103, 1),
(4, 1003, 104, 2),
(5, 1005, 103, 2);
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT
    SUM(p.price * oi.quantity) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Completed';
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
)
SELECT
    customer_id,
    first_order_date,
    DATEFROMPARTS(YEAR(first_order_date), MONTH(first_order_date), 1) AS cohort_month
FROM first_purchase
ORDER BY customer_id;
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
),
cohort_data AS (
    SELECT
        o.customer_id,
        DATEFROMPARTS(YEAR(fp.first_order_date), MONTH(fp.first_order_date), 1) AS cohort_month,
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1) AS activity_month
    FROM orders o
    JOIN first_purchase fp
        ON o.customer_id = fp.customer_id
    WHERE o.status = 'Completed'
)
SELECT
    cohort_month,
    activity_month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM cohort_data
GROUP BY cohort_month, activity_month
ORDER BY cohort_month, activity_month;
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
),
cohort_data AS (
    SELECT
        o.customer_id,
        DATEFROMPARTS(YEAR(fp.first_order_date), MONTH(fp.first_order_date), 1) AS cohort_month,
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1) AS activity_month
    FROM orders o
    JOIN first_purchase fp
        ON o.customer_id = fp.customer_id
    WHERE o.status = 'Completed'
),
cohort_counts AS (
    SELECT
        cohort_month,
        activity_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM cohort_data
    GROUP BY cohort_month, activity_month
),
cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_customers
    FROM cohort_data
    GROUP BY cohort_month
)
SELECT
    cc.cohort_month,
    cc.activity_month,
    cc.active_customers,
    cs.cohort_customers,
    ROUND((1.0 * cc.active_customers / cs.cohort_customers) * 100, 2) AS retention_rate_percent
FROM cohort_counts cc
JOIN cohort_size cs
    ON cc.cohort_month = cs.cohort_month
ORDER BY cc.cohort_month, cc.activity_month;
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
),
cohort_data AS (
    SELECT
        o.customer_id,
        DATEFROMPARTS(YEAR(fp.first_order_date), MONTH(fp.first_order_date), 1) AS cohort_month,
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1) AS activity_month
    FROM orders o
    JOIN first_purchase fp
        ON o.customer_id = fp.customer_id
    WHERE o.status = 'Completed'
),
cohort_counts AS (
    SELECT
        cohort_month,
        activity_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM cohort_data
    GROUP BY cohort_month, activity_month
),
cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_customers
    FROM cohort_data
    GROUP BY cohort_month
)
SELECT
    cc.cohort_month,
    cc.activity_month,
    ROUND((1.0 * cc.active_customers / cs.cohort_customers) * 100, 2) AS retention_rate_percent,
    ROUND(100 - ((1.0 * cc.active_customers / cs.cohort_customers) * 100), 2) AS churn_rate_percent
FROM cohort_counts cc
JOIN cohort_size cs
    ON cc.cohort_month = cs.cohort_month
ORDER BY cc.cohort_month, cc.activity_month;
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
),
cohort_data AS (
    SELECT
        o.customer_id,
        DATEFROMPARTS(YEAR(fp.first_order_date), MONTH(fp.first_order_date), 1) AS cohort_month,
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1) AS activity_month
    FROM orders o
    JOIN first_purchase fp
        ON o.customer_id = fp.customer_id
    WHERE o.status = 'Completed'
),
cohort_counts AS (
    SELECT
        cohort_month,
        activity_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM cohort_data
    GROUP BY cohort_month, activity_month
),
cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_customers
    FROM cohort_data
    GROUP BY cohort_month
)
SELECT
    cc.cohort_month,
    cc.activity_month,
    ROUND((1.0 * cc.active_customers / cs.cohort_customers) * 100, 2) AS retention_rate_percent,
    ROUND(100 - ((1.0 * cc.active_customers / cs.cohort_customers) * 100), 2) AS churn_rate_percent
FROM cohort_counts cc
JOIN cohort_size cs
    ON cc.cohort_month = cs.cohort_month
ORDER BY cc.cohort_month, cc.activity_month;
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
),
cohort_data AS (
    SELECT
        o.customer_id,
        DATEFROMPARTS(YEAR(fp.first_order_date), MONTH(fp.first_order_date), 1) AS cohort_month,
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1) AS activity_month
    FROM orders o
    JOIN first_purchase fp
        ON o.customer_id = fp.customer_id
    WHERE o.status = 'Completed'
),
cohort_counts AS (
    SELECT
        cohort_month,
        activity_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM cohort_data
    GROUP BY cohort_month, activity_month
),
cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_customers
    FROM cohort_data
    GROUP BY cohort_month
)
SELECT
    cc.cohort_month,
    cc.activity_month,
    ROUND((1.0 * cc.active_customers / cs.cohort_customers) * 100, 2) AS retention_rate_percent,
    ROUND(100 - ((1.0 * cc.active_customers / cs.cohort_customers) * 100), 2) AS churn_rate_percent
FROM cohort_counts cc
JOIN cohort_size cs
    ON cc.cohort_month = cs.cohort_month
ORDER BY cc.cohort_month, cc.activity_month;
WITH customer_orders AS (
    SELECT
        c.customer_id,
        COUNT(DISTINCT o.order_id) AS completed_orders
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
        AND o.status = 'Completed'
    GROUP BY c.customer_id
)
SELECT
    COUNT(*) AS total_signed_up,
    SUM(CASE WHEN completed_orders >= 1 THEN 1 ELSE 0 END) AS customers_with_1_order,
    SUM(CASE WHEN completed_orders >= 2 THEN 1 ELSE 0 END) AS repeat_customers
FROM customer_orders;
WITH customer_orders AS (
    SELECT
        c.customer_id,
        COUNT(DISTINCT o.order_id) AS completed_orders
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
        AND o.status = 'Completed'
    GROUP BY c.customer_id
),
funnel AS (
    SELECT
        COUNT(*) AS total_signed_up,
        SUM(CASE WHEN completed_orders >= 1 THEN 1 ELSE 0 END) AS customers_with_1_order,
        SUM(CASE WHEN completed_orders >= 2 THEN 1 ELSE 0 END) AS repeat_customers
    FROM customer_orders
)
SELECT
    total_signed_up,
    customers_with_1_order,
    repeat_customers,
    ROUND((1.0 * customers_with_1_order / total_signed_up) * 100, 2) AS signup_to_purchase_conversion,
    ROUND((1.0 * repeat_customers / NULLIF(customers_with_1_order, 0)) * 100, 2) AS purchase_to_repeat_conversion
FROM funnel;
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
),
cohort_data AS (
    SELECT
        o.customer_id,
        DATEFROMPARTS(YEAR(fp.first_order_date), MONTH(fp.first_order_date), 1) AS cohort_month,
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1) AS activity_month
    FROM orders o
    JOIN first_purchase fp
        ON o.customer_id = fp.customer_id
    WHERE o.status = 'Completed'
),
cohort_index AS (
    SELECT
        cohort_month,
        activity_month,
        DATEDIFF(MONTH, cohort_month, activity_month) AS month_number,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM cohort_data
    GROUP BY cohort_month, activity_month
)
SELECT *
FROM cohort_index
ORDER BY cohort_month, month_number;
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
),
cohort_data AS (
    SELECT
        o.customer_id,
        DATEFROMPARTS(YEAR(fp.first_order_date), MONTH(fp.first_order_date), 1) AS cohort_month,
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1) AS activity_month
    FROM orders o
    JOIN first_purchase fp
        ON o.customer_id = fp.customer_id
    WHERE o.status = 'Completed'
),
cohort_index AS (
    SELECT
        cohort_month,
        DATEDIFF(MONTH, cohort_month, activity_month) AS month_number,
        customer_id
    FROM cohort_data
)
SELECT
    cohort_month,
    COUNT(DISTINCT CASE WHEN month_number = 0 THEN customer_id END) AS month_0,
    COUNT(DISTINCT CASE WHEN month_number = 1 THEN customer_id END) AS month_1,
    COUNT(DISTINCT CASE WHEN month_number = 2 THEN customer_id END) AS month_2
FROM cohort_index
GROUP BY cohort_month
ORDER BY cohort_month;
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
),
cohort_data AS (
    SELECT
        o.customer_id,
        DATEFROMPARTS(YEAR(fp.first_order_date), MONTH(fp.first_order_date), 1) AS cohort_month,
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1) AS activity_month
    FROM orders o
    JOIN first_purchase fp
        ON o.customer_id = fp.customer_id
    WHERE o.status = 'Completed'
),
cohort_index AS (
    SELECT
        cohort_month,
        DATEDIFF(MONTH, cohort_month, activity_month) AS month_number,
        customer_id
    FROM cohort_data
),
cohort_pivot AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT CASE WHEN month_number = 0 THEN customer_id END) AS month_0,
        COUNT(DISTINCT CASE WHEN month_number = 1 THEN customer_id END) AS month_1,
        COUNT(DISTINCT CASE WHEN month_number = 2 THEN customer_id END) AS month_2
    FROM cohort_index
    GROUP BY cohort_month
)
SELECT
    cohort_month,
    month_0,
    ROUND(100.0 * month_0 / NULLIF(month_0, 0), 2) AS retention_month_0_pct,
    ROUND(100.0 * month_1 / NULLIF(month_0, 0), 2) AS retention_month_1_pct,
    ROUND(100.0 * month_2 / NULLIF(month_0, 0), 2) AS retention_month_2_pct
FROM cohort_pivot
ORDER BY cohort_month;
SELECT
    SUM(p.price * oi.quantity) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Completed';
SELECT
    COUNT(DISTINCT order_id) AS total_completed_orders
FROM orders
WHERE status = 'Completed';
SELECT
    COUNT(DISTINCT customer_id) AS total_customers
FROM customers;
SELECT
    COUNT(DISTINCT customer_id) AS active_customers
FROM orders
WHERE status = 'Completed';
WITH revenue_orders AS (
    SELECT
        o.order_id,
        SUM(p.price * oi.quantity) AS order_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.status = 'Completed'
    GROUP BY o.order_id
)
SELECT
    ROUND(AVG(order_revenue), 2) AS avg_order_value
FROM revenue_orders;
WITH total_rev AS (
    SELECT SUM(p.price * oi.quantity) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.status = 'Completed'
),
active_cust AS (
    SELECT COUNT(DISTINCT customer_id) AS active_customers
    FROM orders
    WHERE status = 'Completed'
)
SELECT
    revenue,
    active_customers,
    ROUND(1.0 * revenue / NULLIF(active_customers, 0), 2) AS arpu
FROM total_rev, active_cust;
SELECT
    DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1) AS month,
    SUM(p.price * oi.quantity) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Completed'
GROUP BY DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
ORDER BY month;
SELECT TOP 3
    p.product_name,
    SUM(oi.quantity) AS total_units_sold,
    SUM(p.price * oi.quantity) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Completed'
GROUP BY p.product_name
ORDER BY total_revenue DESC;
WITH revenue_orders AS (
    SELECT
        o.order_id,
        SUM(p.price * oi.quantity) AS order_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.status = 'Completed'
    GROUP BY o.order_id
),
totals AS (
    SELECT
        SUM(order_revenue) AS total_revenue,
        COUNT(*) AS total_completed_orders,
        ROUND(AVG(order_revenue), 2) AS avg_order_value
    FROM revenue_orders
),
active_customers AS (
    SELECT COUNT(DISTINCT customer_id) AS active_customers
    FROM orders
    WHERE status = 'Completed'
),
all_customers AS (
    SELECT COUNT(*) AS total_customers
    FROM customers
)
SELECT
    t.total_revenue,
    t.total_completed_orders,
    t.avg_order_value,
    ac.active_customers,
    allc.total_customers,
    ROUND(1.0 * t.total_revenue / NULLIF(ac.active_customers, 0), 2) AS arpu
FROM totals t
CROSS JOIN active_customers ac
CROSS JOIN all_customers allc;







