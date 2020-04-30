\connect blobber_meta;

BEGIN;

    ALTER TABLE terms
        ADD COLUMN allocation_id varchar(64) REFERENCES allocations (id);

    UPDATE terms AS t
    SET allocation_id = a.id
    FROM allocations AS a
    WHERE t.allocation_tx = a.tx;

    ALTER TABLE terms DROP COLUMN allocation_tx;

COMMIT;

-- for the commit_meta_txns
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO blobber_user;