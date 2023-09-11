/**
 * @author Lance Shi
 * @since Aug 2023
 * @description model for SOP Create Income
 * @group Models
 */
public class SOPCreateIncomeModel {
  public String parent;
  public SOPIncomeEdit income = new SOPIncomeEdit();
  public SOPIncomeVerification incomeVerification = new SOPIncomeVerification();

  /**
   * @description SOPIncomeEdit model of the income information
   */
  public class SOPIncomeEdit {
    public SOPEmploymentDetail employment = new SOPEmploymentDetail();
    public List<SOPIncomeEditType> details = new List<SOPIncomeEditType>();
  }

  /**
   * @description SOPIncomeEditType information of each income type
   */
  public class SOPIncomeEditType {
    public String type;
    public String frequency;
    public SOPMoney amount;
    public String amountType;
  }

  /**
   * @description SOPEmploymentDetail information of general income
   */
  public class SOPEmploymentDetail {
    public String partyId;
    public String businessName;
    public String basis;
    public BeginDate startDate = new BeginDate();
    public String type;
  }

  /**
   * @description SOPIncomeVerification information of verification
   */
  public class SOPIncomeVerification {
    public String income;
    public String method;
  }
}
