<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Checkout</title>
</head>
<body>
<%
    String user = (String)session.getAttribute("user");
    String role = (String)session.getAttribute("role");
	
    if (user == null || role == null) {
    	response.sendRedirect("Failure.jsp?failure="+"NotLogin");
    } else {
%>

<h1>Checkout</h1>
Welcome <%=user %><p>
<table>
	<tr>
		<td>
		<jsp:include page="/Shopping_Summary.jsp"/>
		</td>
	</tr>
</table>
<%
    }
%>
</body>
</html>