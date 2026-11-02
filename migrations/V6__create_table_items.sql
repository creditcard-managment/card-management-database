-- =============================================
-- Table: transaction_items
-- =============================================
CREATE TABLE transaction_items (
                                   item_id         UUID            NOT NULL,
                                   transaction_id  UUID            NOT NULL,
                                   item_description VARCHAR(500),
                                   quantity        INTEGER         NOT NULL DEFAULT 1,
                                   unit_price      NUMERIC(15, 2)  NOT NULL,
                                   total_amount    NUMERIC(15, 2)  NOT NULL,
                                   created_at      TIMESTAMP       NOT NULL DEFAULT NOW(),

                                   CONSTRAINT pk_transaction_items PRIMARY KEY (item_id),
                                   CONSTRAINT fk_transaction_items_transaction
                                       FOREIGN KEY (transaction_id)
                                           REFERENCES transactions(transaction_id)
                                           ON DELETE CASCADE
);

CREATE INDEX idx_transaction_items_transaction_id
    ON transaction_items (transaction_id);