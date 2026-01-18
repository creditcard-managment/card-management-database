-- V1__Initial_Schema.sql
-- Initial database schema for Merchant Management

-- ==========================================
-- MERCHANTS TABLE
-- ==========================================
CREATE TABLE merchants (
    id VARCHAR(36) PRIMARY KEY,

    -- Business Information
    legal_name VARCHAR(300) NOT NULL,
    trade_name VARCHAR(300),
    registration_number VARCHAR(50) NOT NULL,
    business_description VARCHAR(1000),
    years_in_business INTEGER,

    -- Tax Information
    tax_id VARCHAR(20) NOT NULL UNIQUE,
    tax_category VARCHAR(100) NOT NULL,
    vat_responsible BOOLEAN NOT NULL DEFAULT false,
    tax_address VARCHAR(500),

    -- Contact Information
    contact_name VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL UNIQUE,
    phone VARCHAR(50) NOT NULL,
    website VARCHAR(500),

    -- Address
    street_address VARCHAR(200) NOT NULL,
    street_number VARCHAR(20) NOT NULL,
    floor VARCHAR(20),
    apartment VARCHAR(20),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,

    -- Classification
    category VARCHAR(50) NOT NULL,
    type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,

    -- Timestamps
    registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activated_at TIMESTAMP,
    last_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Optimistic Locking
    version INTEGER NOT NULL DEFAULT 0
);

-- Indexes for Merchants
CREATE INDEX idx_merchant_tax_id ON merchants(tax_id);
CREATE INDEX idx_merchant_email ON merchants(email);
CREATE INDEX idx_merchant_status ON merchants(status);
CREATE INDEX idx_merchant_category ON merchants(category);

-- ==========================================
-- PAYMENT TERMINALS TABLE
-- ==========================================
CREATE TABLE payment_terminals (
    id VARCHAR(36) PRIMARY KEY,
    merchant_id VARCHAR(36) NOT NULL,
    serial_number VARCHAR(50) NOT NULL UNIQUE,
    terminal_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,

    -- Terminal Configuration
    max_transaction_amount NUMERIC(15, 2),
    min_transaction_amount NUMERIC(15, 2),
    allow_refunds BOOLEAN DEFAULT true,
    allow_voids BOOLEAN DEFAULT true,
    allow_partial_approvals BOOLEAN DEFAULT false,
    require_signature BOOLEAN DEFAULT true,
    signature_threshold NUMERIC(15, 2),
    require_pin BOOLEAN DEFAULT true,
    timeout_seconds INTEGER DEFAULT 30,
    currency VARCHAR(3) DEFAULT 'ARS',

    -- POS Terminal specific fields
    manufacturer VARCHAR(100),
    model VARCHAR(100),
    firmware_version VARCHAR(50),
    has_contactless_reader BOOLEAN DEFAULT false,
    has_chip_reader BOOLEAN DEFAULT false,
    has_magnetic_stripe_reader BOOLEAN DEFAULT false,
    has_pin_pad BOOLEAN DEFAULT false,
    has_printer BOOLEAN DEFAULT false,

    -- Virtual Terminal specific fields
    api_endpoint VARCHAR(500),
    api_version VARCHAR(20),
    supports_3d_secure BOOLEAN DEFAULT false,
    supports_tokenization BOOLEAN DEFAULT false,
    supports_recurring_payments BOOLEAN DEFAULT false,
    max_concurrent_transactions INTEGER,

    -- Mobile Terminal specific fields
    device_id VARCHAR(100),
    device_model VARCHAR(100),
    operating_system VARCHAR(50),
    app_version VARCHAR(20),
    has_external_reader BOOLEAN DEFAULT false,
    supports_bluetooth BOOLEAN DEFAULT false,
    supports_nfc BOOLEAN DEFAULT false,
    reader_serial_number VARCHAR(50),

    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activated_at TIMESTAMP,
    last_used_at TIMESTAMP,
    deactivated_at TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Optimistic Locking
    version INTEGER NOT NULL DEFAULT 0,

    FOREIGN KEY (merchant_id) REFERENCES merchants(id) ON DELETE CASCADE
);

-- Indexes for Payment Terminals
CREATE INDEX idx_terminal_merchant ON payment_terminals(merchant_id);
CREATE INDEX idx_terminal_serial ON payment_terminals(serial_number);
CREATE INDEX idx_terminal_status ON payment_terminals(status);
CREATE INDEX idx_terminal_type ON payment_terminals(terminal_type);

-- ==========================================
-- TERMINAL ACCEPTED BRANDS TABLE
-- ==========================================
CREATE TABLE terminal_accepted_brands (
    terminal_id VARCHAR(36) NOT NULL,
    card_brand VARCHAR(50) NOT NULL,
    PRIMARY KEY (terminal_id, card_brand),
    FOREIGN KEY (terminal_id) REFERENCES payment_terminals(id) ON DELETE CASCADE
);

-- ==========================================
-- TERMINAL ALLOWED IPS TABLE
-- ==========================================
CREATE TABLE terminal_allowed_ips (
    terminal_id VARCHAR(36) NOT NULL,
    ip_address VARCHAR(50) NOT NULL,
    PRIMARY KEY (terminal_id, ip_address),
    FOREIGN KEY (terminal_id) REFERENCES payment_terminals(id) ON DELETE CASCADE
);

-- ==========================================
-- MERCHANT CONTRACTS TABLE
-- ==========================================
CREATE TABLE merchant_contracts (
    id VARCHAR(36) PRIMARY KEY,
    merchant_id VARCHAR(36) NOT NULL UNIQUE,

    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    auto_renew BOOLEAN NOT NULL DEFAULT true,
    renewal_period_months INTEGER DEFAULT 12,

    -- Contract Terms
    settlement_days INTEGER NOT NULL DEFAULT 2,
    minimum_monthly_volume NUMERIC(15, 2),
    maximum_monthly_volume NUMERIC(15, 2),
    reserve_percentage NUMERIC(5, 2),
    early_termination_notice_days INTEGER DEFAULT 30,
    legal_jurisdiction VARCHAR(100),
    dispute_resolution_method VARCHAR(100),

    -- Chargeback Policy
    chargeback_fee NUMERIC(10, 2),
    max_chargeback_ratio NUMERIC(5, 2),
    warning_threshold_count INTEGER,
    warning_threshold_ratio NUMERIC(5, 2),
    review_period_days INTEGER,
    automatic_suspension_enabled BOOLEAN DEFAULT false,

    -- Service Level
    service_tier VARCHAR(50) NOT NULL,
    uptime_guarantee NUMERIC(5, 2),
    support_response_time_minutes INTEGER,
    dispute_resolution_days INTEGER,
    dedicated_account_manager BOOLEAN DEFAULT false,
    priority_support BOOLEAN DEFAULT false,
    max_transactions_per_day INTEGER,
    max_transaction_amount NUMERIC(15, 2),

    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Optimistic Locking
    version INTEGER NOT NULL DEFAULT 0,

    FOREIGN KEY (merchant_id) REFERENCES merchants(id) ON DELETE CASCADE
);

-- Indexes for Merchant Contracts
CREATE INDEX idx_contract_merchant ON merchant_contracts(merchant_id);
CREATE INDEX idx_contract_status ON merchant_contracts(status);
CREATE INDEX idx_contract_end_date ON merchant_contracts(end_date);
