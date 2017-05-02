<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Shopping_cart</title>
</head>
<body>
<h1>Shopping Cart</h1>

<%-- Check session user --%>
<%
	String user = (String) session.getAttribute("user");
	if (user == null) {
		response.sendRedirect("Failure.jsp?failure="+"NotLogin");
	} else {
}
%>
Welcome <%=user %> <p>

<%-- Import the java.sql package --%>
<%@ page import="java.sql.*, java.io.PrintWriter"%>

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
<table>
	<tr>
		<td>
            <%-- Update code --%>
            <%
                if (action != null && action.equals("update")) {
                    // Begin transaction
                    conn.setAutoCommit(false);

                    // Create prepared statement and use for update
                    pstmt = conn.prepareStatement("UPDATE Contains SET quantity = ? WEHERE product_id = ?");
                    pstmt.setString(1, Integer.parseInt(request.getParameter("quantity")));
                    pstmt.setString(2, Integer.parseInt(request.getParameter("product_id"));
                    int rowCount = pstmt.executeUpdate();

                    // Commit
                    conn.commit();
                    conn.setAutoCommit(true);
                }
            %>
		</td>
	</tr>
	<tr>
		<th>ID</th>
		<th>Name</th>
		<th>SKU</th>
		<th>Price</th>
		<th>Quantity</th>
	</tr>
</table>
<%-- Close connection code --%>
<%
 
            rs.close();
            conn.close();
            
        } catch (SQLException e) {
            // Wrap the SQL exception in a runtime exception to propagate
            // it upwards
            //throw new RuntimeException(e);  
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
%>
<%
	}
%>
</body>
</html>