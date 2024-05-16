/**
 * @author cruzb
 * @since April 2024
 * @description Model class for stream
 * @group Models
 */
public with sharing class SOPStreamDetails {
  public SOPMoney amount;
  public String incomeType;
  public String frequency;

  /**
   * @description readable frequency
   */
  public String readableFrequency {
    get {
      return ResidentialLoanApplicationModel.getReadableFrequency(
        this.frequency
      );
    }
  }
}
