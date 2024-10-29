/**
 * @author Pooja Kirtishahi
 * @since August 2024
 * @description model for linked offset account
 * @group Models
 */
@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing class OffsetAccountModel extends CalloutModel {
  @AuraEnabled
  public List<LoanOffsets> loanOffsets;
  @AuraEnabled
  public Boolean hasError = false;
  /**
   * @description Offset account details
   */
  public class LoanOffsets {
    @AuraEnabled
    public String loanAccount;
    public List<String> offsetAccounts;
    /**
     * @description Offset details Wrapper
     */
    @AuraEnabled
    public List<OffsetWrapper> offsetDetails { get; set; }
  }
  /**
   * @description Offset details Wrapper for FinAccId, FinAccNumber
   */
  public class OffsetWrapper {
    /**
     * @description financial account number for Offset account
     */
    @AuraEnabled
    public String financialAccountNumber { get; set; }
    /**
     * @description financial account Id for Offset account
     */
    @AuraEnabled
    public String financialAccountId { get; set; }
  }

  /**
   * @param json input string to deserialize
   * @return `OffsetAccountModel`
   * @description deserializes the input string into the model
   */
  public static OffsetAccountModel parse(String json) {
    return (OffsetAccountModel) deserialize(json, OffsetAccountModel.class);
  }
}
