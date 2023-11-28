/**
 * @author Lance Shi
 * @since Jun 2023
 * @description model for SOP Expense
 * @group Models
 */
@SuppressWarnings(
  'PMD.CyclomaticComplexity, PMD.StdCyclomaticComplexity, PMD.ExcessivePublicCount, PMD.ExcessiveClassLength, PMD.TooManyFields'
)
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
  public String control;
  public String justificationCode;
  public String warningMessage;
  public Boolean showWarningIcon = false;
  public Boolean showWarningMessage = false;
  public Boolean hasReason = false;
  public String reason;
  public String warningReason;
  public String etag;
  public String hemState;
  public String uid;

  /**
   * @description return update time in the expected format
   */
  public String updateTimeStr {
    get {
      return BOHService.getFormatedDate(updateTime);
    }
  }

  /**
   * @description return empty string when otherJustificationText is null or not 'Other'
   */
  public String otherJustificationText {
    get {
      if(otherJustificationText != null && reason == 'Other') {
        return otherJustificationText;
      }
      return '';
    }
    
  }
}
