<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - FleetFlow Transport Management</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login-style.css">
</head>
<body>
    <div class="login-container">
        
        <div class="login-banner">
            <div class="banner-content">
                <div class="logo-circle">
                    <i class="fas fa-bus"></i>
                </div>
                <h1>FleetFlow</h1>
                <p>Egerton University Transport Management System</p>
                
                <div class="features">
                    <div class="feature-item"><i class="fas fa-check-circle"></i> Centralized Trip Queues</div>
                    <div class="feature-item"><i class="fas fa-check-circle"></i> Smart Fleet Allocation</div>
                    <div class="feature-item"><i class="fas fa-check-circle"></i> Real-time Driver Logs</div>
                </div>
            </div>
        </div>

        <div class="login-form-section">
            <div class="form-wrapper">
                <h2>Welcome Back</h2>
                <p class="subtitle">Please enter your credentials to continue.</p>

                <%-- Error Message Alert --%>
                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-error">
                        <i class="fas fa-exclamation-circle"></i> <%= request.getAttribute("error") %>
                    </div>
                <% } %>
                <% if (request.getAttribute("logoutMessage") != null) { %>
                    <div class="alert alert-success">
                        <i class="fas fa-check-circle"></i> <%= request.getAttribute("logoutMessage") %>
                    </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/login" method="POST" class="login-form">
                    <div class="form-group">
                        <label for="username">Username</label>
                        <div class="input-with-icon">
                            <i class="fas fa-user"></i>
                            <input type="text" id="username" name="username" placeholder="e.g. manager" required autofocus>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="password">Password</label>
                        <div class="input-with-icon">
                            <i class="fas fa-lock"></i>
                            <input type="password" id="password" name="password" placeholder="••••••••" required>
                        </div>
                    </div>

                    <button type="submit" class="btn-login">Sign In <i class="fas fa-arrow-right"></i></button>
                </form>

                <div class="demo-credentials">
                    <p><strong>Demo Access:</strong></p>
                    <div class="demo-grid">
                        <span><strong>Manager:</strong> manager / manager123</span>
                        <span><strong>Staff:</strong> staff / staff123</span>
                        <span><strong>Driver:</strong> driver / driver123</span>
                        <span><strong>Dean:</strong> dean / dean123</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
<!-- <%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>FleetFlow Login</title>
</head>
<body>
<h1>FleetFlow System</h1>
<form action="login" method="post">
    Username: <input type="text" name="username" /><br/><br/>
    Password: <input type="password" name="password" /><br/><br/>
    <button type="submit">Login</button>
</form>

<c:if test="${not empty error}">
    <p style="color:red">${error}</p>
</c:if>
</body>
</html> -->