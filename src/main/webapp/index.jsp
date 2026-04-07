<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
</html>