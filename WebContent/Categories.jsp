<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Categories</title>
</head>
<body>
<h1>Categories</h1>
<%-- Check session user --%>
<%
    String user = (String)session.getAttribute("user");
    String role = (String)session.getAttribute("role");
    //System.out.println(role);
    //System.out.println(user);
    if (user == null || role == null) {
        response.sendRedirect("Login.jsp");
    } else if (role != null && role.equals("customer")) {
        session.setAttribute("failure", "Access");
        response.sendRedirect("Failure.jsp");
    } else {
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
            <%-- Insertion code --%>
            <%
                String action = request.getParameter("action");
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
                    pstmt = conn.prepareStatement("UPDATE Category SET name = ?, description = ?");
                    pstmt.setString(1, request.getParameter("name"));
                    pstmt.setString(2, request.getParameter("description"));
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
</table>
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
        <form action="Categories.jsp" method="POST">
            <input type="hidden" name="action" value="delete"/>
            <input type="hidden" value="<%=rs.getInt("id")%>" name="id"/>
            <%-- Button --%>
            <td><input type="submit" value="Delete"/></td>
        </form>    
    </tr>
</table>
<%-- Close connection code --%>
<%
        }
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
    }
%>
<form action="Home.jsp">
    <button>Home</button>
</form>
</body>
</html>