<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<body>
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

<%-- -------- SELECT product info Code -------- --%>
<%
		String action = request.getParameter("action");
		// Check if an insertion is requested
		if (action != null && action.equals("search")) {
			// get the input
			String P_name = request.getParameter("P_name");
			String C_id = request.getParameter("Category_id");
			// set possible sql string
			String sql_request = "SELECT * FROM product p";
			String sql_condition = " WHERE ";
			String sql_p_name = "p.name like '%";
			String sql_and = " AND ";
			String sql_c_id = "p.category_id = ";
			
			// check conditions
			// if we have both name and category constraint
			if(P_name != null && C_id != null){
				sql_request = sql_request + sql_condition + sql_p_name + 
						P_name + "%'" + sql_and + sql_c_id + C_id;
				
			}
			// if we have category constraint
			else if(P_name != null){
				sql_request = sql_request + sql_condition + sql_p_name + P_name + "%'";
			}else if(C_id != null){
				sql_request = sql_request + sql_condition + sql_c_id + C_id;
			}
			
		 	// Use the prepare statement to SELECT
			// the product match the given attributes FROM the product table.
			pstmt = conn.prepareStatement(sql_request);
		    
		    rs = pstmt.executeQuery();
		}
		
%>

<%-- -------- Close Connection Code -------- --%>
<%
		// Close the ResultSet
		rs.close();
	
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
%>
</body>
</html>