<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transport Manager - Login | FleetFlow</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* ===== NAVIGATION BAR ===== */
        .navbar {
            background-color: rgba(0, 0, 0, 0.8);
            padding: 15px 30px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
        }

        .navbar-content {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .navbar-brand {
            color: #fff;
            font-size: 24px;
            font-weight: bold;
            text-decoration: none;
        }

        .navbar-brand:hover {
            color: #667eea;
        }

        .back-link {
            color: #fff;
            text-decoration: none;
            padding: 8px 16px;
            border-radius: 4px;
            transition: background 0.3s ease;
        }

        .back-link:hover {
            background-color: rgba(255, 255, 255, 0.1);
        }

        /*MAIN CONTAINER*/
        .container {
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        /* ===== LOGIN CARD ===== */
        .login-card {
            background: white;
            border-radius: 8px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            padding: 40px;
            width: 100%;
            max-width: 400px;
        }

        .login-card h1 {
            text-align: center;
            color: #333;
            margin-bottom: 10px;
            font-size: 28px;
        }

        .login-card p {
            text-align: center;
            color: #666;
            margin-bottom: 30px;
            font-size: 14px;
        }

        .error-box {
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            border-radius: 4px;
            color: #721c24;
            padding: 12px 15px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        .error-box::before {
            content: "⚠ ";
            font-weight: bold;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 500;
            font-size: 14px;
        }

        .form-group input {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }

        .form-group input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .form-group input::placeholder {
            color: #aaa;
        }

        .btn-submit {
            width: 100%;
            padding: 12px;
            background-color: #667eea;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.3s ease, transform 0.1s ease;
        }

        .btn-submit:hover {
            background-color: #5568d3;
        }

        .btn-submit:active {
            transform: scale(0.98);
        }

        .btn-submit:disabled {
            background-color: #ccc;
            cursor: not-allowed;
            transform: none;
        }

        .demo-info {
            background-color: #e7f3ff;
            border-left: 4px solid #2196F3;
            padding: 12px 15px;
            margin-top: 20px;
            border-radius: 4px;
            font-size: 13px;
            color: #0056b3;
        }

        .demo-info strong {
            display: block;
            margin-bottom: 5px;
        }

        .demo-credentials {
            font-family: 'Courier New', monospace;
            background-color: rgba(255, 255, 255, 0.5);
            padding: 8px;
            border-radius: 3px;
            margin-top: 8px;
        }

        @media (max-width: 480px) {
            .login-card {
                padding: 30px 20px;
            }

            .login-card h1 {
                font-size: 24px;
            }

            .navbar-content {
                flex-direction: column;
                gap: 10px;
            }

            .navbar-brand {
                font-size: 18px;
            }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="navbar-content">
            <a href="${pageContext.request.contextPath}/dashboard" class="navbar-brand">FleetFlow</a>
            <a href="${pageContext.request.contextPath}/" class="back-link">← Back to Home</a>
        </div>
    </nav>

    <div class="container">
        <div class="login-card">
            <h1>Transport Manager</h1>
            <p>Login to FleetFlow Management System</p>

            <%
                String error = (String) request.getAttribute("error");
                if (error != null && !error.isEmpty()) {
            %>
                <div class="error-box">
                    <%= error %>
                </div>
            <%
                }
            %>

            <form id="loginForm" method="POST" action="${pageContext.request.contextPath}/manager/login" onsubmit="return validateForm()">
                
                <!-- Username Input -->
                <div class="form-group">
                    <label for="username">Username</label>
                    <input 
                        type="text" 
                        id="username" 
                        name="username" 
                        placeholder="Demo: manager"
                        value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>"
                        required>
                </div>

                <!-- Password Input -->
                <div class="form-group">
                    <label for="password">Password</label>
                    <input 
                        type="password" 
                        id="password" 
                        name="password" 
                        placeholder="Demo: manager123"
                        required>
                </div>

                <!-- Submit Button -->
                <button type="submit" class="btn-submit">Login</button>
            </form>

            <div class="demo-info">
                <strong>Demo Credentials:</strong>
                <div class="demo-credentials">
                    Username: <strong>manager</strong><br>
                    Password: <strong>manager123</strong>
                </div>
            </div>
        </div>
    </div>

    <!-- JAVASCRIPT VALIDATION-->
    <script>
        function validateForm() {
            const username = document.getElementById('username').value.trim();
            const password = document.getElementById('password').value.trim();

            // Check if fields are empty
            if (username === '') {
                alert('Username cannot be empty');
                document.getElementById('username').focus();
                return false;
            }

            if (password === '') {
                alert('Password cannot be empty');
                document.getElementById('password').focus();
                return false;
            }

            // Check minimum length
            if (username.length < 3) {
                alert('Username must be at least 3 characters long');
                document.getElementById('username').focus();
                return false;
            }

            if (password.length < 3) {
                alert('Password must be at least 3 characters long');
                document.getElementById('password').focus();
                return false;
            }

            return true;
        }

        // Optional: Clear error message when user starts typing
        document.getElementById('username').addEventListener('focus', function() {
            const errorBox = document.querySelector('.error-box');
            if (errorBox) {
                errorBox.style.display = 'none';
            }
        });

        document.getElementById('password').addEventListener('focus', function() {
            const errorBox = document.querySelector('.error-box');
            if (errorBox) {
                errorBox.style.display = 'none';
            }
        });
    </script>
</body>
</html>