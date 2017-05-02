<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Login</title>
</head>
<body>
<%
String sessionUser = (String) session.getAttribute("user");
if (sessionUser != null) {
	response.sendRedirect("Home.jsp?user="+sessionUser);
} else {
%>
Please login with your user information<p>
<form method="POST" action="Home.jsp">
	Your name:<input type="text" size="20" name="user"/><p>
    <input type="submit" value="Login"/>
</form>
<form action="SignUp.jsp">
    <input type="submit" value="Signup"/>
</form>
</body>
<%
}
%>
</html>