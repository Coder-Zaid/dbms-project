/* ============================================================
   DAIRY FARM HERD & MILK COLLECTION MANAGEMENT SYSTEM
   COMPLETE QUERY SHEET
   Database: dairy_farm_db
   ============================================================ */


/* ============================================================
   1. DATABASE & TABLE COMMANDS
   ============================================================ */

CREATE DATABASE dairy_farm_db;

USE dairy_farm_db;

SHOW DATABASES;

SHOW TABLES;

DESCRIBE breed;

DESCRIBE animal;

DESCRIBE health_visit;

DESCRIBE vaccination;

DESCRIBE breeding_event;

DESCRIBE feed_item;

DESCRIBE feed_issue;

DESCRIBE milking_session;

DESCRIBE milk_yield;

DESCRIBE quality_test;

DESCRIBE buyer;

DESCRIBE sale;

DESCRIBE sale_item;

DESCRIBE payment;


/* ============================================================
   2. VIEW ALL DATA
   ============================================================ */

SELECT * FROM breed;

SELECT * FROM animal;

SELECT * FROM health_visit;

SELECT * FROM vaccination;

SELECT * FROM breeding_event;

SELECT * FROM feed_item;

SELECT * FROM feed_issue;

SELECT * FROM milking_session;

SELECT * FROM milk_yield;

SELECT * FROM quality_test;

SELECT * FROM buyer;

SELECT * FROM sale;

SELECT * FROM sale_item;

SELECT * FROM payment;


/* ============================================================
   3. BASIC SELECT QUERIES
   ============================================================ */

SELECT * FROM animal;

SELECT animal_tag, gender, status
FROM animal;

SELECT *
FROM animal
WHERE status = 'Active';

SELECT *
FROM animal
WHERE gender = 'Female';

SELECT *
FROM animal
ORDER BY date_of_birth;

SELECT *
FROM animal
ORDER BY date_of_birth DESC;

SELECT DISTINCT gender
FROM animal;


/* ============================================================
   4. ANIMAL + BREED QUERIES
   ============================================================ */

SELECT
    a.animal_id,
    a.animal_tag,
    b.breed_name,
    a.gender,
    a.date_of_birth,
    a.status
FROM animal a
JOIN breed b
    ON a.breed_id = b.breed_id;


SELECT
    a.animal_tag,
    b.breed_name
FROM animal a
JOIN breed b
    ON a.breed_id = b.breed_id;


SELECT
    b.breed_name,
    COUNT(a.animal_id) AS number_of_animals
FROM breed b
LEFT JOIN animal a
    ON b.breed_id = a.breed_id
GROUP BY
    b.breed_id,
    b.breed_name;


SELECT
    b.breed_name,
    COUNT(*) AS animal_count
FROM animal a
JOIN breed b
    ON a.breed_id = b.breed_id
GROUP BY b.breed_name;


/* ============================================================
   5. ANIMAL COUNT QUERIES
   ============================================================ */

SELECT COUNT(*) AS total_animals
FROM animal;


SELECT COUNT(*) AS active_animals
FROM animal
WHERE status = 'Active';


SELECT COUNT(*) AS female_animals
FROM animal
WHERE gender = 'Female';


SELECT COUNT(*) AS male_animals
FROM animal
WHERE gender = 'Male';


SELECT
    status,
    COUNT(*) AS number_of_animals
FROM animal
GROUP BY status;


/* ============================================================
   6. HEALTH VISIT QUERIES
   ============================================================ */

SELECT *
FROM health_visit;


SELECT
    a.animal_tag,
    h.visit_date,
    h.diagnosis,
    h.treatment,
    h.veterinarian
FROM animal a
JOIN health_visit h
    ON a.animal_id = h.animal_id
ORDER BY h.visit_date DESC;


SELECT
    a.animal_tag,
    h.visit_date,
    h.diagnosis,
    h.treatment
FROM animal a
JOIN health_visit h
    ON a.animal_id = h.animal_id
WHERE a.animal_tag = 'A1001';


SELECT
    a.animal_tag,
    COUNT(h.visit_id) AS total_visits
FROM animal a
LEFT JOIN health_visit h
    ON a.animal_id = h.animal_id
