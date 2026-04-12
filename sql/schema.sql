-- Fleetflow schema (idempotent)

CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    full_name VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    username VARCHAR(80) UNIQUE,
    password_hash TEXT,
    role VARCHAR(50),
    department VARCHAR(150),
    license_number VARCHAR(100),
    status VARCHAR(50) DEFAULT 'AVAILABLE',
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS department VARCHAR(150);

CREATE TABLE IF NOT EXISTS vehicle (
    id BIGSERIAL PRIMARY KEY,
    plate_number VARCHAR(50) UNIQUE NOT NULL,
    capacity INTEGER DEFAULT 0,
    mileage BIGINT DEFAULT 0,
    status VARCHAR(50) DEFAULT 'AVAILABLE',
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS trip_request (
    id BIGSERIAL PRIMARY KEY,
    destination VARCHAR(255) NOT NULL,
    requesting_department VARCHAR(150),
    departure_time TIMESTAMP,
    passenger_count INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'PENDING',
    trip_type VARCHAR(20) DEFAULT 'ACADEMIC',
    requester_id BIGINT REFERENCES users(id),
    planned_budget NUMERIC(12,2) DEFAULT 0,
    source_timetable_entry_id BIGINT,
    manager_note TEXT,
    document_name VARCHAR(255),
    document_mime_type VARCHAR(120),
    document_data BYTEA,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS trip_assignment (
    id BIGSERIAL PRIMARY KEY,
    trip_request_id BIGINT REFERENCES trip_request(id),
    vehicle_id BIGINT REFERENCES vehicle(id),
    driver_id BIGINT REFERENCES users(id),
    assigned_by_id BIGINT REFERENCES users(id),
    assigned_at TIMESTAMP,
    status VARCHAR(50) DEFAULT 'ASSIGNED',
    override_used BOOLEAN DEFAULT FALSE,
    override_reason TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS timetable_entry (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    department VARCHAR(150),
    destination VARCHAR(255) NOT NULL,
    departure_time TIMESTAMP NOT NULL,
    expected_passenger_count INTEGER DEFAULT 0,
    budget_amount NUMERIC(12,2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'PUBLISHED',
    created_by_id BIGINT REFERENCES users(id),
    source_trip_request_id BIGINT,
    submitted_at TIMESTAMP,
    submitted_by_id BIGINT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

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
    ADD COLUMN IF NOT EXISTS source_timetable_entry_id BIGINT,
    ADD COLUMN IF NOT EXISTS requesting_department VARCHAR(150),
    ADD COLUMN IF NOT EXISTS document_name VARCHAR(255),
    ADD COLUMN IF NOT EXISTS document_mime_type VARCHAR(120),
    ADD COLUMN IF NOT EXISTS document_data BYTEA;

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

CREATE INDEX IF NOT EXISTS idx_trip_request_status ON trip_request(status);
CREATE INDEX IF NOT EXISTS idx_trip_request_departure_time ON trip_request(departure_time);
CREATE INDEX IF NOT EXISTS idx_trip_request_trip_type ON trip_request(trip_type);
CREATE INDEX IF NOT EXISTS idx_trip_request_requesting_department ON trip_request(requesting_department);
CREATE INDEX IF NOT EXISTS idx_trip_assignment_trip_request_id ON trip_assignment(trip_request_id);
CREATE INDEX IF NOT EXISTS idx_trip_assignment_driver_id ON trip_assignment(driver_id);
CREATE INDEX IF NOT EXISTS idx_trip_assignment_vehicle_id ON trip_assignment(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_timetable_entry_departure_time ON timetable_entry(departure_time);
CREATE INDEX IF NOT EXISTS idx_timetable_entry_status ON timetable_entry(status);
CREATE INDEX IF NOT EXISTS idx_timetable_entry_source_trip_request_id ON timetable_entry(source_trip_request_id);
CREATE INDEX IF NOT EXISTS idx_driver_trip_log_driver_id ON driver_trip_log(driver_id);
CREATE INDEX IF NOT EXISTS idx_driver_trip_log_trip_request_id ON driver_trip_log(trip_request_id);
CREATE UNIQUE INDEX IF NOT EXISTS ux_trip_request_source_timetable_entry_id
    ON trip_request(source_timetable_entry_id)
    WHERE source_timetable_entry_id IS NOT NULL;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_trip_type'
    ) THEN
        ALTER TABLE trip_request
            ADD CONSTRAINT chk_trip_type
            CHECK (trip_type IN ('ACADEMIC', 'CLUB'));
    END IF;
END$$;
