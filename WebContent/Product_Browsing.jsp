<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Product_Browser</title>
</head>
<body>
<%
    String user = (String)session.getAttribute("user");
    String role = (String)session.getAttribute("role");
    //System.out.println(role);
    //System.out.println(user);
    if (user == null || role == null) {
    	response.sendRedirect("Failure.jsp?failure="+"NotLogin");
    } else {
%>

<h1>Product Browsing</h1>
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
<form action="Home.jsp">
    <button>Home</button>
</form>
</body>
</html>