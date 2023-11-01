/**
 * @author Vidhya Raghavan
 * @since Sep 2023
 * @description model for SOP DebtSources.returns all the sop credit bureau related values
 * @group Models
 */

public class SOPDebtSources {
  public String partyId;
  public String type;
  public String subType;
  public Datetime retrievedTime;
  /**
   * @description return update time in the expected format
   */
  public String updateRetrievedTimeStr {
    get {
      if (
        loadBureauLiabilitiesState == 'LOAD_BUREAU_LIABILITIES_STATE_COMPLETE'
      ) {
        return SOPModel.CREDIT_CHECK_COMPLETED +
          '' +
          BOHService.getFormatedDate(retrievedTime);
      } else {
        return SOPModel.CREDIT_CHECK_ATTEMPTED;
      }
    }
  }
  public string loadBureauLiabilitiesState;
}
