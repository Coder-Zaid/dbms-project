# Dairy Farm Herd & Milk Collection Management System
## Presentation-II: Database Architecture, Relational Schema & SQL Query Pack
*Student: Mohammed Zaid (Roll No: 25WU0102163) • Faculty Mentor: Dr. Kiran Mayee Adavala • MySQL Community Server 8.0.46*

---

### Project Overview & Relational Architecture
#### Transforming Traditional Dairy Registers into an ACID-Compliant Enterprise RDBMS

> **14 Tables**  
> Strongly-typed InnoDB relations across operations, veterinary, inventory, and billing.

> **100% 3NF**  
> Formally normalized schema eliminating all update, insert, and delete anomalies.

> **4 Active Triggers**  
> Automated inventory guards (`before_feed_issue`) and invoice reconciliation (`after_sale_item`).

> **700 Production Rows**  
> Populated with exactly 50 realistic, referentially-intact records per table.

---

### Problem Statement & Objectives
#### Modernizing Dairy Operations through Relational Discipline

### The Legacy Problem
* **Logbook Fragmentation**: Hand-written registers separating lactation harvests from feed consumption and breeding lineages.
* **Lack of Attribution**: Impossible to correlate milk yield fluctuations with feed rations or genetic breed characteristics.
* **Financial Mismatch**: Unreconciled accounts between bulk milk shipments and cooperative buyer payments.

### DBMS Objectives
* **Referential Integrity**: Enforce foreign keys with `ON DELETE CASCADE` to prevent orphaned health, breeding, or milking logs.
* **Formal Decomposition**: Achieve Boyce-Codd / 3NF across all entities to eliminate partial and transitive dependencies.
* **Transactional ACID Safety**: Guarantee multi-table atomicity and Repeatable Read isolation on MySQL 8.0.

---

### Enhanced Entity-Relationship (EER) Architecture
#### 14 Entities with Unary, Binary, and Associative Mappings

```
      +-------------+        +-------------------+        +----------------+
      |    BREED    |<-------|      ANIMAL       |------->|  HEALTH_VISIT  |
      +-------------+        +---------+---------+        +----------------+
                                  |    |    |
           +----------------------+    |    +-------------------+
           |                           |                        |
           v                           v                        v
    +--------------+        +-------------------+       +----------------+
    | BREEDING     |        | MILKING_SESSION   |       |  VACCINATION   |
    | (Unary Sire) |        +---------+---------+       +----------------+
    +--------------+                  |
                                      v
                             +------------------+
                             |    MILK_YIELD    |
                             +----+--------+----+
                                  |        |
             +--------------------+        +--------------------+
             |                                                  |
             v                                                  v
     +---------------+                                  +---------------+
     | QUALITY_TEST  |                                  |   SALE_ITEM   |
     +---------------+                                  +-------+-------+
                                                                |
                                                                v
                                                        +---------------+
                                                        |     SALE      |<--- BUYER
                                                        +-------+-------+
                                                                |
                                                                v
                                                        +---------------+
                                                        |    PAYMENT    |
                                                        +---------------+
```

* **Recursive Lineage**: `breeding_event.sire_id` references `animal.animal_id` in a unary 1:N relationship.
* **M:N Associative Bridges**: `feed_issue` resolves `animal` ↔ `feed_item`; `sale_item` resolves `sale` ↔ `milk_yield`.
* **2-Table Harvest Normalization**: `milking_session` holds operational session metadata, while `milk_yield` holds physical harvest quantities.

---

### Authoritative Relational Schema & Constraints
#### Comprehensive Primary Key and Foreign Key Mapping