GROUP BY
    a.animal_id,
    a.animal_tag;


/* ============================================================
   7. VACCINATION QUERIES
   ============================================================ */

SELECT *
FROM vaccination;


SELECT
    a.animal_tag,
    v.vaccine_name,
    v.vaccination_date,
    v.next_due_date
FROM animal a
JOIN vaccination v
    ON a.animal_id = v.animal_id
ORDER BY v.next_due_date;


SELECT
    a.animal_tag,
    v.vaccine_name,
    v.next_due_date
FROM animal a
JOIN vaccination v
    ON a.animal_id = v.animal_id
WHERE v.next_due_date >= CURDATE()
ORDER BY v.next_due_date;


SELECT
    a.animal_tag,
    v.vaccine_name,
    v.next_due_date
FROM animal a
JOIN vaccination v
    ON a.animal_id = v.animal_id
WHERE v.next_due_date < CURDATE();


/* ============================================================
   8. BREEDING QUERIES
   ============================================================ */

SELECT *
FROM breeding_event;


SELECT
    a.animal_tag,
    be.breeding_date,
    be.event_type,
    be.sire_id,
    be.notes
FROM animal a
JOIN breeding_event be
    ON a.animal_id = be.animal_id
ORDER BY be.breeding_date DESC;


SELECT
    a.animal_tag,
    COUNT(be.breeding_id) AS breeding_events
FROM animal a
LEFT JOIN breeding_event be
    ON a.animal_id = be.animal_id
GROUP BY
    a.animal_id,
    a.animal_tag;


/* ============================================================
   9. FEED INVENTORY QUERIES
   ============================================================ */

SELECT *
FROM feed_item;


SELECT
    feed_name,
    available_quantity,
    unit,
    reorder_level
FROM feed_item;


SELECT
    feed_name,
    available_quantity,
    reorder_level
FROM feed_item
WHERE available_quantity <= reorder_level;


SELECT
    feed_name,
    available_quantity,
    unit
FROM feed_item
ORDER BY available_quantity ASC;


/* ============================================================
   10. FEED ISSUE QUERIES
   ============================================================ */

SELECT *
FROM feed_issue;


SELECT
    a.animal_tag,
    f.feed_name,
    fi.issue_date,
    fi.quantity,
    f.unit
FROM feed_issue fi
JOIN animal a
    ON fi.animal_id = a.animal_id
JOIN feed_item f
    ON fi.feed_id = f.feed_id
ORDER BY fi.issue_date DESC;


SELECT
    a.animal_tag,
    SUM(fi.quantity) AS total_feed_used
FROM animal a
JOIN feed_issue fi
    ON a.animal_id = fi.animal_id
GROUP BY
    a.animal_id,
    a.animal_tag;


SELECT
    f.feed_name,
    SUM(fi.quantity) AS total_quantity_issued
FROM feed_item f
JOIN feed_issue fi
    ON f.feed_id = fi.feed_id
GROUP BY
    f.feed_id,
    f.feed_name;


/* ============================================================
   11. MILKING SESSION QUERIES
   ============================================================ */

SELECT *
FROM milking_session;


SELECT
    ms.session_id,
    a.animal_tag,
    ms.session_date,
    ms.session_time,
    ms.session_type
FROM milking_session ms
JOIN animal a
    ON ms.animal_id = a.animal_id
ORDER BY
    ms.session_date,
    ms.session_time;


SELECT
    session_type,
    COUNT(*) AS number_of_sessions
FROM milking_session
GROUP BY session_type;


/* ============================================================
   12. MILK YIELD QUERIES
   ============================================================ */

SELECT *
FROM milk_yield;


SELECT
    a.animal_tag,
    ms.session_date,
    ms.session_type,
    y.quantity_litres
FROM animal a
JOIN milking_session ms
    ON a.animal_id = ms.animal_id
JOIN milk_yield y
    ON ms.session_id = y.session_id
ORDER BY ms.session_date;


SELECT
    a.animal_tag,
    SUM(y.quantity_litres) AS total_milk_litres
FROM animal a
JOIN milking_session ms
    ON a.animal_id = ms.animal_id
JOIN milk_yield y
    ON ms.session_id = y.session_id
GROUP BY
    a.animal_id,
    a.animal_tag
