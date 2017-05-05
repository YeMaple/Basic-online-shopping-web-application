<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Categories</title>
</head>
<body>
<%-- Check session user --%>
<%
    String user = (String)session.getAttribute("user");
    String role = (String)session.getAttribute("role");
    int count = (int)session.getAttribute("cart_count");
    
    session.setAttribute("current_page", "category" );
    //System.out.println(role);
    //System.out.println(user);
    if (user == null || role == null) {
    	response.sendRedirect("Failure.jsp?failure="+"NotLogin");
    } else if (role != null && role.equals("customer")) {
        //session.setAttribute("failure", "Access");
        response.sendRedirect("Failure.jsp?failure="+"Access");
    } else {
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

<h1>Categories</h1>

<%-- Import the java.sql package --%>
<%@ page import="java.sql.*, java.io.PrintWriter"%>


<%-- Open connection code --%>
<%
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        ResultSet temp = null;
        String action = request.getParameter("action");
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
            <%-- Insertion code --%>
            <%
                if (action != null && action.equals("insert")) {
                    // Begin transaction
                    conn.setAutoCommit(false);

                    // Create prepared statement and use for insertion
                    pstmt = conn.prepareStatement("INSERT INTO Category (name, description) VALUES (?, ?)");
                    pstmt.setString(1, request.getParameter("name"));
                    pstmt.setString(2, request.getParameter("description"));
                    int rowCount = pstmt.executeUpdate();

                    // Commit 
                    conn.commit();
                    conn.setAutoCommit(true);
                }
            %>

            <%-- Update code --%>
            <%
                if (action != null && action.equals("update")) {
                    // Begin transaction
                    conn.setAutoCommit(false);

                    // Create prepared statement and use for update
                    pstmt = conn.prepareStatement("UPDATE Category SET name = ?, description = ? WHERE id = ?");
                    pstmt.setString(1, request.getParameter("name"));
                    pstmt.setString(2, request.getParameter("description"));
                    pstmt.setInt(3, Integer.parseInt(request.getParameter("id")));
                    int rowCount = pstmt.executeUpdate();

                    // Commit
                    conn.commit();
                    conn.setAutoCommit(true);
                }
            %>

            <%-- Delete code --%>
            <%
                if (action != null && action.equals("delete")) {
                    // Begin transaction
                    conn.setAutoCommit(false);

                    // Create prepared statement and use for delete
                    pstmt = conn.prepareStatement("DELETE FROM Category WHERE id = ?");
                    pstmt.setInt(1, Integer.parseInt(request.getParameter("id")));
                    int rowCount = pstmt.executeUpdate();

                    // Commit
                    conn.commit();
                    conn.setAutoCommit(true);
                }
            %>

            <%-- Select code --%>
            <%
                // Create the statement
                Statement statement = conn.createStatement();

                // Use the created statement to SELECT from categories table.
                rs = statement.executeQuery("SELECT * FROM Category");

            %>
        </td>
    </tr>

<table>
    <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Description</th>
    </tr>
    <tr>
        <form action="Categories.jsp" method="POST">
            <input type="hidden" name="action" value="insert"/>
            <th>&nbsp;</th>
            <th><input value="" name="name"/></th>
            <th><input value="" name="description"/></th>
            <th><input type="submit" value="Insert"/></th>
        </form>
    </tr>
    <%-- Iteration code --%>
    <%
        while (rs.next()) {
    %>
    <tr>
        <form action="Categories.jsp" method="POST">
            <input type="hidden" name="action" value="update"/>
            <input type="hidden" name="id" value="<%=rs.getInt("id")%>"/>
            <%-- Get the id --%>
            <td>
                 <%=rs.getInt("id")%>
            </td>
            <%-- Get the name --%>
            <td>
                <input value="<%=rs.getString("name")%>" name="name"/>
            </td>
             <%-- Get the description --%>
            <td>
                <input value="<%=rs.getString("description")%>" name="description"/>
            </td>    
            <td><input type="submit" value="Update"></td>
        </form>   
        <%
        	pstmt = conn.prepareStatement("SELECT COUNT(p) as cnt FROM Product p WHERE p.category_id = ?");
        	pstmt.setInt(1, rs.getInt("id"));
        	temp = pstmt.executeQuery();
        	if (temp.next()) {
        		if (temp.getInt("cnt") == 0) {
        %>
        <form action="Categories.jsp" method="POST">
            <input type="hidden" name="action" value="delete"/>
            <input type="hidden" value="<%=rs.getInt("id")%>" name="id"/>
            <%-- Button --%>
            <td><input type="submit" value="Delete"/></td>
        </form>
        <%  
        		}
        	}
        %>   
    </tr>
    <%
        }
    %>
</table>
</table>
<%-- Close connection code --%>
<%
 
            //rs.close();
            //temp.close();
            conn.close();
            
            if (action != null && action.equals("insert")) {
            	response.sendRedirect("Success.jsp?success="+"InsertCategory");
            } else if (action != null && action.equals("update")) {
            	response.sendRedirect("Success.jsp?success="+"UpdateCategory");
            } else if (action != null && action.equals("delete")) {
            	response.sendRedirect("Success.jsp?success="+"DeleteCategory");
            }
    
        } catch (SQLException e) {
            // Wrap the SQL exception in a runtime exception to propagate
            // it upwards
            //throw new RuntimeException(e);  
            if (action != null && action.equals("insert")) {
                //ession.setAttribute("failure", "InsertCategory");
                response.sendRedirect("Failure.jsp?failure="+"InsertCategory");
            } else if (action != null && action.equals("update")) {
                //session.setAttribute("failure", "UpdateCategory");
                response.sendRedirect("Failure.jsp?failure"+"UpdateCategory");
            } else if (action != null && action.equals("delete")) {
                //session.setAttribute("failure", "DeleteCategory");
                response.sendRedirect("Failure.jsp?failure="+"DeleteCategory");
            }
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