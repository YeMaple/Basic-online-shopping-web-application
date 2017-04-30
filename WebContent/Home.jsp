<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Home Page</title>
</head>
<body>
<% 
	String user = request.getParameter("user");
	//System.out.println("get user!!!!!!!!!!!");
	if(user == null){
		//System.out.println("Redirect!!!!!!!!!!!");
		response.sendRedirect("Login.jsp");
	}else{
		session.setAttribute("user", user);
%>

<%-- Import the java.sql package --%>
<%@ page import="java.sql.*, java.io.PrintWriter"%>
<%-- Open connection code --%>
<%
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		//System.out.println("Open connection!!!!!!!!!!!");

		try {
	    	// Registering Postgresql JDBC driver with the DriverManager
	    	Class.forName("org.postgresql.Driver");
	
	    	// Open a connection to the database using DriverManager
	    	conn = DriverManager.getConnection(
	        	"jdbc:postgresql://localhost/shopping_db?" +
	        	"user=postgres&password=KaVaLa0096");
%>

<%-- -------- SELECT User Info Code -------- --%>
<%
		//System.out.println("Selection!!!!!!!!!!!");
		// Create the statement
		Statement statement = conn.createStatement();
	
		// Use the prepare statement to SELECT
		// the user attributes FROM the appuser table.
		pstmt = conn.prepareStatement("SELECT * FROM appuser u WHERE u.name = ?");
		pstmt.setString(1, user);
		
		rs = pstmt.executeQuery();
%>

Welcome <%=user %> <p>
<div>
	<div>
	<h2>Page Index</h2>
	</div>
	<div>
		<%
		if(rs.next()){
			// if the user's role is owner
			if(rs.getString("role").equals("owner")){
		%>
		<button onclick="window.open('Categories.jsp')">Categories</button>
		<button onclick="window.open('Products.jsp')">Products</button>
		<%
			}else{
		%>
		<button onclick="window.open('Buy_Shopping_cart.jsp')">Checkout</button>
		<%} %>
		<button onclick="window.open('Product_Browsing.jsp')">Search Products</button>
		<button onclick="window.open('Product_Order.jsp')">Shopping Cart</button>
	</div>
</div>

<%-- -------- Close Connection Code -------- --%>
<%
		}
		// Close the ResultSet
		rs.close();
		// Close the Statement
		statement.close();
	
		// Close the Connection
		conn.close();
		} catch (SQLException e) {
			// Wrap the SQL exception in a runtime exception to propagate
			// it upwards
			throw new RuntimeException(e);
		}
		finally {
		// Release resources in a finally block in reverse-order of
		// their creation
		if (rs != null) {
			try {
				rs.close();
			} catch (SQLException e) { } // Ignore
				rs = null;
		}
		if (pstmt != null) {
			try {
				pstmt.close();
			} catch (SQLException e) { } // Ignore
			pstmt = null;
		}
		if (conn != null) {
			try {
				conn.close();
			} catch (SQLException e) { } // Ignore
				conn = null;
			}
		}
	}
%>
</body>
</html>