| Table Name | Primary Key | Foreign Key Reference | Delete Rule | Normal Form |
| :--- | :--- | :--- | :--- | :--- |
| `breed` | `breed_id` | *None (Root Lookup)* | — | 3NF |
| `animal` | `animal_id` | `breed_id` → `breed.breed_id` | RESTRICT | 3NF |
| `health_visit` | `visit_id` | `animal_id` → `animal.animal_id` | CASCADE | 3NF |
| `vaccination` | `vaccination_id` | `animal_id` → `animal.animal_id` | CASCADE | 3NF |
| `breeding_event` | `breeding_id` | `animal_id` → `animal`, `sire_id` → `animal` | CASCADE / SET NULL | 3NF |
| `feed_item` | `feed_id` | *None (Warehouse Master)* | — | 3NF |
| `feed_issue` | `issue_id` | `feed_id` → `feed_item`, `animal_id` → `animal` | RESTRICT / CASCADE | 3NF |
| `milking_session`| `session_id` | `animal_id` → `animal.animal_id` | CASCADE | 3NF |
| `milk_yield` | `yield_id` | `session_id` → `milking_session.session_id` | CASCADE | 3NF |
| `quality_test` | `test_id` | `yield_id` → `milk_yield.yield_id` | CASCADE | 3NF |
| `buyer` | `buyer_id` | *None (Customer Master)* | — | 3NF |
| `sale` | `sale_id` | `buyer_id` → `buyer.buyer_id` | RESTRICT | 3NF |
| `sale_item` | `(sale_id, yield_id)` | `sale_id` → `sale`, `yield_id` → `milk_yield` | CASCADE / RESTRICT | 3NF |
| `payment` | `payment_id` | `sale_id` → `sale.sale_id` | CASCADE | 3NF |

---

### Normalization Justification: 1NF to 3NF
#### Mathematical Elimination of Redundancy and Functional Anomalies

### 1NF: Atomic Domains
* All attributes store atomic scalar values (VARCHAR, INT, DATE, DECIMAL).
* Repeating multivalued attributes (such as medical vaccinations or multiple milkings) are strictly decomposed into individual tuple rows in child tables.

### 2NF: Full Functional Dependency
* In composite key table `sale_item(sale_id, yield_id)`, attributes `quantity_sold` and `unit_price` depend strictly on the **entire composite key**, not any subset.
* Buyer contact details were removed from `sale` and housed in `buyer` to eliminate partial functional dependency on invoice IDs.

### 3NF: No Transitive Dependencies
* In `animal`, `animal_id → breed_id` and `breed_id → breed_name`. Keeping `breed_name` in `animal` creates a transitive dependency (`animal_id → breed_name`). Decomposed into separate `breed` table.
* In milk operations, shift details belong to `milking_session`, while volume belongs to `milk_yield`.

---

### Business Automation: 4 Active Triggers & 1 View
#### Enforcing Domain Logic at the Storage Engine Layer

### Active Server-Side Triggers
* **`before_feed_issue`**: Validates `feed_item.available_quantity`. Raises `SIGNAL SQLSTATE '45000'` if dispensation exceeds physical inventory, preventing negative stock.
* **`after_feed_issue`**: Atomically decrements `feed_item.available_quantity` upon each confirmed cattle feed issuance.
* **`after_sale_item`**: Automatically computes `(quantity_sold * unit_price)` and increments `sale.total_amount`.
* **`after_payment`**: Updates financial ledgers and calculates outstanding balances in real time.

### Derived Analytical View: `animal_milk_summary`
```sql
CREATE VIEW animal_milk_summary AS
SELECT 
    a.animal_id, a.animal_tag, b.breed_name,
    COUNT(my.yield_id) AS total_sessions,
    COALESCE(SUM(my.quantity_litres), 0) AS total_litres,
    COALESCE(AVG(my.quantity_litres), 0) AS avg_yield_per_session
FROM animal a
JOIN breed b ON a.breed_id = b.breed_id
LEFT JOIN milking_session ms ON a.animal_id = ms.animal_id
LEFT JOIN milk_yield my ON ms.session_id = my.session_id
GROUP BY a.animal_id, a.animal_tag, b.breed_name;
```

---

