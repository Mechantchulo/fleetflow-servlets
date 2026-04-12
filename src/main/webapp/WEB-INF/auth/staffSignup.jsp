<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ATMS Staff Signup</title>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login-style.css">
</head>
<body>
<div class="bg-overlay"></div>
<header class="topbar">
    <div class="brand-pill"><i class="fas fa-bus"></i><span>ATMS</span></div>
</header>
<main class="landing-wrap">
    <section class="landing-card" style="max-width:980px;">
        <div class="hero-pane">
            <span class="hero-tag"><i class="fas fa-user-plus"></i> Staff Account Setup</span>
            <h1>Create a staff account linked to your department.</h1>
            <p>Your profile will be used as source identity for all future trip requests and reports.</p>
            <div class="hero-actions">
                <a class="btn-primary" href="${pageContext.request.contextPath}/login">Back to Login</a>
            </div>
        </div>

        <div class="login-pane">
            <h2>Staff Signup</h2>
            <p class="role-hint">Role: STAFF</p>

            <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= request.getAttribute("error") %></div>
            <% } %>

            <form action="${pageContext.request.contextPath}/signup/staff" method="post" class="login-form">
                <div class="form-group">
                    <label for="fullName">Full Name</label>
                    <input type="text" id="fullName" name="fullName" value="${fullName}" required>
                </div>
                <div class="form-group">
                    <label for="department">Department</label>
                    <input type="text" id="department" name="department" value="${department}" required>
                </div>
                <div class="form-group">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email" value="${email}" required>
                </div>
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" value="${username}" required>
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" minlength="8" required>
                </div>
                <div class="form-group">
                    <label for="confirmPassword">Confirm Password</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" minlength="8" required>
                </div>
                <button type="submit" class="btn-submit">Create Staff Account</button>
            </form>
        </div>
    </section>
</main>
</body>
</html>
