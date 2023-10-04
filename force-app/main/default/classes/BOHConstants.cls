/**
 * @author Lance Shi
 * @since Oct 2023
 * @description class to keep constants for BOH features
 */
public class BOHConstants {
  public static final String BIT_LOW_WARNING = 'This looks a bit low. Please make sure it\'s accurate';
  public static final String LOW_WARNING = 'This looks low. You can adjust the number or select a reason';
  public static final String EXPENSE_ESSENTIALS = 'Essentials';

  public enum EXPENSE_CONTROL {
    EXPENSE_CONTROL_WARNING,
    EXPENSE_CONTROL_BREACHED,
    EXPENSE_CONTROL_JUSTIFIED
  }
  public enum EXPENSE_REVIEW {
    EXPENSE_REVIEW_COMPLETED,
    EXPENSE_REVIEW_REQUIRED
  }
}
