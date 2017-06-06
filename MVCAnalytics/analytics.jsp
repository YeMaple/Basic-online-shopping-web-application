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
  
  if (session.getAttribute("action") == null) {
	  session.setAttribute("action", "analytics");
	  response.sendRedirect("./AnalyticsController");
  }
	if(session.getAttribute("roleName") != null) {
		String role = session.getAttribute("roleName").toString();
		if("owner".equalsIgnoreCase(role) == true){
			Connection con = null;
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
				<form action="AnalyticsController" method="post">
				    <input type="hidden" name="action" value="analytics"/>
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
						<%		}else{ %>
								<option value = <%= cat.getId() %>><%= cat.getCategoryName()%></option>
						<% 		}
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
						<%		}else{ %>
								<option value = <%= cat.getId() %>><%= cat.getCategoryName()%></option>
						<% 		}
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
        ArrayList<AnalyticsHeaderModel> rowHeader = (ArrayList<AnalyticsHeaderModel>) request.getAttribute("row");
        ArrayList<AnalyticsHeaderModel> colHeader = (ArrayList<AnalyticsHeaderModel>) request.getAttribute("col");
        HashMap<String,Double> cellMap = (HashMap<String,Double>) request.getAttribute("cell");
		
        boolean rowNext = false;
        boolean colNext = false;
        int rowCount = rowHeader.size();
        int colCount = colHeader.size();
        if (rowCount > 20) {
          rowCount = 20;
          rowNext = true;
        }
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
					  <form action="AnalyticsController" method="post">
					  	<input type="hidden" name="action" value="analytics"/>
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
					  <form action="AnalyticsController" method="post">
					    <input type="hidden" name="action" value="analytics"/>
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
				//throw new RuntimeException(e);
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
//System.out.println(end_time - start_time);
%>
</body>
</html>
