-- Seed 10 drivers for ATMS (idempotent)
-- Passwords pattern: Driver1@2026 ... Driver10@2026

INSERT INTO users (full_name, email, username, role, license_number, status, is_active, password_hash)
VALUES
    ('Driver One', 'driver1@fleetflow.local', 'driver1', 'DRIVER', 'DL-ATMS-001', 'AVAILABLE', TRUE, crypt('Driver1@2026', gen_salt('bf', 12))),
    ('Driver Two', 'driver2@fleetflow.local', 'driver2', 'DRIVER', 'DL-ATMS-002', 'AVAILABLE', TRUE, crypt('Driver2@2026', gen_salt('bf', 12))),
    ('Driver Three', 'driver3@fleetflow.local', 'driver3', 'DRIVER', 'DL-ATMS-003', 'AVAILABLE', TRUE, crypt('Driver3@2026', gen_salt('bf', 12))),
    ('Driver Four', 'driver4@fleetflow.local', 'driver4', 'DRIVER', 'DL-ATMS-004', 'AVAILABLE', TRUE, crypt('Driver4@2026', gen_salt('bf', 12))),
    ('Driver Five', 'driver5@fleetflow.local', 'driver5', 'DRIVER', 'DL-ATMS-005', 'AVAILABLE', TRUE, crypt('Driver5@2026', gen_salt('bf', 12))),
    ('Driver Six', 'driver6@fleetflow.local', 'driver6', 'DRIVER', 'DL-ATMS-006', 'AVAILABLE', TRUE, crypt('Driver6@2026', gen_salt('bf', 12))),
    ('Driver Seven', 'driver7@fleetflow.local', 'driver7', 'DRIVER', 'DL-ATMS-007', 'AVAILABLE', TRUE, crypt('Driver7@2026', gen_salt('bf', 12))),
    ('Driver Eight', 'driver8@fleetflow.local', 'driver8', 'DRIVER', 'DL-ATMS-008', 'AVAILABLE', TRUE, crypt('Driver8@2026', gen_salt('bf', 12))),
    ('Driver Nine', 'driver9@fleetflow.local', 'driver9', 'DRIVER', 'DL-ATMS-009', 'AVAILABLE', TRUE, crypt('Driver9@2026', gen_salt('bf', 12))),
    ('Driver Ten', 'driver10@fleetflow.local', 'driver10', 'DRIVER', 'DL-ATMS-010', 'AVAILABLE', TRUE, crypt('Driver10@2026', gen_salt('bf', 12)))
ON CONFLICT (username)
DO UPDATE SET
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    role = EXCLUDED.role,
    license_number = EXCLUDED.license_number,
    status = EXCLUDED.status,
    is_active = EXCLUDED.is_active,
    password_hash = crypt(
        CASE EXCLUDED.username
            WHEN 'driver1' THEN 'Driver1@2026'
            WHEN 'driver2' THEN 'Driver2@2026'
            WHEN 'driver3' THEN 'Driver3@2026'
            WHEN 'driver4' THEN 'Driver4@2026'
            WHEN 'driver5' THEN 'Driver5@2026'
            WHEN 'driver6' THEN 'Driver6@2026'
            WHEN 'driver7' THEN 'Driver7@2026'
            WHEN 'driver8' THEN 'Driver8@2026'
            WHEN 'driver9' THEN 'Driver9@2026'
            WHEN 'driver10' THEN 'Driver10@2026'
            ELSE 'Driver@2026'
        END,
        gen_salt('bf', 12)
    );
