/**
 * @author Pooja Kirtishahi
 * @since May 2025
 * @description Represents Request body for view UMI api
 * @group Models
 */

public class ViewUMIRequestModel {
  public List<String> sopIds;
  public String creditEnquiryId;
  public Integer termMonths;
  public FabricType.FabricMoney loanAmount;
  public Integer productType;

  public enum PRODUCT_TYPE {
    LOAN_PRODUCT_TYPE_UNSPECIFIED,
    LOAN_PRODUCT_TYPE_OWNER_OCCUPIED,
    LOAN_PRODUCT_TYPE_INVESTOR
  }
  /**
   * @description constructor with 1 parameter
   * @param loanRec ResidentialLoanApplication
   */
  public ViewUMIRequestModel(ResidentialLoanApplication loanRec) {
    this.sopIds = new List<String>{ loanRec?.SOP_Id__c };
    this.creditEnquiryId = loanRec?.Credit_ID__c;
    this.termMonths = Integer.valueOf(loanRec?.AmortizationTerm);
    this.loanAmount = new FabricType.FabricMoney(
      'AUD',
      loanRec?.LotOriginalCost
    );
    PRODUCT_TYPE productTypeValue = PRODUCT_TYPE.valueOf(
      loanRec?.Property_Use__c ?? 'LOAN_PRODUCT_TYPE_OWNER_OCCUPIED'
    );
    this.productType = productTypeValue.ordinal();
  }
}
