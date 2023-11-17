/**
 * @author Lance Shi
 * @since Oct 2023
 * @description class to keep constants for BOH features
 */
public class BOHConstants {
  public static final String BIT_LOW_WARNING = 'This looks a bit low. Please make sure it\'s accurate';
  public static final String LOW_WARNING = 'This looks low. You can adjust the number or select a reason';
  public static final String EXPENSE_ESSENTIALS = 'Essentials';
  public static final String MANDATORY_FIELD_MISSING = 'Please fill in all the mandatory fields. ';
  public static final String MANDATORY_DETAIL_MISSING = 'Mandatory Information is missing from the Income Details. An entry is required for all the fields within each Income Type. Please review and try again.';
  public static final String START_DATE_ERROR = 'The Start Date cannot be in the future. Please review and try again.';

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
