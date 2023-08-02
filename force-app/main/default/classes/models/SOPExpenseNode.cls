/**
 * @author Lance Shi
 * @since Jun 2023
 * @description SOPExpenseNode wrapper for SOP expense information in a tree structure
 * @group Models
 */
public class SOPExpenseNode {
  public SOPExpense expense;
  public List<SOPExpenseNode> childExpenses;

  /**
   * @description SOPExpenseNode is the constructor of expense node
   * @param expense SOPExpense object to initialize the node
   */
  public SOPExpenseNode(SOPExpense expense) {
    this.expense = expense;
    this.childExpenses = new List<SOPExpenseNode>();
  }
}
