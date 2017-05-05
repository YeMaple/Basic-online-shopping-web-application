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
    int count = (int)session.getAttribute("cart_count");
	
    session.setAttribute("current_page", "product_browsing" );
    if (user == null || role == null) {
    	response.sendRedirect("Failure.jsp?failure="+"NotLogin");
    } else {
%>

<%-- Import the java.sql package --%>
<%@ page import="java.sql.*, javax.sql.*, javax.naming.*"%>
<%-- Open connection code --%>
<%
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	ResultSet cartId = null;

	try {
		/*
	    // Registering Postgresql JDBC driver with the DriverManager
	    Class.forName("org.postgresql.Driver");
	
	    // Open a connection to the database using DriverManager
	    conn = DriverManager.getConnection(
	        	"jdbc:postgresql://localhost/shopping_db?" +
	        	"user=postgres&password=postgres");
	    */
		// Obtain the environment naming context
        Context initCtx = new InitialContext();
        // Look up the data source
        DataSource ds = (DataSource) initCtx.lookup("java:comp/env/jdbc/ShoppingDBPool");
        // Allocate and use a connection from the pool
        conn = ds.getConnection();
%>

<%-- Insertion code --%>
<%
	String action = request.getParameter("action");
	if (action != null && action.equals("new_cart")) {
		// Begin transaction
		conn.setAutoCommit(false);
		
		// Get user id
		pstmt = conn.prepareStatement("SELECT id FROM appuser WHERE name = ?");
			
		pstmt.setString(1, user);
		rs = pstmt.executeQuery();

		int AppUserID = 0;
		if (rs.next()) {
			AppUserID = rs.getInt(1);
		}
		
		// Create prepared statement and use for insertion
		pstmt = conn.prepareStatement("INSERT INTO shoppingcart (status, owner) VALUES (?, ?)");
		pstmt.setString(1, "unpaid");
		pstmt.setInt(2, AppUserID);
	    pstmt.executeUpdate();
	    
	    // Get the new cart id
	    pstmt = conn.prepareStatement("SELECT id FROM shoppingcart WHERE status = ? AND owner = ?");
		pstmt.setString(1, "unpaid");
		pstmt.setInt(2, AppUserID);
	    cartId = pstmt.executeQuery();
	    
	    if(cartId.next()){
	    	session.setAttribute("cart", cartId.getString(1));
	    }
	    
	    session.setAttribute("cart_count", 0);
	
		// Commit 
		conn.commit();
		conn.setAutoCommit(true);
	}
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
<h1>Product Browsing</h1>
<table>
	<tr>
		<td>
		<jsp:include page="/Categories_Link.jsp"/>
		</td>
		<td>
		<jsp:include page="/List_Product.jsp"/>
		</td>
	</tr>
</table>
<%-- -------- Close Connection Code -------- --%>
<%
		// Close the ResultSet
		//rs.close();
	
		// Close the Connection
		conn.close();
		} catch (SQLException e) {
			// Wrap the SQL exception in a runtime exception to propagate
			// it upwards
			//throw new RuntimeException(e);
			response.sendRedirect("Failure.jsp?failure="+"Other");
		} catch (Exception e) {
			response.sendRedirect("Failure.jsp?failure="+"Other");
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
<%
	if(role.equals("owner")){
%>
<form action="Home.jsp">
    <button>Home</button>
</form>
<%
	}
%>
</body>
</html>