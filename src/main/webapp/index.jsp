<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ATMS - Transport Platform</title>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login-style.css">
</head>
<body>
    <div class="bg-overlay"></div>

    <header class="topbar">
        <div class="brand-pill">
            <i class="fas fa-bus"></i>
            <span>ATMS</span>
        </div>
    </header>

    <main class="landing-wrap">
        <section class="landing-card">
            <div class="hero-pane">
                <span class="hero-tag"><i class="far fa-calendar-check"></i> ATMS Transport Platform</span>
                <h1>Move faster with a transport system built for real operations.</h1>
                <p>Centralize timetables, confirmations, approvals, dispatch, and reporting in one secure workflow.</p>
                <div class="hero-actions">
                    <a class="btn-primary" href="#signin">Sign In <i class="fas fa-arrow-right"></i></a>
                </div>
            </div>

            <div class="login-pane" id="signin">
                <h2>Login</h2>
                <p class="role-hint">Role: preassigned staff account</p>

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
                <% if ("staffSuccess".equals(request.getParameter("signup"))) { %>
                    <div class="alert alert-success">
                        <i class="fas fa-check-circle"></i> Staff account created successfully. You can now sign in.
                    </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/login" method="POST" class="login-form">
                    <div class="form-group">
                        <label for="username">Username</label>
                        <input type="text" id="username" name="username" placeholder="e.g. manager" required autofocus>
                    </div>

                    <div class="form-group">
                        <label for="password">Password</label>
                        <div class="password-wrap">
                            <input type="password" id="password" name="password" placeholder="Enter password" required>
                            <button type="button" class="password-toggle" id="passwordToggle" aria-label="Show password">
                                <i class="fas fa-eye" id="passwordToggleIcon"></i>
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="btn-submit">Sign In</button>
                </form>

                <div class="signup-cta">
                    <a class="btn-signup" href="${pageContext.request.contextPath}/signup/staff">
                        <i class="fas fa-user-plus"></i> Create Staff Account
                    </a>
                </div>

                <div class="access-box">
                    <p><strong>Preassigned Access</strong></p>
                    <div class="access-grid">
                        <span><strong>Manager:</strong> manager / Manager@2026</span>
                        <span><strong>Staff:</strong> staff / Staff@2026</span>
                        <span><strong>Driver:</strong> driver / Driver@2026</span>
                        <span><strong>Dean:</strong> dean / Dean@2026</span>
                        <span><strong>Timetabling:</strong> timetabling / Timetable@2026</span>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <script>
        (function () {
            const passwordInput = document.getElementById('password');
            const toggleButton = document.getElementById('passwordToggle');
            const icon = document.getElementById('passwordToggleIcon');
            if (!passwordInput || !toggleButton || !icon) {
                return;
            }
            toggleButton.addEventListener('click', function () {
                const visible = passwordInput.type === 'text';
                passwordInput.type = visible ? 'password' : 'text';
                icon.className = visible ? 'fas fa-eye' : 'fas fa-eye-slash';
                toggleButton.setAttribute('aria-label', visible ? 'Show password' : 'Hide password');
            });
        })();
    </script>
</body>
</html>