ORDER BY total_milk_litres DESC;


SELECT
    SUM(quantity_litres) AS total_milk_litres
FROM milk_yield;


SELECT
    AVG(quantity_litres) AS average_milk_yield
FROM milk_yield;


SELECT
    MAX(quantity_litres) AS highest_milk_yield
FROM milk_yield;


SELECT
    MIN(quantity_litres) AS lowest_milk_yield
FROM milk_yield;


/* ============================================================
   13. MILK PRODUCTION BY DATE
   ============================================================ */

SELECT
    ms.session_date,
    SUM(y.quantity_litres) AS total_milk_litres
FROM milking_session ms
JOIN milk_yield y
    ON ms.session_id = y.session_id
GROUP BY ms.session_date
ORDER BY ms.session_date;


SELECT
    ms.session_type,
    SUM(y.quantity_litres) AS total_milk_litres
FROM milking_session ms
JOIN milk_yield y
    ON ms.session_id = y.session_id
GROUP BY ms.session_type;


SELECT
    ms.session_date,
    ms.session_type,
    SUM(y.quantity_litres) AS total_milk_litres
FROM milking_session ms
JOIN milk_yield y
    ON ms.session_id = y.session_id
GROUP BY
    ms.session_date,
    ms.session_type
ORDER BY
    ms.session_date,
    ms.session_type;


/* ============================================================
   14. HIGHEST PRODUCING ANIMALS
   ============================================================ */

SELECT
    a.animal_tag,
    SUM(y.quantity_litres) AS total_milk
FROM animal a
JOIN milking_session ms
    ON a.animal_id = ms.animal_id
JOIN milk_yield y
    ON ms.session_id = y.session_id
GROUP BY
    a.animal_id,
    a.animal_tag
ORDER BY total_milk DESC
LIMIT 1;


SELECT
    a.animal_tag,
    SUM(y.quantity_litres) AS total_milk
FROM animal a
JOIN milking_session ms
    ON a.animal_id = ms.animal_id
JOIN milk_yield y
    ON ms.session_id = y.session_id
GROUP BY
    a.animal_id,
    a.animal_tag
ORDER BY total_milk DESC;


/* ============================================================
   15. QUALITY TEST QUERIES
   ============================================================ */

SELECT *
FROM quality_test;


SELECT
    a.animal_tag,
    ms.session_date,
    y.quantity_litres,
    qt.fat_percentage,
    qt.snf_percentage,
    qt.density
FROM animal a
JOIN milking_session ms
    ON a.animal_id = ms.animal_id
JOIN milk_yield y
    ON ms.session_id = y.session_id
JOIN quality_test qt
    ON y.yield_id = qt.yield_id;


SELECT
    y.yield_id,
    qt.fat_percentage,
    qt.snf_percentage,
    qt.density
FROM milk_yield y
JOIN quality_test qt
    ON y.yield_id = qt.yield_id
WHERE qt.fat_percentage > 4.00;


SELECT
    AVG(fat_percentage) AS average_fat_percentage
FROM quality_test;


SELECT
    AVG(snf_percentage) AS average_snf_percentage
FROM quality_test;


SELECT
    MAX(fat_percentage) AS highest_fat_percentage
FROM quality_test;


/* ============================================================
   16. BUYER QUERIES
   ============================================================ */

SELECT *
FROM buyer;


SELECT
    buyer_name,
    contact,
    address
FROM buyer
ORDER BY buyer_name;


/* ============================================================
   17. SALES QUERIES
   ============================================================ */

SELECT *
FROM sale;


SELECT
    s.sale_id,
    b.buyer_name,
    s.sale_date,
    s.total_amount
FROM sale s
JOIN buyer b
    ON s.buyer_id = b.buyer_id
ORDER BY s.sale_date DESC;


SELECT
    s.sale_id,
    b.buyer_name,
    s.sale_date,
    si.yield_id,
    si.quantity_sold,
    si.rate_per_litre,
    si.quantity_sold * si.rate_per_litre AS item_amount
FROM sale s
JOIN buyer b
    ON s.buyer_id = b.buyer_id
JOIN sale_item si
    ON s.sale_id = si.sale_id;


