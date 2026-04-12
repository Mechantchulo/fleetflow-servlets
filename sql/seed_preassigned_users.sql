-- Preassigned role accounts (hashed with bcrypt via pgcrypto crypt)
-- Run after auth_migration.sql

INSERT INTO users (full_name, email, username, role, status, is_active, password_hash)
VALUES
    ('Transport Manager', 'manager@fleetflow.local', 'manager', 'TRANSPORT_MANAGER', 'AVAILABLE', TRUE, crypt('Manager@2026', gen_salt('bf', 12))),
    ('Dean Office', 'dean@fleetflow.local', 'dean', 'DEAN', 'AVAILABLE', TRUE, crypt('Dean@2026', gen_salt('bf', 12))),
    ('Staff User', 'staff@fleetflow.local', 'staff', 'STAFF', 'AVAILABLE', TRUE, crypt('Staff@2026', gen_salt('bf', 12))),
    ('Driver User', 'driver@fleetflow.local', 'driver', 'DRIVER', 'AVAILABLE', TRUE, crypt('Driver@2026', gen_salt('bf', 12))),
    ('Timetabling Staff', 'timetabling@fleetflow.local', 'timetabling', 'TIMETABLING_STAFF', 'AVAILABLE', TRUE, crypt('Timetable@2026', gen_salt('bf', 12)))
ON CONFLICT (username)
DO UPDATE SET
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    role = EXCLUDED.role,
    status = EXCLUDED.status,
    is_active = EXCLUDED.is_active,
    password_hash = crypt(
        CASE EXCLUDED.username
            WHEN 'manager' THEN 'Manager@2026'
            WHEN 'dean' THEN 'Dean@2026'
            WHEN 'staff' THEN 'Staff@2026'
            WHEN 'driver' THEN 'Driver@2026'
            WHEN 'timetabling' THEN 'Timetable@2026'
            ELSE 'ChangeMe@2026'
        END,
        gen_salt('bf', 12)
    );
