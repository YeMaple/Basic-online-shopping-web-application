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
	String sessionUser = (String) session.getAttribute("user");
	String user = request.getParameter("user");
	//System.out.println("get user!!!!!!!!!!!");
	if(user == null && sessionUser == null){
		//System.out.println("Redirect!!!!!!!!!!!");
		response.sendRedirect("Failure.jsp?failure="+"NotLogin");
	} else {
		if (sessionUser != null) {
			user = sessionUser;
		}
%>

<%-- Import the java.sql package --%>
<%@ page import="java.sql.*, java.io.PrintWriter"%>
<%-- Open connection code --%>
<%
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		PreparedStatement cartst = null;
		ResultSet cartrs = null;
		//System.out.println("Open connection!!!!!!!!!!!");

		try {
	    	// Registering Postgresql JDBC driver with the DriverManager
	    	Class.forName("org.postgresql.Driver");
	
	    	// Open a connection to the database using DriverManager
	    	conn = DriverManager.getConnection(
	        	"jdbc:postgresql://localhost/shopping_db?" +
	        	"user=postgres&password=postgres");
%>


<%-- -------- SELECT User Info Code -------- --%>
<%
		//System.out.println("Selection!!!!!!!!!!!");
		// Create the statement
		//Statement statement = conn.createStatement();
	
		// Use the prepare statement to SELECT
		// the user attributes FROM the appuser table.
		pstmt = 
		conn.prepareStatement("SELECT u.role, c.id, u.name FROM AppUser u JOIN ShoppingCart c ON c.owner = u.id WHERE u.name = ? AND c.status = ?");
		pstmt.setString(1, user);
		pstmt.setString(2, "unpaid");
		
		rs = pstmt.executeQuery();
%>
		<%
		if(rs.next()){
			// Set session parameter
			session.setAttribute("user", rs.getString(3));
			session.setAttribute("role", rs.getString(1));
			session.setAttribute("cart", rs.getString(2));
		%>

Welcome <%=user %> <p>
<div>
	<div>
	<h2>Page Index</h2>
	</div>
	<div>

		<%
			// if the user's role is owner
			if(rs.getString("role").equals("owner")){
		%>
		<form action="Categories.jsp", method="POST">
			<input type = "hidden" name = "user" value = <%=user %>/>
			<input type = "hidden" name = "role" value = <%=rs.getString("role") %>/>
			<button>Categories</button>
		</form>
		<form action="Products.jsp", method="POST">
			<input type = "hidden" name = "user" value = <%=user %>/>
			<input type = "hidden" name = "role" value = <%=rs.getString("role") %>/>
			<button>Products</button>
		</form>
		<%
			}
		%>
		<form action="Buy_Shopping_cart.jsp", method="POST">
			<input type = "hidden" name = "user" value = <%=user %>/>
			<input type = "hidden" name = "role" value = <%=rs.getString("role") %>/>
			<button>Checkout</button>
		</form>
		<form action="Product_Browsing.jsp", method="POST">
			<input type = "hidden" name = "user" value = <%=user %>/>
			<input type = "hidden" name = "role" value = <%=rs.getString("role") %>/>
			<input type = "hidden" name = "Category_id" value = 0 />
			<button>Search Products</button>
		</form>
		<form action="Product_Order.jsp", method="POST">
			<input type = "hidden" name = "user" value = <%=user %>/>
			<input type = "hidden" name = "role" value = <%=rs.getString("role") %>/>
			<button>Shopping Cart</button>
		</form>
	</div>
</div>

<%-- -------- Close Connection Code -------- --%>
<%
		} else {
			
			response.sendRedirect("Failure.jsp?failure="+"InvalidUser&WrongName="
					+user);			
		}
		// Close the ResultSet
		rs.close();
		pstmt.close();
		// Close the Statement
		//statement.close();
	
		// Close the Connection
		conn.close();
		} catch (SQLException e) {
			// Wrap the SQL exception in a runtime exception to propagate
			// it upwards
			//throw new RuntimeException(e);
			response.sendRedirect("Failure.jsp?failure="+"InvalidUser&WrongName="
									+user);
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