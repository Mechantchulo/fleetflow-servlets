# Dean Servlet Testing Guide
## Complete Setup & Testing for Tomcat + NetBeans + PostgreSQL + Maven

---

## 🚀 PREREQUISITES CHECK

### Verify Software Versions
```bash
# Check Java version (should be 17+)
java -version

# Check Maven version
mvn -version

# Check PostgreSQL
psql --version

# Check Tomcat (if installed separately)
catalina version
```

### Required Versions
- **Java**: 17 or higher
- **Maven**: 3.6+ 
- **PostgreSQL**: 12+
- **Tomcat**: 10+ (Jakarta EE compatible)
- **NetBeans**: 12+ with Java EE support

---

## 📋 STEP-BY-STEP SETUP

### 1. Database Setup

#### 1.1 Create Database
```sql
-- Connect to PostgreSQL as superuser
psql -U postgres

-- Create database
CREATE DATABASE fleetflow;

-- Create user (optional, for security)
CREATE USER fleetflow_user WITH PASSWORD 'fleetflow2026';
GRANT ALL PRIVILEGES ON DATABASE fleetflow TO fleetflow_user;

-- Connect to fleetflow database
\c fleetflow
```

#### 1.2 Create Required Tables
```sql
-- Trip requests table
CREATE TABLE trip_request (
    id BIGSERIAL PRIMARY KEY,
    destination VARCHAR(255) NOT NULL,
    departure_time TIMESTAMP,
    passenger_count INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'PENDING',
    requester_id BIGINT,
    manager_note TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Users table  
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    full_name VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    role VARCHAR(50),
    license_number VARCHAR(100),
    status VARCHAR(50) DEFAULT 'AVAILABLE',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Vehicle table
CREATE TABLE vehicle (
    id BIGSERIAL PRIMARY KEY,
    plate_number VARCHAR(50) UNIQUE NOT NULL,
    capacity INTEGER DEFAULT 0,
    mileage BIGINT DEFAULT 0,
    status VARCHAR(50) DEFAULT 'AVAILABLE',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Trip assignment table
CREATE TABLE trip_assignment (
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

-- Insert sample data for testing
INSERT INTO users (full_name, email, role, status) VALUES
('John Driver', 'driver1@fleet.com', 'DRIVER', 'AVAILABLE'),
('Jane Driver', 'driver2@fleet.com', 'DRIVER', 'ASSIGNED'),
('Mike Manager', 'manager@fleet.com', 'TRANSPORT_MANAGER', 'AVAILABLE');

INSERT INTO vehicle (plate_number, capacity, mileage, status) VALUES
('ABC-123', 45, 15000, 'AVAILABLE'),
('XYZ-789', 30, 25000, 'ASSIGNED'),
('DEF-456', 50, 8000, 'MAINTENANCE');

INSERT INTO trip_request (destination, departure_time, passenger_count, status, requester_id) VALUES
('Airport Terminal 1', NOW() + INTERVAL '1 day', 35, 'PENDING', 1),
('Downtown Office', NOW() + INTERVAL '2 days', 15, 'APPROVED', 2),
('Conference Center', NOW() + INTERVAL '3 hours', 50, 'ASSIGNED', 1);
```

### 2. Project Setup in NetBeans

#### 2.1 Import Project
1. Open NetBeans
2. File → Open Project
3. Navigate to `fleetflow-servlets` directory
4. Select the project and click "Open Project"

#### 2.2 Configure Database Connection
Create or update `.env` file in project root:
```properties
DB_HOST=localhost
DB_PORT=5432
DB_NAME=fleetflow
DB_USER=postgres
DB_PASSWORD=fleetflow2026
```

#### 2.3 Verify Tomcat Server in NetBeans
1. Services tab → Servers
2. Right-click → Add Server
3. Select Apache Tomcat
4. Point to Tomcat installation directory
5. Set admin username/password

### 3. Build & Deploy

#### 3.1 Clean and Build
```bash
# In NetBeans: Right-click project → Clean and Build
# Or via command line:
mvn clean install
```

#### 3.2 Deploy to Tomcat
```bash
# Option 1: Via NetBeans
# Right-click project → Run

# Option 2: Manual deployment
cp target/FleetflowServlets-1.0-SNAPSHOT.war /path/to/tomcat/webapps/

# Option 3: Via Maven
mvn tomcat7:deploy
```

---

## 🧪 FUNCTIONALITY TESTING

### Test 1: Basic Access
```bash
# Open browser and navigate to:
http://localhost:8080/FleetflowServlets-1.0-SNAPSHOT/dean/dashboard
```

**Expected**: Should show login form

### Test 2: Login Functionality
1. **Valid Credentials**:
   - Username: `dean`
   - Password: `dean123`
   