/* ============================================================
   18. SALES BY BUYER
   ============================================================ */

SELECT
    b.buyer_name,
    COUNT(s.sale_id) AS number_of_sales,
    SUM(s.total_amount) AS total_purchase_amount
FROM buyer b
LEFT JOIN sale s
    ON b.buyer_id = s.buyer_id
GROUP BY
    b.buyer_id,
    b.buyer_name
ORDER BY total_purchase_amount DESC;


/* ============================================================
   19. TOTAL MILK SOLD
   ============================================================ */

SELECT
    SUM(quantity_sold) AS total_milk_sold
FROM sale_item;


/* ============================================================
   20. TOTAL REVENUE
   ============================================================ */

SELECT
    SUM(total_amount) AS total_revenue
FROM sale;


/* ============================================================
   21. AVERAGE SALE VALUE
   ============================================================ */

SELECT
    AVG(total_amount) AS average_sale_value
FROM sale;


/* ============================================================
   22. SALE ITEM DETAILS
   ============================================================ */

SELECT *
FROM sale_item;


SELECT
    sale_id,
    yield_id,
    quantity_sold,
    rate_per_litre,
    quantity_sold * rate_per_litre AS item_total
FROM sale_item;


/* ============================================================
   23. PAYMENT QUERIES
   ============================================================ */

SELECT *
FROM payment;


SELECT
    p.payment_id,
    s.sale_id,
    b.buyer_name,
    p.payment_date,
    p.amount,
    p.payment_method,
    p.reference_no
FROM payment p
JOIN sale s
    ON p.sale_id = s.sale_id
JOIN buyer b
    ON s.buyer_id = b.buyer_id;


SELECT
    SUM(amount) AS total_payments_received
FROM payment;


SELECT
    payment_method,
    SUM(amount) AS total_received
FROM payment
GROUP BY payment_method;


/* ============================================================
   24. PAYMENT BALANCE / OUTSTANDING AMOUNT
   ============================================================ */

SELECT
    s.sale_id,
    b.buyer_name,
    s.total_amount AS sale_amount,
    COALESCE(SUM(p.amount), 0) AS amount_paid,
    s.total_amount -
        COALESCE(SUM(p.amount), 0) AS balance
FROM sale s
JOIN buyer b
    ON s.buyer_id = b.buyer_id
LEFT JOIN payment p
    ON s.sale_id = p.sale_id
GROUP BY
    s.sale_id,
    b.buyer_name,
    s.total_amount;


/* ============================================================
   25. FULL MILK SALES REPORT
   ============================================================ */

SELECT
    s.sale_id,
    b.buyer_name,
    s.sale_date,
    si.yield_id,
    si.quantity_sold,
    si.rate_per_litre,
    si.quantity_sold * si.rate_per_litre AS amount
FROM sale s
JOIN buyer b
    ON s.buyer_id = b.buyer_id
JOIN sale_item si
    ON s.sale_id = si.sale_id
ORDER BY s.sale_date DESC;


/* ============================================================
   26. REMAINING MILK FROM EACH YIELD
   ============================================================ */

SELECT
    y.yield_id,
    y.quantity_litres AS collected,
    COALESCE(SUM(si.quantity_sold), 0) AS sold,
    y.quantity_litres -
        COALESCE(SUM(si.quantity_sold), 0) AS remaining
FROM milk_yield y
LEFT JOIN sale_item si
    ON y.yield_id = si.yield_id
GROUP BY
    y.yield_id,
    y.quantity_litres;


/* ============================================================
   27. COMPLETE ANIMAL MILK SUMMARY
   ============================================================ */

SELECT
    a.animal_tag,
    b.breed_name,
    COALESCE(SUM(y.quantity_litres), 0)
        AS total_milk_litres
FROM animal a
JOIN breed b
    ON a.breed_id = b.breed_id
LEFT JOIN milking_session ms
    ON a.animal_id = ms.animal_id
LEFT JOIN milk_yield y
    ON ms.session_id = y.session_id
GROUP BY
    a.animal_id,
    a.animal_tag,
    b.breed_name
ORDER BY total_milk_litres DESC;


/* ============================================================
   28. ANIMAL + HEALTH + BREED REPORT
   ============================================================ */

