/** @author Jaya Srivastava
 * @since Jan 2025
 * @description Request model for Refinance NCC Cases
 * @group Models
 */
public class LendingCaseResponseModel {
  /**
   * @description Details of the Approve/Reject API callout
   */
  @AuraEnabled
  public Boolean approveRejectSuccess;

  /**
   * @description Details of the Approve/Reject API callout
   */
  @AuraEnabled
  public Boolean caseUpdateSuccess;

  /**
   * @description Blank constructor for LendingCaseResponseModel
   */
  public LendingCaseResponseModel() {
  }

  /**
   * @description constructor with 2 parameter for form the response
   * @param responseApi Boolean
   * @param caseUpdate Boolean
   */
  public LendingCaseResponseModel(Boolean responseApi, Boolean caseUpdate) {
    this.approveRejectSuccess = responseApi;
    this.caseUpdateSuccess = caseUpdate;
  }
}
