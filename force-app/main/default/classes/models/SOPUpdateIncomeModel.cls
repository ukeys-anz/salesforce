/**
 * @author Lance Shi
 * @since Aug 2023
 * @description model for SOP Update Income
 * @group Models
 */
public class SOPUpdateIncomeModel {
  public String name;
  public String uid;
  public String etag;
  public SOPCreateIncomeModel.SOPEmploymentDetail employment = new SOPCreateIncomeModel.SOPEmploymentDetail();
  public List<SOPCreateIncomeModel.SOPIncomeEditType> details = new List<SOPCreateIncomeModel.SOPIncomeEditType>();
}
