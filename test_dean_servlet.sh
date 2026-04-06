#!/bin/bash

echo "========================================"
echo "Dean Servlet Automated Testing Script"
echo "========================================"
echo

echo "[1/6] Checking Java version..."
if ! command -v java &> /dev/null; then
    echo "ERROR: Java not found or not in PATH"
    exit 1
fi
java -version
echo

echo "[2/6] Checking Maven..."
if ! command -v mvn &> /dev/null; then
    echo "ERROR: Maven not found or not in PATH"
    exit 1
fi
mvn -version
echo

echo "[3/6] Building project..."
if ! mvn clean install; then
    echo "ERROR: Build failed"
    exit 1
fi
echo "Build successful!"
echo

echo "[4/6] Checking if Tomcat is running..."
if ! netstat -an | grep -q ":8080"; then
    echo "WARNING: Tomcat may not be running on port 8080"
    echo "Please start Tomcat before continuing"
fi
echo

echo "[5/6] Testing database connection..."
echo "Testing PostgreSQL connection..."
if ! psql -h localhost -p 5432 -U postgres -d fleetflow -c "SELECT 1;" &> /dev/null; then
    echo "WARNING: Cannot connect to PostgreSQL database"
    echo "Please ensure PostgreSQL is running and database 'fleetflow' exists"
fi
echo

echo "[6/6] Opening browser for manual testing..."
echo
echo "========================================"
echo "TESTING URLs:"
echo "========================================"
echo
echo "1. Login Page:"
echo "   http://localhost:8080/FleetflowServlets-1.0-SNAPSHOT/dean/dashboard"
echo
echo "2. Logout:"
echo "   http://localhost:8080/FleetflowServlets-1.0-SNAPSHOT/dean/logout"
echo
echo "3. Test Credentials:"
echo "   Username: dean"
echo "   Password: dean123"
echo
echo "========================================"
echo "Opening browser in 3 seconds..."
sleep 3

# Try different browsers based on OS
if command -v google-chrome &> /dev/null; then
    google-chrome http://localhost:8080/FleetflowServlets-1.0-SNAPSHOT/dean/dashboard &
elif command -v firefox &> /dev/null; then
    firefox http://localhost:8080/FleetflowServlets-1.0-SNAPSHOT/dean/dashboard &
elif command -v open &> /dev/null; then
    open http://localhost:8080/FleetflowServlets-1.0-SNAPSHOT/dean/dashboard
else
    echo "Could not auto-open browser. Please manually navigate to the URL above."
fi

echo
echo "========================================"
echo "TESTING COMPLETE!"
echo "========================================"
echo
echo "Manual testing checklist:"
echo "[ ] Login page loads"
echo "[ ] Login with dean/dean123 works"
echo "[ ] Dashboard shows statistics"
echo "[ ] Recent trips appear"
echo "[ ] Fleet utilization shows data"
echo "[ ] Logout functionality works"
echo
echo "Check Tomcat logs for any errors:"
echo "\$CATALINA_HOME/logs/catalina.out"
echo
