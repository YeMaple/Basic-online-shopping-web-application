<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Signup</title>
</head>
<body>
<h1>Signup Page</h1>
<%-- Import the java.sql package --%>
<%@ page import="java.sql.*, javax.sql.*, javax.naming.*"%>
<%-- Open connection code --%>
<%
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;

	try {
       
		// Obtain the environment naming context
        Context initCtx = new InitialContext();
        // Look up the data source
        DataSource ds = (DataSource) initCtx.lookup("java:comp/env/jdbc/ShoppingDBPool");
        // Allocate and use a connection from the pool
        conn = ds.getConnection();
   
        /*
        // Registering Postgresql JDBC driver with the DriverManager
        Class.forName("org.postgresql.Driver");

        // Open a connection to the database using DriverManager
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost/shopping_db?" +
            "user=postgres&password=postgres");
       	*/
%> 

<%-- Insertion Code --%>
<%
	String action = request.getParameter("action");
	// Check if an insertion is requested
	if (action != null && action.equals("insert")) {
	
	    // Begin transaction
	    conn.setAutoCommit(false);
	
	    // Create the prepared statement and use it to
	    // INSERT user values INTO the appuser table.
	    pstmt = conn
	    .prepareStatement("INSERT INTO Appuser (name, role, age, state) VALUES (?, ?, ?, ?)"
	    					,Statement.RETURN_GENERATED_KEYS);
	
	    pstmt.setString(1, request.getParameter("usr_name"));
	    pstmt.setString(2, request.getParameter("role"));
	    pstmt.setInt(3, Integer.parseInt(request.getParameter("age")));
	    pstmt.setString(4, request.getParameter("state"));
	    pstmt.executeUpdate();
	    rs = pstmt.getGeneratedKeys();

	   	int AppUserID = 0;
	   	while (rs.next()) {
	   		AppUserID = rs.getInt(1);
	   	}
	    
	    pstmt = conn
	    .prepareStatement("INSERT INTO ShoppingCart (status, owner) VALUES (?, ?)");
	    pstmt.setString(1, "unpaid");
	    pstmt.setInt(2, AppUserID);
	    pstmt.executeUpdate();
	    // Commit transaction
	    conn.commit();
	    conn.setAutoCommit(true);
	}
%>

<%-- Insert content --%>
<form action="SignUp.jsp", method="POST">
<input type="hidden" name="action" value="insert"/>
User name:<br>
<input type="text" name="usr_name" value="" required>
<br>
Role:<br>
<select name="role">
  <option value="owner">Owner</option>
  <option value="customer">Customer</option>
</select>
<br>
Age:<br>
<input type="number" name="age" min="1" max="150" required>
<br>
State:<br>
<select name="state">
  <option value="ca">CA</option>
  <option value="nv">NV</option>
  <option value="oh">OH</option>
  <option value="al">AL</option>
  <option value="ak">AK</option>
  <option value="az">AZ</option>
  <option value="ar">AR</option>
  <option value="co">CO</option>
  <option value="ct">CT</option>
  <option value="de">DE</option>
  <option value="dc">DC</option>
  <option value="fl">FL</option>
  <option value="ga">GA</option>
  <option value="hi">HI</option>
  <option value="id">ID</option>
  <option value="il">IL</option>
  <option value="in">IN</option>
  <option value="ia">IA</option>
  <option value="ks">KS</option>
  <option value="ky">KY</option>
  <option value="la">LA</option>
  <option value="me">ME</option>
  <option value="md">MD</option>
  <option value="ma">MA</option>
  <option value="mi">MI</option>
  <option value="mn">MN</option>
  <option value="ms">MS</option>
  <option value="mo">MO</option>
  <option value="mt">MT</option>
  <option value="ne">NE</option>
  <option value="nh">MH</option>
  <option value="nm">NM</option>
  <option value="nv">NC</option>
  <option value="nd">ND</option>
  <option value="ok">OK</option>
  <option value="or">OR</option>
  <option value="pa">PA</option>
  <option value="ri">RI</option>
  <option value="sc">SC</option>
  <option value="sd">SD</option>
  <option value="tn">TN</option>
  <option value="tx">TX</option>
  <option value="ut">UT</option>
  <option value="vt">VT</option>
  <option value="va">VA</option>
  <option value="wa">WA</option>
  <option value="wi">WI</option>
  <option value="WY">WY</option>
</select>
<br><br>
<input type="submit" value="Signup">
</form>

<%-- Close connection --%>
<%
	
	// Close the Connection
	conn.close();
	if (action != null && action.equals("insert")) {
		response.sendRedirect("Success.jsp?success="+"SignUp");
	}
	} catch (SQLException e) {
	// Wrap the SQL exception in a runtime exception to propagate it upwards
	//session.setAttribute("failure", "SignUp");
	response.sendRedirect("Failure.jsp?failure="+"SignUp");
	//throw new RuntimeException(e);
	} catch (Exception e) {
		response.sendRedirect("Failure.jsp?failure="+"Other");
	}

%>

</body>
</html>