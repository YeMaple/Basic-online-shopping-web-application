<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Products</title>
</head>
<body>
<%
    String user = (String)session.getAttribute("user");
    String role = (String)session.getAttribute("role");
    //System.out.println(role);
    //System.out.println(user);
    if (user == null || role == null) {
    	response.sendRedirect("Failure.jsp?failure="+"NotLogin");
    } else if (role != null && role.equals("customer")) {
        //session.setAttribute("failure", "Access");
        response.sendRedirect("Failure.jsp?failure="+"Access");
    } else {
%>

<h1>Products</h1>
Welcome <%=user %><p>
<table>
	<tr>
		<td>
		<jsp:include page="/Categories_Link.jsp"/>
		</td>
		<td>
		<jsp:include page="/List_product.jsp"/>
	</tr>
</table>
<%
    }
%>
</body>
</html>