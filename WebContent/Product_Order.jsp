<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Shopping_cart</title>
</head>
<body>

<%-- Check session user --%>
<%
	String user = (String) session.getAttribute("user");
	String role = (String)session.getAttribute("role");
	int count = (int) session.getAttribute("cart_count");
	//System.out.println("!!!!!!!!!!!!!!!!");
	int cart_id = Integer.parseInt((String) session.getAttribute("cart"));
	if (user == null) {
		response.sendRedirect("Failure.jsp?failure="+"NotLogin");
	} else {
		String action = request.getParameter("action");
%>
Welcome <%=user %> <p>
<h1>Shopping Cart</h1>
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
<%-- Insert into cart Code --%>
<%
	// Check if an insertion is requested
	if (action != null && action.equals("add")) {
	
	    // Begin transaction
	    conn.setAutoCommit(false);

	    pstmt = conn.prepareStatement("SELECT * FROM contains c WHERE c.product_id =? AND c.cart_id=?");
	    pstmt.setInt(1,Integer.parseInt(request.getParameter("id")));
	    pstmt.setInt(2, cart_id);
	    ResultSet tmp = pstmt.executeQuery();
	    if (tmp.next()) {
	    	response.sendRedirect("Failure.jsp?failure=" + "RepeatItem");
	    	conn.setAutoCommit(true);
	    } else {
	    pstmt = conn
	    .prepareStatement("INSERT INTO contains (added_price, quantity, product_id, cart_id) VALUES (?, 1, ?, ?)");
	    pstmt.setDouble(1, Double.parseDouble(request.getParameter("price")));
	    pstmt.setInt(2, Integer.parseInt(request.getParameter("id")));
	    pstmt.setInt(3, cart_id);
	    pstmt.executeUpdate();
	    
	 	// Update shopping cart count
	 	count++;
	 	session.setAttribute("cart_count", count);
	    // Commit transaction
	    conn.commit();
	    conn.setAutoCommit(true);
	    }

	}
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
                    pstmt = conn.prepareStatement("UPDATE Contains SET quantity = ? WHERE product_id = ?");
                    pstmt.setInt(1, Integer.parseInt(request.getParameter("quantity")));
                    pstmt.setInt(2, Integer.parseInt(request.getParameter("product_id")));
                    int rowCount = pstmt.executeUpdate();

                    // Commit
                    conn.commit();
                    conn.setAutoCommit(true);
                }
            %>
            <%-- Select code --%>
            <%
            	// Delete the none existed products from the cart
            	pstmt = conn.prepareStatement("DELETE FROM contains c USING product p WHERE c.product_id = p.id AND p.status = 'deleted' ");
            	pstmt.executeUpdate();
            	// Load the products in the cart
            	pstmt = 
            	conn.prepareStatement(
            	"SELECT p.id, p.name, p.sku, c.added_price, c.quantity " +
            	"FROM Product p, Contains c " +
            	"WHERE c.cart_id = ? AND c.product_id = p.id");
            	pstmt.setInt(1, cart_id);
            	rs = pstmt.executeQuery();
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
	<%-- Iteration code --%>
	<% 
		while (rs.next()) {
	%>
	<tr>
		<td>
			<%=rs.getInt(1)%>
		</td>
		<td>
			<%=rs.getString(2)%>
		</td>
		<td>
			<%=rs.getString(3)%>
		</td>
		<td>
			<%=rs.getDouble(4)%>
		</td>
		<form action="Product_Order.jsp" method="POST">
           	<input type="hidden" name="action" value="update"/>
           	<input type="hidden" name="product_id" value="<%=rs.getInt("id")%>"/>
           	<td>
           	<input type="number" name="quantity" min="1" value="<%=rs.getInt(5)%>"/>
           	</td>
           	<td>
           	<input type="submit" value="update"/>
           	</td>
		</form>
	</tr>
	<%
		}
	%>
	<tr>
			<form action="Buy_Shopping_Cart.jsp">
			    <button>Checkout</button>
			</form>
	</tr>
</table>
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