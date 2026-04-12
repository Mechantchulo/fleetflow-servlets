-- Staff request enrichment migration
-- Adds department + optional scheduling-request PDF attachment fields.

ALTER TABLE trip_request
    ADD COLUMN IF NOT EXISTS requesting_department VARCHAR(150),
    ADD COLUMN IF NOT EXISTS document_name VARCHAR(255),
    ADD COLUMN IF NOT EXISTS document_mime_type VARCHAR(120),
    ADD COLUMN IF NOT EXISTS document_data BYTEA;

CREATE INDEX IF NOT EXISTS idx_trip_request_requesting_department
    ON trip_request(requesting_department);