### Comprehensive SQL Query Pack: 30+ Production Queries
#### Covering All Relational Algebra Operations on Live Data

### Filtering & Aggregation
* **`DISTINCT` & `BETWEEN`**: Extract active breeds and filter lactation cycles within specified date ranges.
* **`LIKE` & `IN`**: Regex/wildcard search on ear tags (`A10%`) and set-based status checks.
* **`GROUP BY` with `HAVING`**: Group yields by shift and isolate high-producing cattle exceeding 20.0 L thresholds.

### Advanced Joins & Subqueries
* **Multi-Table Inner Joins**: Linking cattle, health examinations, and veterinary recommendations.
* **Left Outer Joins**: Auditing milking lots with pending laboratory quality assays.
* **Scalar & Correlated Subqueries**: Identifying top milk-producing cattle per breed relative to herd averages.
* **Self-Joins**: Tracing sire pedigree lineage in `breeding_event`.

---

### Feature Query #29: End-to-End Relationship Trace
#### Deep Relational Traversal for Animal #20 (`animal_id = 20`)

```sql
SELECT 
    a.animal_id, a.animal_tag, b.breed_name,
    my.quantity_litres, qt.fat_percentage, qt.snf_percentage,
    si.quantity_sold, s.total_amount, bu.buyer_name
FROM animal a
JOIN breed b ON a.breed_id = b.breed_id
JOIN milking_session ms ON a.animal_id = ms.animal_id
JOIN milk_yield my ON ms.session_id = my.session_id
LEFT JOIN quality_test qt ON my.yield_id = qt.yield_id
LEFT JOIN sale_item si ON my.yield_id = si.yield_id
LEFT JOIN sale s ON si.sale_id = s.sale_id
LEFT JOIN buyer bu ON s.buyer_id = bu.buyer_id
WHERE a.animal_id = 20;
```

### Verified Live Output (MySQL 8.0 Execution: 1.38 ms)
| animal_id | Cattle Name & Tag | breed_name | quantity_litres | fat_percentage | snf_percentage | quantity_sold | total_amount | buyer_name |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **20** | **Mangala (A1020)** | **Nagori** | **24.0 L** | **3.50%** | **8.90%** | **7.0 L** | **₹343.00** | **Heritage Fresh Dairy Union** |

---

### Database Volume, Testing & ACID Integrity
#### 50 Rows Per Table (700 Total Tuples) Formally Verified

> **Atomicity Test**: Multi-table insertions across `milking_session` and `milk_yield` are wrapped in `START TRANSACTION ... COMMIT`. Uncaught exceptions trigger automatic `ROLLBACK`, guaranteeing zero orphaned sessions.

> **Consistency & Constraint Test**: Attempting to insert a duplicate `animal_tag` violates the `UNIQUE KEY` constraint with error `ER_DUP_ENTRY (1062)`. Negative yield inputs violate the `CHECK (quantity_litres > 0)` constraint.

> **Isolation & Durability Test**: MySQL InnoDB engine operates under **Repeatable Read** isolation with ACID durability ensured by Write-Ahead Logging (WAL) and doublewrite buffers.

---

### Viva Defense Summary: Key Questions & Answers
#### Architectural Insights Prepared for Faculty Evaluation

* **Q: Why separate `milking_session` and `milk_yield` instead of one table?**  
  *A:* To achieve strict 3NF. Operational shift details and timestamps belong to the session entity; individual volume yields per lot belong to the harvest entity.
* **Q: What is the purpose of `ON DELETE CASCADE` on `animal_id`?**  
  *A:* When a cattle record is expunged from the registry, all linked clinical visits, vaccinations, and milking logs are automatically purged to prevent dangling foreign key references.
* **Q: How does the trigger prevent negative inventory?**  
  *A:* `before_feed_issue` inspects `feed_item.available_quantity`. If `NEW.quantity > available_quantity`, it raises a `SIGNAL SQLSTATE '45000'` that aborts the transaction before disk writes.
