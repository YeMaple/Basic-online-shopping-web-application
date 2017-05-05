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
	
    session.setAttribute("current_page", "product_browsing" );
    if (user == null || role == null) {
    	response.sendRedirect("Failure.jsp?failure="+"NotLogin");
    } else {
%>

<%-- Import the java.sql package --%>
<%@ page import="java.sql.*"%>
<%-- Open connection code --%>
<%
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;

	try {
	    // Registering Postgresql JDBC driver with the DriverManager
	    Class.forName("org.postgresql.Driver");
	
	    // Open a connection to the database using DriverManager
	    conn = DriverManager.getConnection(
	        	"jdbc:postgresql://localhost/shopping_db?" +
	        	"user=postgres&password=postgres");
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
	
		// Commit 
		conn.commit();
		conn.setAutoCommit(true);
	}
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
<form action="Home.jsp">
    <button>Home</button>
</form>
</body>
</html>