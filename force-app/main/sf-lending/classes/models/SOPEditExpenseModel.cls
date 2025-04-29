/**
 * @author Vidhya Raghavan
 * @since Oct 2023
 * @description SOPExpenseNode wrapper for edit SOP expense Modal
 * @group Models
 */
public class SOPEditExpenseModel {
  public String parent;
  public List<MonthlyExpense> monthlyExpenses;

  /**
   * @description MonthlyExpense base class for expense list
   */
  public class MonthlyExpense {
    public String name;
    public String uid;
    public String categoryId;
    public String expenseParent;
    public String categoryName;
    public String control;
    public String review;
    public SOPMoney statedMonthlyAverageAmount;
    public Boolean leafNode;
    public String etag;
    public String hemState;
    public String justificationCode;
    public String otherJustificationText;
  }
}
