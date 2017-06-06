package ucsd.shoppingApp;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;

import ucsd.shoppingApp.models.AnalyticsHeaderModel;

public class AnalyticsDAO {
	private static String [] selectClauses = {
	"SELECT pe.id, pe.person_name, COALESCE(SUM(pic.price * pic.quantity),0) AS row_sum\n",
	"SELECT pr.id, pr.product_name, COALESCE(SUM(pic.price * pic.quantity),0) AS col_sum\n",
	"SELECT st.id, st.state_name, COALESCE(SUM(pic.price * pic.quantity),0) as row_sum\n",
	"SELECT SUM(pic.price * pic.quantity) as cell_sum\n"
	};

	private static String [] fromClauses = {
	"FROM person pe LEFT OUTER JOIN shopping_cart sc ON sc.person_id = pe.id LEFT OUTER JOIN products_in_cart pic ON pic.cart_id = sc.id\n",
	"FROM product pr LEFT OUTER JOIN products_in_cart pic ON pic.product_id = pr.id LEFT OUTER JOIN shopping_cart sc ON pic.cart_id = sc.id\n",
	"FROM state st LEFT OUTER JOIN person pe ON st.id = pe.state_id LEFT OUTER JOIN shopping_cart sc ON sc.person_id = pe.id LEFT OUTER JOIN products_in_cart pic ON pic.cart_id = sc.id\n",
	"FROM shopping_cart sc JOIN products_in_cart ON pic.cart_id = sc.id\n",
	"FROM person pe LEFT OUTER JOIN shopping_cart sc ON sc.person_id = pe.id LEFT OUTER JOIN products_in_cart pic ON (pic.cart_id = sc.id AND pic.product_id IN (SELECT pr.id FROM product pr WHERE pr.category_id = ?))\n",
 	"FROM state st LEFT OUTER JOIN person pe ON st.id = pe.state_id LEFT OUTER JOIN shopping_cart sc ON sc.person_id = pe.id LEFT OUTER JOIN products_in_cart pic ON (pic.cart_id = sc.id AND pic.product_id IN (SELECT pr.id FROM product pr WHERE pr.category_id = ?))\n"
	};

	private static String [] whereClauses = {
	"WHERE sc.is_purchased = TRUE OR sc.is_purchased IS NULL\n",
	"WHERE (sc.is_purchased = TRUE OR sc.is_purchased IS NULL) AND (pr.category_id = ? OR pr.category_id IS NULL)\n"
	};

	private static String [] groupClauses = {
	"GROUP BY pe.id, pe.person_name\n",
	"GROUP BY pr.id, pr.product_name\n",
	"GROUP BY st.id, st.state_name\n",
	};

	private static String [] orderClauses = {
	"ORDER BY pe.person_name\n",
	"ORDER BY pr.product_name\n",
	"ORDER BY st.state_name\n",
	"ORDER BY row_sum DESC\n",
	"ORDER BY col_sum DESC\n"
	};

	private static String [] limitClauses = {
	"LIMIT 21\n",
	"LIMIT 11\n"
	};

	private static String cellContentClauses = "SELECT cr.id, cc.id, ce.cell_sum\n" +
				          "FROM curr_row cr LEFT OUTER JOIN curr_col cc ON TRUE LEFT OUTER JOIN cell ce ON (ce.group_id = cr.id AND ce.product_id = cc.id)\n";
	private String [] cellClauses = {
 	"SELECT cr.id as group_id, cc.id as product_id, COALESCE(SUM(pic.price * pic.quantity),0) AS cell_sum\n" +
 	"FROM curr_row cr, curr_col cc, shopping_cart sc, products_in_cart pic\n" +
 	"WHERE sc.is_purchased = TRUE AND pic.cart_id = sc.id AND sc.person_id = cr.id AND pic.product_id = cc.id\n" +
	"GROUP BY cr.id, cc.id\n",
 	"SELECT pr.state_id as group_id, cc.id as product_id, COALESCE(SUM(pic.price * pic.quantity),0) as cell_sum\n" +
 	"FROM person pr, curr_col cc, shopping_cart sc, products_in_cart pic\n" +
 	"WHERE sc.is_purchased = TRUE AND pic.cart_id = sc.id AND sc.person_id = pr.id AND pic.product_id = cc.id\n" +
 	"GROUP BY pr.state_id, cc.id\n"
	};

	private static String offsetClauses = "OFFSET ?\n";

	private Connection con;
	private ArrayList<AnalyticsHeaderModel> rowHeader;
	private ArrayList<AnalyticsHeaderModel> colHeader;
	private HashMap<String, Double> cellMap;

	public AnalyticsDAO(Connection con) {
		this.con = con;
	}

	public void excuteAnalytics(String groupName, String sortOrder, int category_id, int row_offset, int col_offset) {
		String rowQuery = "";
		String colQuery = "";
		String cellQuery = "";

      	PreparedStatement rowPstmt = null;
      	PreparedStatement colPstmt = null;
      	PreparedStatement cellPstmt = null;
      	ResultSet rowRs = null;
      	ResultSet colRs = null;
      	ResultSet cellRs = null;

      	try {
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

		rowHeader = new ArrayList<AnalyticsHeaderModel>();
		colHeader = new ArrayList<AnalyticsHeaderModel>();
		cellMap = new HashMap<String, Double>();

		rowRs = rowPstmt.executeQuery();
		colRs = colPstmt.executeQuery();
		cellRs = cellPstmt.executeQuery();

		while (rowRs.next()) {
			AnalyticsHeaderModel head = new AnalyticsHeaderModel(rowRs.getInt(1), rowRs.getString(2), rowRs.getDouble(3));
			rowHeader.add(head);
		}

		while (colRs.next()) {
			AnalyticsHeaderModel head = new AnalyticsHeaderModel(colRs.getInt(1), colRs.getString(2), colRs.getDouble(3));
			colHeader.add(head);
		}

		while (cellRs.next()) {
			int row = cellRs.getInt(1);
			int col = cellRs.getInt(2);
			double sum = cellRs.getDouble(3);
			String key = "" + row + "+" + col;
			cellMap.put(key,sum);
        }
    	} catch (Exception e) {
    		e.printStackTrace();
    	} finally {
    		try {
    			if (rowRs != null) {
    				rowRs.close();
    			}
    			if (colRs != null) {
    				colRs.close();
    			}
    			if (cellRs != null) {
    				cellRs.close();
    			}
    			if (rowPstmt != null) {
    				rowPstmt.close();
    			}
    			if (colPstmt != null) {
    				colPstmt.close();
    			}
    			if (cellPstmt != null) {
    				cellPstmt.close();
    			}
    		} catch (Exception e) {
    			e.printStackTrace();
    		}
    	}
	}

	public ArrayList<AnalyticsHeaderModel> getRow() {
		return rowHeader;
	}

	public ArrayList<AnalyticsHeaderModel> getCol() {
		return colHeader;
	}

	public HashMap<String,Double> getCell() {
		return cellMap;
	}
}
