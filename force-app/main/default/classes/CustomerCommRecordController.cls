/**
 * @author Sneha Malik
 * @since 20 Oct 2023
 * @description CustomerCommRecordController. Helper class that gives tableau dashboard URL based on customer's ocv ID.
 */

@SuppressWarnings('PMD.ApexSuggestUsingNamedCred, PMD.CyclomaticComplexity')
public with sharing class CustomerCommRecordController {
  /**
   * @description The CustomerCommRecord aura component uses this to construct the dynamic tableau URL.
   * @param recordId Record Id of the Account/customer.
   * @return String customerCommURL : dynamic tableau url.
   */
  @AuraEnabled
  public static string getCustomerCommUrl(Id recordId) {
    String customerCommURL = null;
    if (PermissionUtils.canQuery('Account') == true) {
      Account accRecord = [
        SELECT Id, OCV_ID__c
        FROM Account
        WHERE Id = :recordId
      ];
      customerCommURL = Label.ANZX_Customer_Comm_Url + accRecord.OCV_ID__c;
    }
    return customerCommURL;
  }
}