SELECT
    a.animal_tag,
    b.breed_name,
    h.visit_date,
    h.diagnosis,
    h.treatment,
    h.veterinarian
FROM animal a
JOIN breed b
    ON a.breed_id = b.breed_id
LEFT JOIN health_visit h
    ON a.animal_id = h.animal_id
ORDER BY
    a.animal_tag,
    h.visit_date DESC;


/* ============================================================
   29. COMPLETE ANIMAL PRODUCTION REPORT
   ============================================================ */

SELECT
    a.animal_tag,
    b.breed_name,
    a.gender,
    a.status,
    COALESCE(SUM(y.quantity_litres), 0)
        AS total_milk_litres
FROM animal a
JOIN breed b
    ON a.breed_id = b.breed_id
LEFT JOIN milking_session ms
    ON a.animal_id = ms.animal_id
LEFT JOIN milk_yield y
    ON ms.session_id = y.session_id
GROUP BY
    a.animal_id,
    a.animal_tag,
    b.breed_name,
    a.gender,
    a.status
ORDER BY total_milk_litres DESC;


/* ============================================================
   30. GROUP BY EXAMPLES
   ============================================================ */

SELECT
    gender,
    COUNT(*) AS total
FROM animal
GROUP BY gender;


SELECT
    status,
    COUNT(*) AS total
FROM animal
GROUP BY status;


SELECT
    session_type,
    COUNT(*) AS total_sessions
FROM milking_session
GROUP BY session_type;


SELECT
    payment_method,
    COUNT(*) AS number_of_payments
FROM payment
GROUP BY payment_method;


/* ============================================================
   31. HAVING EXAMPLES
   ============================================================ */

SELECT
    a.animal_tag,
    SUM(y.quantity_litres) AS total_milk
FROM animal a
JOIN milking_session ms
    ON a.animal_id = ms.animal_id
JOIN milk_yield y
    ON ms.session_id = y.session_id
GROUP BY
    a.animal_id,
    a.animal_tag
HAVING SUM(y.quantity_litres) > 20;


SELECT
    b.breed_name,
    COUNT(a.animal_id) AS animal_count
FROM breed b
JOIN animal a
    ON b.breed_id = a.breed_id
GROUP BY
    b.breed_id,
    b.breed_name
HAVING COUNT(a.animal_id) > 1;


/* ============================================================
   32. SUBQUERY EXAMPLES
   ============================================================ */

SELECT *
FROM animal
WHERE animal_id IN (
    SELECT animal_id
    FROM health_visit
);


SELECT
    yield_id,
    quantity_litres
FROM milk_yield
WHERE quantity_litres > (
    SELECT AVG(quantity_litres)
    FROM milk_yield
);


SELECT
    animal_tag
FROM animal
WHERE animal_id IN (
    SELECT ms.animal_id
    FROM milking_session ms
    JOIN milk_yield y
        ON ms.session_id = y.session_id
    GROUP BY ms.animal_id
    HAVING SUM(y.quantity_litres) > 20
);


/* ============================================================
   33. EXISTS EXAMPLES
   ============================================================ */

SELECT
    a.animal_tag
FROM animal a
WHERE EXISTS (
    SELECT 1
    FROM health_visit h
    WHERE h.animal_id = a.animal_id
);


SELECT
    a.animal_tag
FROM animal a
WHERE EXISTS (
    SELECT 1
    FROM vaccination v
    WHERE v.animal_id = a.animal_id
);


/* ============================================================
   34. INNER JOIN EXAMPLE
   ============================================================ */

SELECT
    a.animal_tag,
    b.breed_name
FROM animal a
INNER JOIN breed b
    ON a.breed_id = b.breed_id;


/* ============================================================
   35. LEFT JOIN EXAMPLE
   ============================================================ */

SELECT
    a.animal_tag,
    h.visit_date,
    h.diagnosis
FROM animal a
LEFT JOIN health_visit h
    ON a.animal_id = h.animal_id;


/* ============================================================
   36. MULTIPLE JOIN EXAMPLE
   ============================================================ */

SELECT
    a.animal_tag,
    b.breed_name,
    ms.session_date,
    y.quantity_litres
FROM animal a
JOIN breed b
    ON a.breed_id = b.breed_id
