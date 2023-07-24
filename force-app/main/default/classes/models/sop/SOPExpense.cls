/**
 * @author Lance Shi
 * @since Jun 2023
 * @description model for SOP Expense
 * @group Models
 */
public class SOPExpense { 
  public Integer layer; 
  public String name; 
  public String categoryId;
  public String expenseParent;
  public String categoryName; 
  public String review;
  public SOPMoney statedMonthlyAverageAmount; 
  public Boolean leafNode;
  public Datetime updateTime;
  /**
   * @description return update time in the expected format
   */
  public String updateTimeStr {
    get {
      return BOHService.getFormatedDate(updateTime);
    }
  }
}