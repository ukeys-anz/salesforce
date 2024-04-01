/**
 * @author : Naman Garg
 * @description : This class is the wrapper class of CCRMFinancialSummaryController
 * @since : Jan 2024
 */

@SuppressWarnings('PMD.ExcessivePublicCount')
public class CCRMFinancialSummaryWrapper {
  /**
   * @author Naman Garg
   * @group CCRM (Commercial CRM)
   * @description TotalBalance wrapper class to call Total Customer Balance API
   * @name TotalBalance
   */
  public class TotalBalance {
    public List<String> accounts = new List<String>();
    public String fieldSet;
    public String responseId;

    /**
     * @description It is the constructor to populate the TotalBalance
     * @param accounts List of Account Ids
     * @param fieldSet Name of the FieldSet
     * @param responseId Record Id of customer
     */
    public TotalBalance(
      List<String> accounts,
      String fieldSet,
      String responseId
    ) {
      this.accounts = accounts;
      this.fieldSet = fieldSet;
      this.responseId = responseId;
    }
  }

  /**
   * @author Naman Garg
   * @group CCRM (Commercial CRM)
   * @description TerminalAndTotalAsset wrapper class to call Terminal and Total Asset Balance API
   * @name TerminalAndTotalAsset
   */
  public class TerminalAndTotalAsset {
    public List<String> capCustomerIds = new List<String>();
    public String type;
    public String fieldSet;
    public String responseId;

    /**
     * @description It is the constructor to populate the TerminalAndTotalAsset
     * @param capCustomerIds List of Cap Customer Ids
     * @param fieldSet Name of the FieldSet
     * @param responseId Record Id of customer
     */
    public TerminalAndTotalAsset(
      List<String> capCustomerIds,
      String fieldSet,
      String responseId
    ) {
      this.capCustomerIds = capCustomerIds;
      this.fieldSet = fieldSet;
      this.responseId = responseId;
    }

    /**
     * @description It is the constructor to populate the TerminalAndTotalAsset
     * @param capCustomerIds List of Cap Customer Ids
     * @param type It value is 'Both'
     * @param fieldSet Name of the FieldSet
     * @param responseId Record Id of customer
     */
    public TerminalAndTotalAsset(
      List<String> capCustomerIds,
      String type,
      String fieldSet,
      String responseId
    ) {
      this.capCustomerIds = capCustomerIds;
      this.type = type;
      this.fieldSet = fieldSet;
      this.responseId = responseId;
    }
  }

  /**
   * @author Naman Garg
   * @group CCRM (Commercial CRM)
   * @description FinSummaryResponse wrapper class to get the response published by mule.
   * @name FinSummaryResponse
   */
  public class FinSummaryResponse {
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
     * @description Hold the value of Terminal response published by mule
     */
    @AuraEnabled
    public Decimal totalMerchantTerminals { get; set; }
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
     * @description Tells if the Terminal value exist in cache
     */
    @AuraEnabled
    public String terminalAck { get; set; }
    /**
     * @description Tells if the Asset Finance Balance value exist in cache
     */
    @AuraEnabled
    public String assetBalanceAck { get; set; }
  }

  /**
   * @author Naman Garg
   * @group CCRM (Commercial CRM)
   * @description CacheData wrapper class to insert the data in cache.
   * @name CacheData
   */
  public class CacheData {
    public Decimal totalBalance;
    public Decimal totalMerchantTerminals;
    public Decimal totalAssetFinanceBalance;
    public String totalBalanceAck;
    public String terminalAck;
    public String assetBalanceAck;
    public String lastSummaryUpdateDate;

    /**
     * @description It is the constructor to populate the value in cache
     */
    public CacheData() {
      this.totalBalanceAck = CCRMConstants.NO_AVAILABLE_BALANCE;
      this.terminalAck = CCRMConstants.NO_AVAILABLE_BALANCE;
      this.assetBalanceAck = CCRMConstants.NO_AVAILABLE_BALANCE;
    }
  }

  /**
   * @author Naman Garg
   * @group CCRM (Commercial CRM)
   * @description FinSummaryCallout wrapper class to call the respective API
   * @name FinSummaryCallout
   */
  public class FinSummaryCallout {
    /**
     * @description Id of the Customer Record
     */
    @AuraEnabled
    public String responseId { get; set; }
    /**
     * @description True if we want to call Total Balance API
     */
    @AuraEnabled
    public Boolean callTotalCustBalanceApi { get; set; }
    /**
     * @description True if we want to call Terminal API
     */
    @AuraEnabled
    public Boolean callTerminalApi { get; set; }
    /**
     * @description True if we want to call Asset Finance Balance API
     */
    @AuraEnabled
    public Boolean callAssetFinanceBalanceApi { get; set; }
  }
}
