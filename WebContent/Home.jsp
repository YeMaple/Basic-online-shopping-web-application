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
		ResultSet num = null;


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
			// Check if cart has product
			pstmt = conn.prepareStatement("SELECT COUNT(c.product_id) AS cnt FROM contains c WHERE c.cart_id =?");
			pstmt.setInt(1, Integer.parseInt(rs.getString(2)));
			num = pstmt.executeQuery();
			int count = 0;
			if (num.next()){
				count = num.getInt("cnt");
			}
			session.setAttribute("cart_count", count);
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
			<input type = "hidden" name = "role" value = <%=rs.getString("role") %>/>
			<button>Checkout</button>
		</form>
	</div>
<%
	}
%>
</div>
<div>
	<div>
	<h1>Page Index</h1>
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