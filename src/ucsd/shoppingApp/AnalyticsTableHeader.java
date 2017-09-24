package ucsd.shoppingApp;

public class AnalyticsTableHeader {
  private int header_id;
  private double header_sum;
  private String header_name;

  public AnalyticsTableHeader(int id, double sum, String name) {
    header_id = id;
    header_sum = sum;
    header_name = name;
  }

  public int getId() {
    return header_id;
  }

  public double getSum() {
    return header_sum;
  }

  public String getName() {
    return header_name;
  }
}
