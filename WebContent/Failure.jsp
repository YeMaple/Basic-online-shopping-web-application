<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Failure</title>
</head>
<body>
    <%
        String type = request.getParameter("failure");
        if (type != null && type.equals("SignUp")) {
    %>
        SignUp Failure<p>
        <a href="SignUp.jsp">Please try again</a>
    <%
        } else if (type != null && type.equals("NotLogin")) {
    %>
        No User Login<p> 
        <a href="Login.jsp">Please login </a>   
    <%
        } else if (type != null && type.equals("Access")) {
    %>
    	This page is available to owners only<p>
        <a href="Home.jsp">Return to homepage</a>
    <%
        } else if (type != null && type.equals("InsertCategory")) {
    %>
        Insert Category Failure<p>
        <a href="Category.jsp">Please try again</a>
    <%
        } else if (type != null && type.equals("UpdateCategory")) {
    %>
        Update Category Failure<p>
        <a href="Category.jsp">Please try again</a>
    <%
        } else if (type != null && type.equals("DeleteCategory")) {
    %> 
        Delete Category Failure<p>
        <a href="Category.jsp">Please try again</a>
    <%
        }
    %>
</body>
</html>