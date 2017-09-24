<%@page import="java.sql.Connection, ucsd.shoppingApp.ConnectionManager, ucsd.shoppingApp.*"%>
<%@page import="ucsd.shoppingApp.AnalyticsTableHeader"%>
<%@ page import="ucsd.shoppingApp.models.* , java.util.*" %>
<%-- Import the java.sql package --%>
<%@ page import="javax.sql.*, javax.naming.*" %>
<%@ page import="java.sql.*, java.util.*, java.lang.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Similar Products</title>
</head>
<body>
<%
  String rowQuery = "SELECT pe.id, pe.person_name, COALESCE(SUM(pic.price * pic.quantity),0) AS row_sum\n" +
                    "FROM person pe JOIN shopping_cart sc ON sc.person_id = pe.id JOIN products_in_cart pic ON pic.cart_id = sc.id\n" +
                    "WHERE sc.is_purchased = TRUE\n" +
                    "GROUP BY pe.id, pe.person_name\n" +
                    "ORDER BY row_sum DESC\n";
  String colQuery = "SELECT pr.id, pr.product_name, SUM(pic.price * pic.quantity) AS col_sum\n" +
                    "FROM product pr JOIN products_in_cart pic ON pic.product_id = pr.id JOIN shopping_cart sc ON pic.cart_id = sc.id\n" +
                    "WHERE sc.is_purchased = TRUE\n" +
                    "GROUP BY pr.id, pr.product_name\n" +
                    "ORDER BY col_sum DESC\n";
  String cellQuery = "SELECT cr.id AS person_id, cr.person_name, cc.id AS product_id, cc.product_name, COALESCE(SUM(pic.price * pic.quantity),0) AS cell_sum\n" +
                     "FROM curr_row cr, curr_col cc, shopping_cart sc, products_in_cart pic\n" +
                     "WHERE sc.is_purchased = TRUE AND pic.cart_id = sc.id AND sc.person_id = cr.id AND pic.product_id = cc.id\n" +
                     "GROUP BY cr.id, cr.person_name, cc.id, cc.product_name\n";
  String cellContentQuery = "SELECT cr.id AS person_id, cr.person_name, cc.id AS product_id, cc.product_name, COALESCE(ce.cell_sum,0) AS sales\n" +
                            "FROM curr_row cr LEFT OUTER JOIN curr_col cc ON TRUE LEFT OUTER JOIN cell ce ON (cr.id = ce.person_id AND cc.id = ce.product_id)\n";
  String mainQuery = "SELECT c1.product_id AS product1_id, c1.product_name AS product1_name, c2.product_id AS product2_id, c2.product_name AS product2_name, (SUM(c1.sales * c2.sales) / SQRT(SUM(c1.sales * c1.sales)) / SQRT(SUM(c2.sales * c2.sales))) AS similarity\n" +
                     "FROM cellcontent c1, cellcontent c2\n" +
                     "WHERE c1.person_id = c2.person_id AND c1.product_id < c2.product_id\n" +
                     "GROUP BY product1_id, product1_name, product2_id, product2_name\n" +
                     "ORDER BY similarity DESC\n" +
                     "LIMIT 100\n";
  String similarQuery = "WITH curr_row AS (" + rowQuery + "),\n" +
                        "curr_col AS (" + colQuery + "),\n" +
                        "cell AS(" + cellQuery + "),\n" +
                        "cellcontent AS(" + cellContentQuery + ")\n" +
                        mainQuery;
%>
<%-- Open connection code --%>
<%
	if(session.getAttribute("roleName") != null) {
		String role = session.getAttribute("roleName").toString();
		if("owner".equalsIgnoreCase(role) == true){
			Connection con = null;
      PreparedStatement pstmt = null;
      ResultSet rs = null;
			try {
				con = ConnectionManager.getConnection();
        pstmt = con.prepareStatement(similarQuery);
        rs = pstmt.executeQuery();
        int rowCount = 0;

%>
	<table cellspacing="5">
		<tr>
			<td valign="top"><jsp:include page="menu.jsp"></jsp:include></td>
			<td></td>
			<td valign="top">
				<h3>Hello <%= session.getAttribute("personName") %></h3>
				<h3>Similar Products</h3>
			</td>
			<td></td>
			<td>
				<table width = 1000, height = 1000, border=1 style="border-collapse: collapse; table-layout:fixed">
        <tr>
          <th>No.</th>
          <th>Product 1</th>
          <th>Product 2</th>
          <th>Similarity</th>
        </tr>
        <% while (rs.next()) {
           rowCount = rowCount + 1; %>
           <tr>
             <td style="text-align:center"><%=rowCount %></td>
             <td style="text-align:center"><%=rs.getString(2)%></td>
             <td style="text-align:center"><%=rs.getString(4)%></td>
             <td style="text-align:center"><%=rs.getDouble(5)%></td>
           </tr>
        <% } %>
        <% for (int i = 0; i < 100 - rowCount; i++) { %>
           <tr>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
           </tr>
        <% } %>
				</table>
			</td>
		</tr>
	</table>
<%
				con.close();
			} catch (Exception e) {
				out.write("<h3>An exception has occured</h3>");
				throw new RuntimeException(e);
			} finally {
				if (con != null) {
					try {
						con.close();
					} catch (Exception e) { } // Ignore
						con = null;
					}
			}
		}
		else { %>
			<h3>This page is available to owners only</h3>
		<%
		}
	}
	else { %>
			<h3>Please <a href = "./login.jsp">login</a> before viewing the page</h3>
	<%} %>
</body>
</html>
