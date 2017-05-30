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
<title>Sales Analytics</title>
</head>
<body>
<%
long start_time = System.currentTimeMillis();
String [] selectClauses = {
  "SELECT pe.id, pe.person_name, COALESCE(SUM(pic.price * pic.quantity),0) AS row_sum\n",
  "SELECT pr.id, pr.product_name, COALESCE(SUM(pic.price * pic.quantity),0) AS col_sum\n",
  "SELECT st.id, st.state_name, COALESCE(SUM(pic.price * pic.quantity),0) as row_sum\n",
  "SELECT SUM(pic.price * pic.quantity) as cell_sum\n"
};

String [] fromClauses = {
  "FROM person pe LEFT OUTER JOIN shopping_cart sc ON sc.person_id = pe.id LEFT OUTER JOIN products_in_cart pic ON pic.cart_id = sc.id\n",
  "FROM product pr LEFT OUTER JOIN products_in_cart pic ON pic.product_id = pr.id LEFT OUTER JOIN shopping_cart sc ON pic.cart_id = sc.id\n",
  "FROM state st LEFT OUTER JOIN person pe ON st.id = pe.state_id LEFT OUTER JOIN shopping_cart sc ON sc.person_id = pe.id LEFT OUTER JOIN products_in_cart pic ON pic.cart_id = sc.id\n",
  "FROM shopping_cart sc JOIN products_in_cart ON pic.cart_id = sc.id\n",
  "FROM person pe LEFT OUTER JOIN shopping_cart sc ON sc.person_id = pe.id LEFT OUTER JOIN products_in_cart pic ON (pic.cart_id = sc.id AND pic.product_id IN (SELECT pr.id FROM product pr WHERE pr.category_id = ?))\n",
  "FROM state st LEFT OUTER JOIN person pe ON st.id = pe.state_id LEFT OUTER JOIN shopping_cart sc ON sc.person_id = pe.id LEFT OUTER JOIN products_in_cart pic ON (pic.cart_id = sc.id AND pic.product_id IN (SELECT pr.id FROM product pr WHERE pr.category_id = ?))\n"
};

String [] whereClauses = {
  "WHERE sc.is_purchased = TRUE OR sc.is_purchased IS NULL\n",
  "WHERE (sc.is_purchased = TRUE OR sc.is_purchased IS NULL) AND (pr.category_id = ? OR pr.category_id IS NULL)\n"
};

String [] groupClauses = {
  "GROUP BY pe.id, pe.person_name\n",
  "GROUP BY pr.id, pr.product_name\n",
  "GROUP BY st.id, st.state_name\n",
};

String [] orderClauses = {
  "ORDER BY pe.person_name\n",
  "ORDER BY pr.product_name\n",
  "ORDER BY st.state_name\n",
  "ORDER BY row_sum DESC\n",
  "ORDER BY col_sum DESC\n"
};

String [] limitClauses = {
  "LIMIT 21\n",
  "LIMIT 11\n"
};

String cellContentClauses = "SELECT cr.id, cc.id, ce.cell_sum\n" +
                  "FROM curr_row cr LEFT OUTER JOIN curr_col cc ON TRUE LEFT OUTER JOIN cell ce ON (ce.group_id = cr.id AND ce.product_id = cc.id)\n";
String [] cellClauses = {
  "SELECT cr.id as group_id, cc.id as product_id, COALESCE(SUM(pic.price * pic.quantity),0) AS cell_sum\n" +
  "FROM curr_row cr, curr_col cc, shopping_cart sc, products_in_cart pic\n" +
  "WHERE sc.is_purchased = TRUE AND pic.cart_id = sc.id AND sc.person_id = cr.id AND pic.product_id = cc.id\n" +
  "GROUP BY cr.id, cc.id\n",
  "SELECT pr.state_id as group_id, cc.id as product_id, COALESCE(SUM(pic.price * pic.quantity),0) as cell_sum\n" +
  "FROM person pr, curr_col cc, shopping_cart sc, products_in_cart pic\n" +
  "WHERE sc.is_purchased = TRUE AND pic.cart_id = sc.id AND sc.person_id = pr.id AND pic.product_id = cc.id\n" +
  "GROUP BY pr.state_id, cc.id\n"
};
String offsetClauses = "OFFSET ?\n";

