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
	String user = (String) session.getAttribute("user");
	String role = (String) session.getAttribute("role");
	//System.out.println("get user!!!!!!!!!!!");
	if(user == null){
		//System.out.println("Redirect!!!!!!!!!!!");
		response.sendRedirect("Login.jsp");
	}else{
		session.setAttribute("user", user);
%>

<%-- Import the java.sql package --%>
<%@ page import="java.sql.*, java.util.*"%>

<%-- Open connection code --%>
<%
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs1 = null;
		//System.out.println("Open connection!!!!!!!!!!!");

		try {
	    	// Registering Postgresql JDBC driver with the DriverManager
	    	Class.forName("org.postgresql.Driver");
	
	    	// Open a connection to the database using DriverManager
	    	conn = DriverManager.getConnection(
	        	"jdbc:postgresql://localhost/shopping_db?" +
	        	"user=postgres&password=KaVaLa0096");
%>

<%-- Get categories list code --%>
<%
	// Create the statement
	Statement statement = conn.createStatement();
	ArrayList category_List = new ArrayList();
	// Use the created statement to SELECT
	// the student attributes FROM the Student table.
	rs1 = statement.executeQuery("SELECT name FROM category");
%>

Hello! <%=user %>
<div>
	<div>
		<form action="List_product.jsp">
			<input type="hidden" name="action" value="search">
			<select name="category_id">
				<option value="all"> all</option>
				<%
					while(rs1.next()){
						String C_name = rs1.getString("name");
				%>
			    <option value="<%=C_name %>">
			        <%=C_name %>
			    </option>
			    <%
					}
			    %>
			</select>
			
			<input type="text" name="P_name" placeholder="Search product name here" value="">
			<input type="submit" value="Search">
		</form>
	</div>
</div>

<%
		//Close the ResultSet
		rs1.close();
	
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
		if (rs1 != null) {
			try {
				rs1.close();
			} catch (SQLException e) { } // Ignore
				rs1 = null;
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