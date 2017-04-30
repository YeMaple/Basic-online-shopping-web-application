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
	String user = request.getParameter("user");
	if(user == null){
		response.sendRedirect("Login.jsp");
	}
	session.setAttribute("user", user);
%>

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
        	"user=postgres&password=KaVaLa0096");
%>

<%-- -------- SELECT User Info Code -------- --%>
<%
	// Create the statement
	Statement statement = conn.createStatement();

	// Use the prepare statement to SELECT
	// the user attributes FROM the appuser table.
	pstmt = conn.prepareStatement("SELECT * FROM appuser u WHERE u.name = ?");
	pstmt.setString(1, user);
	
	ResultSet rs = pstmt.executeQuery();
%>

Welcome <% = user %> <p>
<div>
	<div>
	<h2>Page Index</h2>
	</div>
	<div>
		<%
			// if the user's role is owner
			if(rs.getString("role").equals("owner")){
		%>
		<button onclick="window.open('Categories.jsp')">Categories</button>
		<% 
			}
		%>
		<button onclick="window.open('Categories.jsp')">Categories</button>
		
	</div>
</div>
</body>
</html>