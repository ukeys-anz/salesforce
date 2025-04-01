/**
 * @since 03/2025
 * @description This class provides SOQL helpers for class related GetCustomerInformation.
 * @runTests GetCustomerInformationTest
 */
public with sharing class GetCustomerInformationRepo {
   /**
   * @description REPO to Fetch Financial Accounts Releated to the Customer
   * @param accId ID of the Customer
   * @return List<FinServ__FinancialAccount__c> return the list of Financial Accounts
   */
    
     public List<FinServ__FinancialAccount__c> getFinancialAccounts(String accId) {
         if(String.isBlank(accId)){
             return new List<FinServ__FinancialAccount__c>();
         }
        return [SELECT Id,Account_Key__c ,FinServ__FinancialAccountType__c  FROM FinServ__FinancialAccount__c WHERE FinServ__PrimaryOwner__c =: accId];
        
    }
 
}