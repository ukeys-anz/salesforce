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

  public static final String BOH_CLOSED_STATUS = 'Closed';
  public static final String BOH_NEW_STATUS = 'New';
  public static final String BOH_AUTO_CLOSED_SUB_STATUS = 'Auto-closed';
  public static final String BOH_OPPORTUNITY_IDENTIFIED_SUB_STATUS = 'Opportunity identified';
  public static final String BOH_REFERRED_TO_CLASSIC_SUB_STATUS = 'Referred to Classic';

  public static final List<String> BOH_SUB_STATUS_FOR_CONVERSION = new List<String>{
    BOH_OPPORTUNITY_IDENTIFIED_SUB_STATUS,
    BOH_REFERRED_TO_CLASSIC_SUB_STATUS
  };

  /**
   * @description fetch ANZx case status Closed - Expired
   * @return String case status Closed - Expired
   */
  public static final String caseClosedExpiredStatus {
    get {
      return 'Closed - Expired';
    }
    private set;
  }

  /**
   * @description fetch ANZx case status Closed - Cancelled
   * @return String case status Closed - Cancelled
   */
  public static final String caseClosedCancelledStatus {
    get {
      return 'Closed - Cancelled';
    }
    private set;
  }

  /**
   * @description fetch Residential Loan Application Reason Credit Assessment Expired
   * @return String Residential Loan Application Reason Credit Assessment Expired
   */
  public static final String rlaReasonCreditAssessmentExpired {
    get {
      return 'Credit Assessment Expired';
    }
    private set;
  }

  /**
   * @description fetch ANZx rla status State_Cancelled
   * @return String rla status State_Cancelled
   */
  public static final String rlaStateCancelledStatus {
    get {
      return 'STATE_CANCELLED';
    }
    private set;
  }

  public enum EXPENSE_CONTROL {
    EXPENSE_CONTROL_WARNING,
    EXPENSE_CONTROL_BREACHED,
    EXPENSE_CONTROL_JUSTIFIED
  }
  public enum EXPENSE_REVIEW {
    EXPENSE_REVIEW_COMPLETED,
    EXPENSE_REVIEW_REQUIRED
  }

  public enum CFAAS_DOCUMENT_FLAG {
    EXISTING,
    CREATING
  }

  public enum CFAAS_FILE_STATUS {
    FINALVERSION,
    DRAFT
  }
}
