CREATE TABLE IF NOT EXISTS driver_trip_log (
    id BIGSERIAL PRIMARY KEY,
    driver_id BIGINT NOT NULL REFERENCES users(id),
    trip_request_id BIGINT NOT NULL REFERENCES trip_request(id),
    report_type VARCHAR(30) DEFAULT 'OTHER',
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    report_notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_driver_trip_log_driver_id ON driver_trip_log(driver_id);
CREATE INDEX IF NOT EXISTS idx_driver_trip_log_trip_request_id ON driver_trip_log(trip_request_id);
