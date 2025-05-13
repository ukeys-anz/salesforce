/**
 * @since 03/2025
 * @description This class provides SOQL helpers for class related GetCustomerInformation.
 * @runTests GetCustomerInformationTest
 */
public with sharing class GetCustomerInformationRepo {
   /**
   * @description REPO to Fetch Financial Accounts Releated to the Customer
   * @param accId ID of the Customer
   * @param ocvId ocvId of the Customer
   * @return List<FinServ__FinancialAccount__c> return the list of Financial Accounts
   */
    
     public List<FinServ__FinancialAccount__c> getFinancialAccounts(String accId,String ocvId) {
          String query ='SELECT Id, Account_Key__c , FinServ__FinancialAccountType__c FROM FinServ__FinancialAccount__c WHERE ';
         if(String.isBlank(accId)){
             return new List<FinServ__FinancialAccount__c>();
         }
          query +=  (!String.isBlank(ocvId)) ?  ' FinServ__PrimaryOwner__r.OCV_ID__c =: OcvId' : ' FinServ__PrimaryOwner__c =: accId';
         
        return Database.query(query);
                 
    }
 
}