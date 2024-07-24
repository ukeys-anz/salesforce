/**
 * @author Shivam Swaraj
 * @since Mon July 24 2024
 * @description Provides SOQL and DML helpers for HomeLoanController, FinancialAccountController
 */
public with sharing class FinancialAccountRepository {

    //Financial Account Role Types To Include for showing owner names on financial account record page
    private static final Set<String> FINSERV_ROLE_TYPES = new Set<String>{
    'Additional Owner',
    'Primary Owner'
    };
   /**
   * @description return the id(s) of the financial account owners
   * @param financialAccountId financial account record id
   * @return list of FAR which are Primary or Additional role type
   */
    public List<FinServ__FinancialAccountRole__c> getAccountOwnerDetails(Id financialAccountId) {
    
    //Check if can query financial account role
    PermissionUtils.canQuery('FinServ__FinancialAccountRole__c');

    return [
      SELECT Id, FinServ__RelatedAccount__c, FinServ__RelatedAccount__r.Name
      FROM FinServ__FinancialAccountRole__c
      WHERE
        FinServ__FinancialAccount__c = :financialAccountId
        AND FinServ__Active__c = TRUE
        AND FinServ__Role__c IN :FINSERV_ROLE_TYPES
    ];
    }
}