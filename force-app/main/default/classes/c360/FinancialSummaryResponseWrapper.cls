/**
 * @author Naman Garg
 * @group CCRM (Commercial CRM)
 * @description FinSummaryResponse wrapper class to get the response published by mule.
 * @name FinSummaryResponse
 */
public class FinancialSummaryResponseWrapper {
  /**
   * @description Id of the Customer Record
   */
  @AuraEnabled
  public String responseId { get; set; }
  /**
   * @description Hold the value of Total Balance response published by mule
   */
  @AuraEnabled
  public Decimal totalBalance { get; set; }
  /**
   * @description Hold the value of Asset Finance Balance response published by mule
   */
  @AuraEnabled
  public Decimal totalAssetFinanceBalance { get; set; }
  /**
   * @description Tells the data & Time when Summaries values are Last updated
   */
  @AuraEnabled
  public String lastSummaryUpdateDate { get; set; }
  /**
   * @description Tells if the values exist in cache
   */
  @AuraEnabled
  public String cacheAck { get; set; }
  /**
   * @description Tells if the Total Balance value exist in cache
   */
  @AuraEnabled
  public String totalBalanceAck { get; set; }
  /**
   * @description Tells if the Asset Finance Balance value exist in cache
   */
  @AuraEnabled
  public String assetBalanceAck { get; set; }
  /**
   * @description Hold the value of TotalDebit value published by mule
   */
  @AuraEnabled
  public String totalDebitBalance { get; set; }
  /**
   * @description Hold the value of Creditbalance published by mule
   */
  @AuraEnabled
  public String totalCreditBalance { get; set; }
  /**
   * @description Tells if the TotalDebitBalance value exist in cache
   */
  @AuraEnabled
  public String totalDebitBalanceAck { get; set; }
  /**
   * @description Tells if the TotalCreditBalance value exist in cache
   */
  @AuraEnabled
  public String totalCreditBalanceAck { get; set; }
  /**
   * @description Tells if the TotalLimitValue value exist in cache
   */
  @AuraEnabled
  public String totalLimitAck { get; set; }
  /**
   * @description Hold the value of TotalLimit response published by mule
   */
  @AuraEnabled
  public String totalLimitValue { get; set; }
}
