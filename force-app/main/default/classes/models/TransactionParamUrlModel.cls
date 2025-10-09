/**
 * @author Batya Aisman Sufrin
 * @since Aug 2025
 * @description Model for transaction parameters used in URL
 */
public with sharing class TransactionParamUrlModel {
  /**
   * @description The start date for the transaction query
   */
  @AuraEnabled
  public String startDate { get; set; }

  /**
   * @description The end date for the transaction query
   */
  @AuraEnabled
  public String endDate { get; set; }

  /**
   * @description The account number for the transaction query
   */
  @AuraEnabled
  public String accountNumber { get; set; }

  /**
   * @description The bucket IDs for the transaction query
   */
  @AuraEnabled
  public List<String> bucketIds { get; set; }

  /**
   * @description The page size for the transaction query
   */
  @AuraEnabled
  public String pageSize { get; set; }

  /**
   * @description Default constructor
   */
  public TransactionParamUrlModel() {
    this.bucketIds = new List<String>();
  }
}