2. **Invalid Credentials**:
   - Username: `wrong`
   - Password: `wrong`

**Expected**: 
- Valid: Redirect to dashboard with statistics
- Invalid: Show error message

### Test 3: Dashboard Statistics
After successful login, verify:
- ✅ Pending trips count
- ✅ Approved trips count  
- ✅ Today's trips count
- ✅ Fleet utilization numbers
- ✅ Recent trips table

### Test 4: Session Management
1. Login successfully
2. Open new tab and navigate to: `http://localhost:8080/FleetflowServlets-1.0-SNAPSHOT/dean/dashboard`
3. Should show dashboard (not login form)

### Test 5: Logout Functionality
```bash
# Navigate to:
http://localhost:8080/FleetflowServlets-1.0-SNAPSHOT/dean/logout
```

**Expected**: Should logout and redirect to login form

---

## 🔍 DEBUGGING CHECKLIST

### If Login Doesn't Work:
1. **Check Database Connection**:
   ```bash
   # Test connection
   psql -h localhost -p 5432 -U postgres -d fleetflow
   ```

2. **Check Tomcat Logs**:
   ```bash
   # Look for deployment errors
   tail -f /path/to/tomcat/logs/catalina.out
   ```

3. **Check Session Attributes**:
   - Add debug logging in DeanServlet
   - Verify session is being created properly

### If Dashboard Shows No Data:
1. **Verify Database Tables**:
   ```sql
   SELECT COUNT(*) FROM trip_request;
   SELECT COUNT(*) FROM users;
   SELECT COUNT(*) FROM vehicle;
   ```

2. **Check SQL Queries**:
   - Verify table names match exactly
   - Check column names in queries

### If Page Not Found (404):
1. **Check Deployment**:
   ```bash
   # Verify WAR file is deployed
   ls /path/to/tomcat/webapps/
   ```

2. **Check URL Pattern**:
   - Verify context path is correct
   - Check servlet mapping in DeanServlet

---

## 📱 TESTING ON DIFFERENT DEVICES

### Device Setup Requirements:
1. **Same Network**: Ensure both devices are on the same network
2. **Firewall**: Open port 8080 on the server machine
3. **Database Access**: Ensure PostgreSQL accepts remote connections

### Remote Access Configuration:
```bash
# On server machine, find IP address
ipconfig  # Windows
ifconfig  # Linux/Mac

# Update PostgreSQL to accept remote connections
# Edit: postgresql.conf
listen_addresses = '*'

# Edit: pg_hba.conf  
host    all             all             0.0.0.0/0               md5

# Restart PostgreSQL
sudo systemctl restart postgresql
```

### Cross-Device Testing URL:
```
http://[SERVER_IP]:8080/FleetflowServlets-1.0-SNAPSHOT/dean/dashboard
```

---

## ✅ SUCCESS CRITERIA

### Functional Requirements:
- [ ] Login page loads correctly
- [ ] Valid credentials authenticate successfully  
- [ ] Invalid credentials show error message
- [ ] Dashboard displays statistics
- [ ] Recent trips table shows data
- [ ] Fleet utilization numbers appear
- [ ] Logout functionality works
- [ ] Session persistence across tabs

### Technical Requirements:
- [ ] No deployment errors in Tomcat logs
- [ ] Database connections succeed
- [ ] SQL queries execute without errors
- [ ] JSP pages render correctly
- [ ] CSS and JavaScript load properly

---

## 🚨 COMMON ISSUES & SOLUTIONS

### Issue 1: "Database connection failed"
**Solution**: Check PostgreSQL service status and connection parameters

### Issue 2: "404 Not Found"  
**Solution**: Verify WAR file deployment and context path

### Issue 3: "500 Internal Server Error"
**Solution**: Check Tomcat logs for stack trace

### Issue 4: "Login redirects to same page"
**Solution**: Check session creation and attribute setting

### Issue 5: "Dashboard shows zeros"
**Solution**: Verify database tables have data and SQL queries are correct

---

## 📞 SUPPORT & TROUBLESHOOTING

### Log Files to Monitor:
1. **Tomcat Logs**: `/path/to/tomcat/logs/catalina.out`
2. **Application Logs**: Check NetBeans output console
3. **Database Logs**: PostgreSQL error logs

### Quick Test Commands:
```bash
# Test database connection
psql -h localhost -p 5432 -U postgres -d fleetflow -c "SELECT 1;"

# Test Tomcat is running
curl http://localhost:8080/

# Test application is deployed
curl http://localhost:8080/FleetflowServlets-1.0-SNAPSHOT/
```

---

**🎯 The Dean servlet should now be fully functional and testable across different devices!**
