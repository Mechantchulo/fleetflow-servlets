-- Timetabling submission + budget workflow migration
-- Run this on existing databases.

ALTER TABLE timetable_entry
    ADD COLUMN IF NOT EXISTS budget_amount NUMERIC(12,2) DEFAULT 0,
    ADD COLUMN IF NOT EXISTS source_trip_request_id BIGINT,
    ADD COLUMN IF NOT EXISTS submitted_at TIMESTAMP,
    ADD COLUMN IF NOT EXISTS submitted_by_id BIGINT REFERENCES users(id);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_timetable_entry_source_trip_request'
    ) THEN
        ALTER TABLE timetable_entry
            ADD CONSTRAINT fk_timetable_entry_source_trip_request
                FOREIGN KEY (source_trip_request_id)
                REFERENCES trip_request(id);
    END IF;
END$$;

ALTER TABLE trip_request
    ADD COLUMN IF NOT EXISTS planned_budget NUMERIC(12,2) DEFAULT 0,
    ADD COLUMN IF NOT EXISTS source_timetable_entry_id BIGINT;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_trip_request_source_timetable_entry'
    ) THEN
        ALTER TABLE trip_request
            ADD CONSTRAINT fk_trip_request_source_timetable_entry
                FOREIGN KEY (source_timetable_entry_id)
                REFERENCES timetable_entry(id);
    END IF;
END$$;

CREATE UNIQUE INDEX IF NOT EXISTS ux_trip_request_source_timetable_entry_id
    ON trip_request(source_timetable_entry_id)
    WHERE source_timetable_entry_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_timetable_entry_submitted_at ON timetable_entry(submitted_at);
CREATE INDEX IF NOT EXISTS idx_timetable_entry_source_trip_request_id ON timetable_entry(source_trip_request_id);
