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
    int count = (int)session.getAttribute("cart_count");
	
    session.setAttribute("current_page", "product" );
    if (user == null || role == null) {
    	response.sendRedirect("Failure.jsp?failure="+"NotLogin");
    } else if(role != null && role.equals("customer")) {
    	//session.setAttribute("failure", "Access");
        response.sendRedirect("Failure.jsp?failure="+"Access");
    } else{
%>
<div>
	<div style = "position:absolute;top:0;left:0;" >
		Welcome <%=user %>
	</div>
<%
	if(count != 0){
%>
	<div style = "position:absolute;left:20%" >
		<form action="Buy_Shopping_Cart.jsp", method="POST">
			<input type = "hidden" name = "user" value = <%=user %>/>
			<input type = "hidden" name = "role" value = <%=role %>/>
			<button>Checkout</button>
		</form>
	</div>
<%
	}
%>
</div>
<h1>Products</h1>
<table>
	<tr>
		<td>
		<jsp:include page="/Categories_Link.jsp"/>
		</td>
		<td>
		<jsp:include page="/List_Product_IDUS.jsp"/>
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