JOIN milking_session ms
    ON a.animal_id = ms.animal_id
JOIN milk_yield y
    ON ms.session_id = y.session_id;


/* ============================================================
   37. INSERT EXAMPLES
   ============================================================ */

INSERT INTO breed
(breed_name, description)
VALUES
('Red Sindhi', 'Indian dairy cattle breed');


INSERT INTO animal
(animal_tag, breed_id, gender, date_of_birth, status)
VALUES
('A1005', 4, 'Female', '2023-02-15', 'Active');


INSERT INTO health_visit
(animal_id, visit_date, diagnosis, treatment, veterinarian)
VALUES
(1, CURDATE(), 'Routine check',
 'No treatment required', 'Dr. Kumar');


INSERT INTO vaccination
(animal_id, vaccine_name, vaccination_date, next_due_date)
VALUES
(1, 'FMD Vaccine', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 6 MONTH));


/* ============================================================
   38. UPDATE EXAMPLES
   ============================================================ */

UPDATE animal
SET status = 'Sold'
WHERE animal_tag = 'A1005';


UPDATE animal
SET status = 'Active'
WHERE animal_tag = 'A1005';


UPDATE feed_item
SET available_quantity = available_quantity + 100
WHERE feed_id = 1;


UPDATE buyer
SET contact = '9999999999'
WHERE buyer_id = 1;


/* ============================================================
   39. DELETE EXAMPLES
   ============================================================ */

DELETE FROM health_visit
WHERE visit_id = 3;


DELETE FROM vaccination
WHERE vaccination_id = 3;


/* ============================================================
   40. TRANSACTION EXAMPLE
   ============================================================ */

START TRANSACTION;

UPDATE feed_item
SET available_quantity = available_quantity + 50
WHERE feed_id = 1;

COMMIT;


/* ============================================================
   41. ROLLBACK EXAMPLE
   ============================================================ */

START TRANSACTION;

UPDATE feed_item
SET available_quantity = available_quantity - 100
WHERE feed_id = 1;

ROLLBACK;


/* ============================================================
   42. VIEW
   ============================================================ */

SELECT *
FROM animal_milk_summary;


/* ============================================================
   43. CREATE A CUSTOM REPORT VIEW
   ============================================================ */

CREATE OR REPLACE VIEW daily_milk_report AS
SELECT
    ms.session_date,
    SUM(y.quantity_litres) AS total_milk_litres
FROM milking_session ms
JOIN milk_yield y
    ON ms.session_id = y.session_id
GROUP BY ms.session_date;


SELECT *
FROM daily_milk_report;


/* ============================================================
   44. INFORMATION_SCHEMA - PRIMARY / FOREIGN KEYS
   ============================================================ */

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'dairy_farm_db'
AND REFERENCED_TABLE_NAME IS NOT NULL;


/* ============================================================
   45. SHOW ALL CONSTRAINTS
   ============================================================ */

SELECT
    CONSTRAINT_NAME,
    TABLE_NAME,
    CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'dairy_farm_db';


/* ============================================================
   46. SHOW CREATE TABLE
   ============================================================ */

SHOW CREATE TABLE animal;

SHOW CREATE TABLE milk_yield;

SHOW CREATE TABLE sale_item;


/* ============================================================
   47. SHOW TRIGGERS
   ============================================================ */

SHOW TRIGGERS;


/* ============================================================
   48. TEST UNIQUE CONSTRAINT
   Should produce an error
   ============================================================ */

-- INSERT INTO animal
-- (animal_tag, breed_id, gender, date_of_birth, status)
-- VALUES
-- ('A1001', 1, 'Female', '2022-01-01', 'Active');


/* ============================================================
   49. TEST FOREIGN KEY CONSTRAINT
   Should produce an error
   ============================================================ */

-- INSERT INTO animal
-- (animal_tag, breed_id, gender, date_of_birth, status)
-- VALUES
-- ('A9999', 9999, 'Female', '2022-01-01', 'Active');


/* ============================================================
   50. TEST CHECK CONSTRAINT
   Should produce an error
   ============================================================ */

-- INSERT INTO milk_yield
-- (session_id, quantity_litres)
-- VALUES
-- (1, -10);


