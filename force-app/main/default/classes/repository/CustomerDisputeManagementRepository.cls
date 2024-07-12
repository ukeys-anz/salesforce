/**
 * @author Shivam Swaraj
 * @since Mon July 8 2024
 * @description Provides SOQL and DML helpers for CustomerDisputeManagementService
 */
public with sharing class CustomerDisputeManagementRepository {
    /**
     * @description To query all the customers details including number of active cases and cdm record details if exist
     * @param customerIds set of customer Ids
     * @param disputeLimit maximum limit of dispute cases allowed to create
     * @return List<Account> list of customer with all the related details
     */
    public List<Account> queryCustomer(Set<Id> customerIds, Integer disputeLimit) {

        List<Account> customersWithCdmAndCaseDetails = new List<Account>();
        if (
            PermissionUtils.canQuery('Case') &&
            PermissionUtils.canQuery('Customer_Dispute_Management__c') &&
            PermissionUtils.canQuery('Account') &&
            !customerIds.isEmpty()
          )
        {
        //Query Customer to find number of active cases and CDM record exist
        customersWithCdmAndCaseDetails = [
            SELECT
                Id,
                Customer_Dispute_Management__c,
                Customer_Dispute_Management__r.Id,
                Customer_Dispute_Management__r.Temporary_Block__c,
                Customer_Dispute_Management__r.Permanent_Block__c,
                Customer_Dispute_Management__r.Temporary_Block_Overridden__c,
                (
                SELECT Id
                FROM Cases
                WHERE
                    IsClosed = FALSE
                    AND Origin IN :GetHelpConstants.SELF_SERVICE_ORIGIN
                    AND RecordTypeId IN :CheckCaseRecordType.DISPUTE_RT_IDS
                LIMIT :disputeLimit
                )
            FROM Account
            WHERE Id IN :customerIds
            ];
        }
        return customersWithCdmAndCaseDetails;
        
    }
}