/**
 * @author Vidhya Raghavan
 * @since Jun 2023
 * @description model for SOP Asset
 * @group Models
 */
public class SOPAsset implements Comparable {
  public String id;
  public String type;
  public String subType;
  public String assetName;
  public SOPMoney estimatedValue;
  public SOPAccounts account;
  public List<SOPOwnership> ownership;
  public String propertyId;
  public String createTime;
  public Datetime updateTime;
  public String updatedBy;

  /**
   * @description return the owner name of the asset
   */
  public string ownerName {
    get {
      if (this.ownership.size() == 1) {
        return this.ownership[0].ownerName;
      }
      return ResidentialLoanApplicationModel.JOINT_ACCOUNT;
    }
  }

  /**
   * @description sort the balance values to show on the Savings and Assets flexcard.
   * @param compareTo input object
   * @return `returnValue`
   */
  public Integer compareTo(Object compareTo) {
    SOPAsset compareToIncome = (SOPAsset) compareTo;
    Integer returnValue = 0;
    if (
      this.estimatedValue != null &&
      compareToIncome.estimatedValue != null &&
      this.estimatedValue.value < compareToIncome.estimatedValue.value
    ) {
      returnValue = 1;
    } else if (
      this.estimatedValue.value > compareToIncome.estimatedValue.value
    ) {
      returnValue = -1;
    }
    return returnValue;
  }
}
