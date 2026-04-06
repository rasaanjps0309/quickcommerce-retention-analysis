-- User Table ---

CREATE TABLE qb.users (
    user_id VARCHAR(10) PRIMARY KEY,
    city VARCHAR(50),
    device_os VARCHAR(20),
    age INTEGER,
    gender VARCHAR(20), -- Changed from CHAR(1) to VARCHAR
    acquisition_source VARCHAR(50),
    acquisition_cost NUMERIC(10, 2),
    signup_datetime TIMESTAMP,
    referral_source VARCHAR(50),
    first_order_datetime TIMESTAMP,
    is_loyalty_member INTEGER
);


-- Orders Table --- 
CREATE TABLE qb.orders (
    user_id VARCHAR(10),
    order_id VARCHAR(20) PRIMARY KEY,
    order_placed_datetime TIMESTAMP,
    order_value NUMERIC(10, 2),
    item_count INTEGER,
    preparation_time_mins NUMERIC(10, 2),
    agent_assigned_time_mins NUMERIC(10, 2),
    delivery_time_mins NUMERIC(10, 2),
    order_status VARCHAR(20),
    discount_value NUMERIC(10, 2),
    coupon_code VARCHAR(20),
    payment_method VARCHAR(20),
    is_first_order INTEGER
);


-- events summary tabe ---
CREATE TABLE qb.event_summary (
    user_id VARCHAR(10),
    total_session_count INTEGER,
    total_category_browse_count INTEGER,
    added_to_cart VARCHAR(5), -- For 'yes'/'no' values
    cart_value NUMERIC(10, 2),
    search_count INTEGER,
    days_active_last_7 INTEGER,
    event_count INTEGER
);


-- Experiment Data table 

CREATE TABLE qb.quickbasket_experiment (
    user_id TEXT PRIMARY KEY,
    experiment_group TEXT,
    city TEXT,
    device_os TEXT,
    acquisition_channel TEXT,
    acquisition_cost NUMERIC,

    first_order_datetime TIMESTAMP,
    first_order_value NUMERIC,
    first_order_delivery_time_mins NUMERIC,
    first_order_discount_value NUMERIC,
    first_order_item_count INTEGER,
    first_order_payment_method TEXT,

    returned_7d INTEGER,

    second_order_datetime TIMESTAMP,
    second_order_value NUMERIC,
    second_order_delivery_time_mins NUMERIC,
    second_order_discount_value NUMERIC,
    second_order_item_count NUMERIC,
    second_order_status TEXT,
    second_order_payment_method TEXT,

    w2_returned INTEGER,
    w2_order_value NUMERIC
);