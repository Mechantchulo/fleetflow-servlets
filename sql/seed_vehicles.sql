-- Seed buses with mixed capacities/statuses for ATMS
-- Safe to re-run.

INSERT INTO vehicle (plate_number, capacity, mileage, status)
VALUES
    ('KDA 123A', 14, 124500, 'AVAILABLE'),
    ('KDE 519E', 18, 168200, 'AVAILABLE'),
    ('KDD 401D', 25, 206900, 'AVAILABLE'),
    ('KCF 772Q', 29, 114300, 'AVAILABLE'),
    ('KDG 220N', 33, 189400, 'AVAILABLE'),
    ('KDJ 904R', 37, 254700, 'AVAILABLE'),
    ('KDM 115Z', 45, 298100, 'AVAILABLE'),
    ('KDN 550U', 52, 311000, 'AVAILABLE'),
    ('KDP 702M', 33, 267900, 'MAINTENANCE'),
    ('KDQ 818V', 60, 342800, 'AVAILABLE')
ON CONFLICT (plate_number)
DO UPDATE SET
    capacity = EXCLUDED.capacity,
    mileage = EXCLUDED.mileage,
    status = EXCLUDED.status;
