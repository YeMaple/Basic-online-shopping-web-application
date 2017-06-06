package ucsd.shoppingApp.controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ucsd.shoppingApp.AnalyticsDAO;
import ucsd.shoppingApp.ConnectionManager;
import ucsd.shoppingApp.models.AnalyticsHeaderModel;


public class AnalyticsController extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Connection con = null;

	public void destroy() {
		if (con != null) {
			try {
				con.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}

	public AnalyticsController() {
		con = ConnectionManager.getConnection();
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String forward = "./analytics.jsp";
		AnalyticsDAO analyticsDao = new AnalyticsDAO(con);
		try {
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
			analyticsDao.excuteAnalytics(groupName, sortOrder, category_id, row_offset, col_offset);

		} catch (Exception e) {
			request.setAttribute("message", e);
			request.setAttribute("error", true);
		} finally {
			request.setAttribute("action", "analytics");
			request.setAttribute("row", analyticsDao.getRow());
			request.setAttribute("col", analyticsDao.getCol());
			request.setAttribute("cell", analyticsDao.getCell());
			RequestDispatcher view = request.getRequestDispatcher(forward);
			view.forward(request,response);
		}
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}

}
