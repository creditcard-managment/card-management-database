-- =============================================
-- Migration: V6
-- Date: 2026-04-27
-- Description: create table transactions
-- =============================================

CREATE TABLE transactions (
                              transaction_id              UUID            NOT NULL,

    -- FK hacia cards(id) y merchants(id) → VARCHAR(36)
                              card_id                     VARCHAR(36)     NOT NULL,
                              merchant_id                 VARCHAR(36)     NOT NULL,

    -- Enums
                              transaction_type            VARCHAR(50)     NOT NULL,
                              transaction_status          VARCHAR(50)     NOT NULL,
                              payment_method              VARCHAR(50)     NOT NULL,

    -- Amount Information
                              amount                      NUMERIC(15, 2)  NOT NULL,
                              currency                    VARCHAR(3)      NOT NULL,
                              local_amount                NUMERIC(15, 2),
                              local_currency              VARCHAR(3),
                              exchange_rate               NUMERIC(10, 6),

    -- Card Information (PCI Compliant - Tokenized)
                              card_number_token           VARCHAR(100)    NOT NULL,
                              card_last_four              VARCHAR(4)      NOT NULL,
                              card_holder_name            VARCHAR(100),
                              expiration_date             VARCHAR(7),

    -- Authorization
                              authorization_code          VARCHAR(50),
                              authorization_date          TIMESTAMP,
                              authorization_response_code VARCHAR(10),

    -- Merchant Information
                              merchant_category_code      VARCHAR(4),
                              merchant_name               VARCHAR(200),
                              merchant_city               VARCHAR(100),
                              merchant_country            VARCHAR(2),

    -- Transaction Details
                              terminal_id                 VARCHAR(50),
                              pos_entry_mode              VARCHAR(20),
                              transaction_date            TIMESTAMP       NOT NULL,
                              settlement_date             TIMESTAMP,

    -- Fraud & Risk
                              risk_score                  INTEGER,
                              fraud_check_status          VARCHAR(20),

    -- Status Information
                              decline_reason              VARCHAR(500),
                              reversal_reason             VARCHAR(500),

    -- Audit Fields
                              created_at                  TIMESTAMP       NOT NULL DEFAULT NOW(),
                              updated_at                  TIMESTAMP       NOT NULL DEFAULT NOW(),
                              created_by                  VARCHAR(100),
                              version                     INTEGER         NOT NULL DEFAULT 0,

                              CONSTRAINT pk_transactions PRIMARY KEY (transaction_id),
                              CONSTRAINT fk_transactions_card
                                  FOREIGN KEY (card_id)
                                      REFERENCES cards(id)
                                      ON DELETE RESTRICT,
                              CONSTRAINT fk_transactions_merchant
                                  FOREIGN KEY (merchant_id)
                                      REFERENCES merchants(id)
                                      ON DELETE RESTRICT
);

CREATE INDEX idx_transactions_card_id         ON transactions (card_id);
CREATE INDEX idx_transactions_merchant_id     ON transactions (merchant_id);
CREATE INDEX idx_transactions_status          ON transactions (transaction_status);
CREATE INDEX idx_transactions_date            ON transactions (transaction_date);
CREATE INDEX idx_transactions_settlement_date ON transactions (settlement_date);
CREATE INDEX idx_transactions_auth_code       ON transactions (authorization_code);
