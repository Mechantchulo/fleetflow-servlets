-- Add department to users for staff profile linkage

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS department VARCHAR(150);

CREATE INDEX IF NOT EXISTS idx_users_role_department
    ON users(role, department);
