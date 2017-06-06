package ucsd.shoppingApp.models;

public class AnalyticsHeaderModel {
	private int header_id;
	private double header_sum;
	private String header_name;

	public AnalyticsHeaderModel() {

	}

	public AnalyticsHeaderModel(int id, String name, double sum) {
		header_id = id;
		header_name = name;
		header_sum = sum;
	}

	public void setId(int id) {
		header_id = id;
	}

	public int getId() {
		return header_id;
	}

	public void setSum(double sum) {
		header_sum = sum;
	}

	public double getSum() {
		return header_sum;
	}

	public void setName(String name) {
		header_name = name;
	}

	public String getName() {
		return header_name;
	}
}