/* ============================================================
   51. TEST FEED STOCK TRIGGER
   Should produce an error if quantity > available stock
   ============================================================ */

-- INSERT INTO feed_issue
-- (feed_id, animal_id, issue_date, quantity)
-- VALUES
-- (1, 1, CURDATE(), 999999);


/* ============================================================
   52. TEST MILK SALE TRIGGER
   Should produce an error if quantity sold > milk collected
   ============================================================ */

-- INSERT INTO sale_item
-- (sale_id, yield_id, quantity_sold, rate_per_litre)
-- VALUES
-- (1, 1, 9999, 50);


/* ============================================================
   53. FINAL DATABASE CHECK
   ============================================================ */

USE dairy_farm_db;

SHOW TABLES;

SELECT COUNT(*) AS total_breeds
FROM breed;

SELECT COUNT(*) AS total_animals
FROM animal;

SELECT COUNT(*) AS total_health_visits
FROM health_visit;

SELECT COUNT(*) AS total_vaccinations
FROM vaccination;

SELECT COUNT(*) AS total_breeding_events
FROM breeding_event;

SELECT COUNT(*) AS total_feed_items
FROM feed_item;

SELECT COUNT(*) AS total_feed_issues
FROM feed_issue;

SELECT COUNT(*) AS total_milking_sessions
FROM milking_session;

SELECT COUNT(*) AS total_milk_yields
FROM milk_yield;

SELECT COUNT(*) AS total_quality_tests
FROM quality_test;

SELECT COUNT(*) AS total_buyers
FROM buyer;

SELECT COUNT(*) AS total_sales
FROM sale;

SELECT COUNT(*) AS total_sale_items
FROM sale_item;

SELECT COUNT(*) AS total_payments
FROM payment;


/* ============================================================
   54. QUICK DEMONSTRATION QUERIES
   USE THESE DURING YOUR REVIEW
   ============================================================ */

-- Show all tables
SHOW TABLES;

-- Show animal structure
DESCRIBE animal;

-- Animal with breed
SELECT
    a.animal_tag,
    b.breed_name,
    a.gender,
    a.status
FROM animal a
JOIN breed b
    ON a.breed_id = b.breed_id;

-- Total milk per animal
SELECT
    a.animal_tag,
    SUM(y.quantity_litres) AS total_milk
FROM animal a
JOIN milking_session ms
    ON a.animal_id = ms.animal_id
JOIN milk_yield y
    ON ms.session_id = y.session_id
GROUP BY
    a.animal_id,
    a.animal_tag
ORDER BY total_milk DESC;

-- Milk quality
SELECT
    a.animal_tag,
    y.quantity_litres,
    qt.fat_percentage,
    qt.snf_percentage,
    qt.density
FROM animal a
JOIN milking_session ms
    ON a.animal_id = ms.animal_id
JOIN milk_yield y
    ON ms.session_id = y.session_id
JOIN quality_test qt
    ON y.yield_id = qt.yield_id;

-- Sales
SELECT
    s.sale_id,
    b.buyer_name,
    s.sale_date,
    s.total_amount
FROM sale s
JOIN buyer b
    ON s.buyer_id = b.buyer_id;

-- Payments and balance
SELECT
    s.sale_id,
    s.total_amount,
    COALESCE(SUM(p.amount), 0) AS paid,
    s.total_amount -
        COALESCE(SUM(p.amount), 0) AS balance
FROM sale s
LEFT JOIN payment p
    ON s.sale_id = p.sale_id
GROUP BY
    s.sale_id,
    s.total_amount;

-- Remaining milk
SELECT
    y.yield_id,
    y.quantity_litres AS collected,
    COALESCE(SUM(si.quantity_sold), 0) AS sold,
    y.quantity_litres -
        COALESCE(SUM(si.quantity_sold), 0) AS remaining
FROM milk_yield y
LEFT JOIN sale_item si
    ON y.yield_id = si.yield_id
GROUP BY
    y.yield_id,
    y.quantity_litres;

-- PK/FK relationships
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'dairy_farm_db'
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Triggers
SHOW TRIGGERS;

-- Final check
SHOW TABLES;


/* ============================================================
   END OF QUERY SHEET
   ============================================================ */