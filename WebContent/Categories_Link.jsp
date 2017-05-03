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

<b>Categories List</b>
<%-- Open connection code --%>
<%
	String P_name = request.getParameter("P_name");
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

<%-- Select categories code --%>
<%
    Statement statement = conn.createStatement();
    rs = statement.executeQuery("SELECT * FROM Category");
%>
<ul>
    <li>
    	<%
    		if (P_name != null) {
    	%>
    	<a href="Product_Browsing.jsp?action=search&Category_id=0&P_name=<%=P_name%>">
    		All
    	</a>
    	<%
    		} else {
    	%>
  		<a href="Product_Browsing.jsp?action=search&Category_id=0"> 
  			All
  		</a>		 	
    	<%
    		}
    	%>
    </li>
    <%-- Iteration code --%>
    <%
        while (rs.next()) {
    %>
    <li>
    	<%
    		if (P_name != null) {
    	%>
        <a href="Product_Browsing.jsp?action=search&Category_id=<%=rs.getInt("id")%>&P_name=<%=P_name%>">
        	<%=rs.getString("name")%>
        </a>
        <%
    		} else {
        %>
        <a href="Product_Browsing.jsp?action=search&Category_id=<%=rs.getInt("id")%>">
        	<%=rs.getString("name")%>
        </a>
        <%
    		}
        %>
    </li>
    <%
        }
    %>
</ul>

<%-- Close connection code --%>
<%
        rs.close();
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