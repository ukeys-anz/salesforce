/**
 * @author : Naman Garg
 * @description : This class is the wrapper class of FinancialSummaryController
 * @since : Jan 2024
 */

public class FinancialSummaryWrapper {
  /**
   * @author Naman Garg
   * @group CCRM (Commercial CRM)
   * @description TotalBalance wrapper class to call Total Customer Balance API
   * @name TotalBalance
   */
  public class TotalBalance {
    Set<String> accounts = new Set<String>();
    String fieldSet;
    String responseId;

    /**
     * @description It is the constructor to populate the TotalBalance
     * @param accounts List of Account Ids
     * @param fieldSet Name of the FieldSet
     * @param responseId Record Id of customer
     */
    public TotalBalance(
      Set<String> accounts,
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
    List<String> capCustomerIds = new List<String>();
    String type;
    String fieldSet;
    String responseId;

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
   * @description TotalLimits wrapper class to call Total Limits Balance API
   * @name TotalBalance
   */
  public class TotalLimits {
    Set<String> accounts = new Set<String>();
    String fieldSet;
    String responseId;

    /**
     * @description It is the constructor to populate the Total Limits
     * @param accounts List of Account Ids
     * @param fieldSet Name of the FieldSet
     * @param responseId Record Id of customer
     */
    public TotalLimits(
      Set<String> accounts,
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
   * @description CacheData wrapper class to insert the data in cache.
   * @name CacheData
   */
  public class CacheData {
    public Decimal totalBalance;
    public Decimal totalAssetFinanceBalance;
    public String totalBalanceAck;
    public String assetBalanceAck;
    public String lastSummaryUpdateDate;
    public Decimal totalCreditBalance;
    public String totalCreditBalanceAck;
    public Decimal totalDebitBalance;
    public String totalDebitBalanceAck;
    public Decimal totalLimitValue;
    public String totalLimitAck;
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
     * @description True if we want to call Asset Finance Balance API
     */
    @AuraEnabled
    public Boolean callAssetFinanceBalanceApi { get; set; }
    /**
     * @description True if we want to call TotalCustomerLimit Balance API
     */
    @AuraEnabled
    public Boolean callTotalLimitsApi { get; set; }
  }

  /**
   * @author Naman Garg
   * @group CCRM (Commercial CRM)
   * @description CustomerIdWrapper wrapper class to get the cap Id List.
   * @name CustomerIdWrapper
   */
  public class CustomerIdWrapper {
    public List<String> capIdsList = new List<String>();
    public List<String> capIdsModifiedList = new List<String>();
  }
}