%>
<%-- Open connection code --%>
<%
  String groupName = "c";
  if (request.getParameter("group_name") != null) {
    groupName = request.getParameter("group_name");
  }
  String sortOrder = "alpha";
  if (request.getParameter("sort_order") != null) {
    sortOrder = request.getParameter("sort_order");
  }
  int category_id = 0;
  if (request.getParameter("category_id") != null) {
    category_id = Integer.parseInt(request.getParameter("category_id"));
  }
  int row_offset = 0;
  if (request.getParameter("row_offset") != null) {
    row_offset = Integer.parseInt(request.getParameter("row_offset"));
  }
  int col_offset = 0;
  if (request.getParameter("col_offset") != null) {
    col_offset = Integer.parseInt(request.getParameter("col_offset"));
  }



  if(session.getAttribute("roleName") != null) {
    String role = session.getAttribute("roleName").toString();
    if("owner".equalsIgnoreCase(role) == true){
      Connection con = null;
      PreparedStatement rowPstmt = null;
      PreparedStatement colPstmt = null;
      PreparedStatement cellPstmt = null;
      ResultSet rowRs = null;
      ResultSet colRs = null;
      ResultSet cellRs = null;
      try{
        con = ConnectionManager.getConnection();

%>
<%-- Get categories list code --%>
<%
  CategoryDAO cd = new CategoryDAO(con);
  List<CategoryModel> category_list = cd.getCategories();
%>
  <table cellspacing="5">
    <tr>
      <td valign="top"><jsp:include page="menu.jsp"></jsp:include></td>
      <td></td>
      <td valign="top">
        <h3>Hello <%= session.getAttribute("personName") %></h3>
        <h3>Sales Analytics</h3>
        <form action="analytics.jsp" method="post">
          <%if(col_offset == 0 && row_offset == 0 ){ %>
          <p>Group by:</p>
          <select required name="group_name">
            <% if(groupName.equals("s")){ %>
            <option value = 'c'> Customer </option>
            <option selected value = 's'> State </option>
            <%}else{ %>
            <option selected value = 'c'> Customer </option>
            <option value = 's'> State </option>
            <%} %>
          </select>
          <p>Sort with:</p>
          <select required name="sort_order">
            <% if(sortOrder.equals("topk")){ %>
            <option value = 'alpha'> Alphabetic </option>
            <option selected value = 'topk'> Top K </option>
            <%}else{ %>
            <option selected value = 'alpha'> Alphabetic </option>
            <option value = 'topk'> Top K </option>
            <%} %>
          </select>
          <p>Product categories:</p>
          <select required name="category_id">
            <option value = 0> All</option>
            <%
              for (CategoryModel cat : category_list) {
                if(cat.getId() == category_id){
            %>
                <option selected  value="<%= cat.getId() %>"><%=cat.getCategoryName() %></option>
            <%    }else{ %>
                <option value = <%= cat.getId() %>><%= cat.getCategoryName()%></option>
            <%    }
              } %>
          </select>
              <p> </p>
              <input type="submit" value="Run Query"></input>
                <%}else{ %>
              <p>Group by:</p>
          <select disabled name="group_name">
            <% if(groupName.equals("s")){ %>
            <option value = 'c'> Customer </option>
            <option selected value = 's'> State </option>
            <%}else{ %>
            <option selected value = 'c'> Customer </option>
            <option value = 's'> State </option>
            <%} %>
          </select>
          <p>Sort with:</p>
          <select disabled name="sort_order">
            <% if(sortOrder.equals("topk")){ %>
            <option value = 'alpha'> Alphabetic </option>
            <option selected value = 'topk'> Top K </option>
            <%}else{ %>
            <option selected value = 'alpha'> Alphabetic </option>
            <option value = 'topk'> Top K </option>
            <%} %>
          </select>
          <p>Product categories:</p>
          <select disabled name="category_id">
            <option value = 0> All</option>
            <%
              for (CategoryModel cat : category_list) {
                if(cat.getId() == category_id){
            %>
                <option selected  value="<%= cat.getId() %>"><%=cat.getCategoryName() %></option>
            <%    }else{ %>
                <option value = <%= cat.getId() %>><%= cat.getCategoryName()%></option>
            <%    }
              } %>
          </select>
              <p> </p>
              <input disabled type="submit" value="Run Query"></input>
              <%} %>
        </form>
      </td>
      <td></td>
      <td>
<%
        String rowQuery = "";
        String colQuery = "";
        String cellQuery = "";


        if (groupName.equalsIgnoreCase("c") && sortOrder.equalsIgnoreCase("alpha") && category_id == 0) {
          rowQuery = selectClauses[0] + fromClauses[0] + whereClauses[0] + groupClauses[0] + orderClauses[0] + limitClauses[0] + offsetClauses;
          colQuery = selectClauses[1] + fromClauses[1] + whereClauses[0] + groupClauses[1] + orderClauses[1] + limitClauses[1] + offsetClauses;
          cellQuery = "WITH curr_row AS (" + rowQuery + "),\n" +
                      "curr_col AS (" + colQuery + "),\n" +
                      "cell AS (" + cellClauses[0] + ")\n" +
                      cellContentClauses;
          rowPstmt = con.prepareStatement(rowQuery);
          rowPstmt.setInt(1,row_offset);
          colPstmt = con.prepareStatement(colQuery);
          colPstmt.setInt(1,col_offset);
          cellPstmt = con.prepareStatement(cellQuery);
          cellPstmt.setInt(1,row_offset);
          cellPstmt.setInt(2,col_offset);
        } else if (groupName.equalsIgnoreCase("c") && sortOrder.equalsIgnoreCase("topk") && category_id == 0) {
          rowQuery = selectClauses[0] + fromClauses[0] + whereClauses[0] + groupClauses[0] + orderClauses[3] + limitClauses[0] + offsetClauses;
          colQuery = selectClauses[1] + fromClauses[1] + whereClauses[0] + groupClauses[1] + orderClauses[4] + limitClauses[1] + offsetClauses;
          cellQuery = "WITH curr_row AS (" + rowQuery + "),\n" +
                      "curr_col AS (" + colQuery + "),\n" +
                      "cell AS (" + cellClauses[0] + ")\n" +
                      cellContentClauses;
          rowPstmt = con.prepareStatement(rowQuery);
          rowPstmt.setInt(1, row_offset);
          colPstmt = con.prepareStatement(colQuery);
          colPstmt.setInt(1,col_offset);
          cellPstmt = con.prepareStatement(cellQuery);
          cellPstmt.setInt(1,row_offset);
          cellPstmt.setInt(2,col_offset);
        } else if (groupName.equalsIgnoreCase("s") && sortOrder.equalsIgnoreCase("alpha") && category_id == 0) {
          rowQuery = selectClauses[2] + fromClauses[2] + whereClauses[0] + groupClauses[2] + orderClauses[2] + limitClauses[0] + offsetClauses;
          colQuery = selectClauses[1] + fromClauses[1] + whereClauses[0] + groupClauses[1] + orderClauses[1] + limitClauses[1] + offsetClauses;
          cellQuery = "WITH curr_row AS (" + rowQuery + "),\n" +
                      "curr_col AS (" + colQuery + "),\n" +
                      "cell AS (" + cellClauses[1] + ")\n" +
                      cellContentClauses;
          rowPstmt = con.prepareStatement(rowQuery);
          rowPstmt.setInt(1, row_offset);
          colPstmt = con.prepareStatement(colQuery);
          colPstmt.setInt(1,col_offset);
          cellPstmt = con.prepareStatement(cellQuery);
          cellPstmt.setInt(1,row_offset);
          cellPstmt.setInt(2,col_offset);
        } else if (groupName.equalsIgnoreCase("s") && sortOrder.equalsIgnoreCase("topk") && category_id == 0) {
          rowQuery = selectClauses[2] + fromClauses[2] + whereClauses[0] + groupClauses[2] + orderClauses[3] + limitClauses[0] + offsetClauses;
          colQuery = selectClauses[1] + fromClauses[1] + whereClauses[0] + groupClauses[1] + orderClauses[4] + limitClauses[1] + offsetClauses;
          cellQuery = "WITH curr_row AS (" + rowQuery + "),\n" +
                      "curr_col AS (" + colQuery + "),\n" +
                      "cell AS (" + cellClauses[1] + ")\n" +
                      cellContentClauses;
          rowPstmt = con.prepareStatement(rowQuery);
          rowPstmt.setInt(1, row_offset);
          colPstmt = con.prepareStatement(colQuery);
          colPstmt.setInt(1,col_offset);
          cellPstmt = con.prepareStatement(cellQuery);
          cellPstmt.setInt(1,row_offset);
          cellPstmt.setInt(2,col_offset);
        } else if (groupName.equalsIgnoreCase("c") && sortOrder.equalsIgnoreCase("alpha") && category_id > 0) {
          rowQuery = selectClauses[0] + fromClauses[4] + whereClauses[0] + groupClauses[0] + orderClauses[0] + limitClauses[0] + offsetClauses;
          colQuery = selectClauses[1] + fromClauses[1] + whereClauses[1] + groupClauses[1] + orderClauses[1] + limitClauses[1] + offsetClauses;
          cellQuery = "WITH curr_row AS (" + rowQuery + "),\n" +
                      "curr_col AS (" + colQuery + "),\n" +
                      "cell AS (" + cellClauses[0] + ")\n" +
                      cellContentClauses;
          rowPstmt = con.prepareStatement(rowQuery);
          rowPstmt.setInt(1, category_id);
          rowPstmt.setInt(2, row_offset);
          colPstmt = con.prepareStatement(colQuery);
          colPstmt.setInt(1, category_id);
          colPstmt.setInt(2, col_offset);
          cellPstmt = con.prepareStatement(cellQuery);
          cellPstmt.setInt(1, category_id);
          cellPstmt.setInt(2, row_offset);
          cellPstmt.setInt(3, category_id);
          cellPstmt.setInt(4, col_offset);
        } else if (groupName.equalsIgnoreCase("c") && sortOrder.equalsIgnoreCase("topk") && category_id > 0) {
          rowQuery = selectClauses[0] + fromClauses[4] + whereClauses[0] + groupClauses[0] + orderClauses[3] + limitClauses[0] + offsetClauses;
          colQuery = selectClauses[1] + fromClauses[1] + whereClauses[1] + groupClauses[1] + orderClauses[4] + limitClauses[1] + offsetClauses;
          cellQuery = "WITH curr_row AS (" + rowQuery + "),\n" +
                      "curr_col AS (" + colQuery + "),\n" +
                      "cell AS (" + cellClauses[0] + ")\n" +
                      cellContentClauses;
          rowPstmt = con.prepareStatement(rowQuery);
          rowPstmt.setInt(1, category_id);
          rowPstmt.setInt(2, row_offset);
          colPstmt = con.prepareStatement(colQuery);
          colPstmt.setInt(1, category_id);
          colPstmt.setInt(2, col_offset);
          cellPstmt = con.prepareStatement(cellQuery);
          cellPstmt.setInt(1, category_id);
          cellPstmt.setInt(2, row_offset);
          cellPstmt.setInt(3, category_id);
          cellPstmt.setInt(4, col_offset);
        } else if (groupName.equalsIgnoreCase("s") && sortOrder.equalsIgnoreCase("alpha") && category_id > 0) {
          rowQuery = selectClauses[2] + fromClauses[5] + whereClauses[0] + groupClauses[2] + orderClauses[2] + limitClauses[0] + offsetClauses;
          colQuery = selectClauses[1] + fromClauses[1] + whereClauses[1] + groupClauses[1] + orderClauses[1] + limitClauses[1] + offsetClauses;
          cellQuery = "WITH curr_row AS (" + rowQuery + "),\n" +
                      "curr_col AS (" + colQuery + "),\n" +
                      "cell AS (" + cellClauses[1] + ")\n" +
                      cellContentClauses;
          rowPstmt = con.prepareStatement(rowQuery);
          rowPstmt.setInt(1, category_id);
          rowPstmt.setInt(2, row_offset);
          colPstmt = con.prepareStatement(colQuery);
          colPstmt.setInt(1, category_id);
          colPstmt.setInt(2, col_offset);
          cellPstmt = con.prepareStatement(cellQuery);
          cellPstmt.setInt(1, category_id);
          cellPstmt.setInt(2, row_offset);
          cellPstmt.setInt(3, category_id);
          cellPstmt.setInt(4, col_offset);
        } else if (groupName.equalsIgnoreCase("s") && sortOrder.equalsIgnoreCase("topk") && category_id > 0) {
          rowQuery = selectClauses[2] + fromClauses[5] + whereClauses[0] + groupClauses[2] + orderClauses[3] + limitClauses[0] + offsetClauses;
          colQuery = selectClauses[1] + fromClauses[1] + whereClauses[1] + groupClauses[1] + orderClauses[4] + limitClauses[1] + offsetClauses;
          cellQuery = "WITH curr_row AS (" + rowQuery + "),\n" +
                      "curr_col AS (" + colQuery + "),\n" +
                      "cell AS (" + cellClauses[1] + ")\n" +
                      cellContentClauses;
          rowPstmt = con.prepareStatement(rowQuery);
          rowPstmt.setInt(1, category_id);
          rowPstmt.setInt(2, row_offset);
          colPstmt = con.prepareStatement(colQuery);
          colPstmt.setInt(1, category_id);
          colPstmt.setInt(2, col_offset);
          cellPstmt = con.prepareStatement(cellQuery);
          cellPstmt.setInt(1, category_id);
          cellPstmt.setInt(2, row_offset);
          cellPstmt.setInt(3, category_id);
          cellPstmt.setInt(4, col_offset);
        }

        rowRs = rowPstmt.executeQuery();
        colRs = colPstmt.executeQuery();
        cellRs = cellPstmt.executeQuery();
        ArrayList<AnalyticsTableHeader> rowHeader = new ArrayList<AnalyticsTableHeader>();
        ArrayList<AnalyticsTableHeader> colHeader = new ArrayList<AnalyticsTableHeader>();
        HashMap<String,Double> cellMap = new HashMap<String,Double>();

        while (rowRs.next()) {
          AnalyticsTableHeader head = new AnalyticsTableHeader(rowRs.getInt(1), rowRs.getDouble(3), rowRs.getString(2));
          rowHeader.add(head);
        }

        while (colRs.next()) {
          AnalyticsTableHeader head = new AnalyticsTableHeader(colRs.getInt(1), colRs.getDouble(3), colRs.getString(2));
          colHeader.add(head);
        }

        while (cellRs.next()) {
          int row = cellRs.getInt(1);
          int col = cellRs.getInt(2);
          double sum = cellRs.getDouble(3);
          String key = "" + row + "+" + col;
          cellMap.put(key,sum);
        }
        boolean rowNext = false;
        boolean colNext = false;
        int rowCount = rowHeader.size();
        if (rowCount > 20) {
          rowCount = 20;
          rowNext = true;
        }
        int colCount = colHeader.size();
        if (colCount > 10) {
          colCount = 10;
          colNext = true;
        }
%>
        <table width = 1000, height = 1000, border=1 style="border-collapse: collapse; table-layout:fixed">
          <thead>
          <tr>
                    <td><p>Group\Prod<p></td>
                    <% for (int i = 0; i < colCount; i++) { %>
                      <td><b><%= colHeader.get(i).getName()%></b> ($<%= colHeader.get(i).getSum() %>)</td>
                    <% } %>
                    <% for (int i = 0; i < 10 - colCount; i++) { %>
                      <td> </td>
                    <% } %>
                  </tr>
                </thead>
                <tbody>
                  <% for (int i = 0; i < rowCount; i++) { %>
                  <tr>
                    <td><b><%= rowHeader.get(i).getName()%></b> ($<%= rowHeader.get(i).getSum() %>)</td>
                    <% for (int j = 0; j < colCount; j++) {
                        int row = rowHeader.get(i).getId();
                        int col = colHeader.get(j).getId();
                        String key = "" + row + "+" + col;
                        Double sum = cellMap.get(key);
                    %>
                    <td><%= sum %></td>
                    <% } %>
                    <% for (int j = 0; j < 10 - colCount; j++) { %>
                    <td> </td>
                    <% } %>
                  </tr>
                  <% } %>
                  <%for (int i = 0; i < 20 - rowCount; i++) { %>
                  <tr>
                    <td> </td>
                    <% for (int j = 0; j < 10; j++) {%>
                    <td> </td>
                    <% } %>
                  </tr>
                  <% } %>
               </tbody>
            </table>
            <% if (rowNext) { %>
            <form action="analytics.jsp" method="post">
              <input type="hidden" name="group_name" value="<%= groupName%>"/>
              <input type="hidden" name="sort_order" value="<%= sortOrder%>"/>
              <input type="hidden" name="category_id" value="<%= category_id%>"/>
              <input type="hidden" name="row_offset" value="<%= row_offset + 20%>"/>
              <input type="hidden" name="col_offset" value="<%= col_offset%>"/>
              <% if (groupName.equalsIgnoreCase("c")) { %>
              <input type="submit" value="Next 20 Customers"/>
              <% } else{ %>
              <input type="submit" value="Next 20 States"/>
              <% } %>
            </form>
            <% } %>
            <% if (colNext) { %>
            <form action="analytics.jsp" method="post">
              <input type="hidden" name="group_name" value="<%= groupName%>"/>
              <input type="hidden" name="sort_order" value="<%= sortOrder%>"/>
              <input type="hidden" name="category_id" value="<%= category_id%>"/>
              <input type="hidden" name="row_offset" value="<%= row_offset%>"/>
              <input type="hidden" name="col_offset" value="<%= col_offset + 10%>"/>
              <input type="submit" value="Next 10 Products"/>
            </form>
            <% } %>
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
<%
long end_time = System.currentTimeMillis();
System.out.println(end_time - start_time);
%>
</body>
</html>
