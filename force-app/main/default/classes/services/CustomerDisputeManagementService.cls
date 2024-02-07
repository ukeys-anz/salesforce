/**
 * @author Shivam Swaraj, Nilesh
 * @since 01/2024
 * @description This is used to create or update the Customer Dispute Manangement record when a case is inserted or updated.
 */
public with sharing class CustomerDisputeManagementService {
public static Integer disputeLimit;
  static {
     disputeLimit  = (Integer)Max_Open_Self_Service_Dispute__mdt.getAll().get('Dispute_Limit').Dispute_Limit__c;
  }
    /**
   * @description check whether the Customer Dispute Management exist or not and then create the Customer Dispute Management Record
   * @param caseRecords Case records from trigger
   * @param  oldMap  Map<Id, Case> oldMap for after update
   */
    public static void validateCustomerDisputeManagement(List<Case> caseRecords,  Map<Id, Case> oldMap) {
        Set<String> customerIds = new Set<String>();
        for (Case caseRecord : caseRecords) {
            if(CheckCaseRecordType.isDispute(caseRecord) && caseRecord.Origin == GetHelpConstants.SELF_SERVICE_ORIGIN)
            {
                //Do the transaction only when the status is changed in after update of the case
                if ((Trigger.isAfter && Trigger.isUpdate) && caseRecord.IsClosed != oldMap.get(caseRecord.Id).IsClosed) 
                {
                    customerIds.add(caseRecord.AccountId);
                }
                //Handle after insert of the Self Service Dispute cases
                else if(Trigger.isAfter && Trigger.isInsert)
                {
                    customerIds.add(caseRecord.AccountId);
                } 
            }
        }

        //Added to end early if no customer ids available for processing
        if(customerIds.isEmpty())
        {
           return;
        }

        //Added to check if CustomerDisputeManagement Exist or Not
        prepareListOfCdmAndAccountsForUpsertion(customerIds);
    }

    /**
   * @description check whether a Customer Dispute Management Record Exist and If Not Create a record and update the customer
   * @param customerIds Case records from trigger
   */
    private static void prepareListOfCdmAndAccountsForUpsertion( Set<String> customerIds)
    {
        List<Account> listOfCustomersToLinkWithCdm = new List<Account>();
        List<Customer_Dispute_Management__c> listOfCdmToInsertOrUpdate = new List<Customer_Dispute_Management__c>();
        List<Database.UpsertResult> cdmUpsertResult = new List<Database.UpsertResult>();
        List<Account> customerList = new List<Account>();

        //Check whether the running user can query the below objects
        if(!PermissionUtils.canQuery('Case') &&
        !PermissionUtils.canQuery('Account') &&
        !PermissionUtils.canQuery('Customer_Dispute_Management__c'))
        {
            return ;
        }

        //Query Customer to find number of active cases and CDM record exist 
        customerList = [SELECT Id, Customer_Dispute_Management__c,Customer_Dispute_Management__r.Id, Customer_Dispute_Management__r.Temporary_Block__c,
        (Select Id from Cases WHERE IsClosed =false AND Origin=:GetHelpConstants.SELF_SERVICE_ORIGIN AND RecordTypeId IN :CheckCaseRecordType.DISPUTE_RT_IDS LIMIT :disputeLimit)
         FROM Account where Id IN :customerIds];

        for(Account customer:customerList)
        {
            Integer activeCaseCount=customer.Cases.size();
            if(String.isNotBlank(customer.Customer_Dispute_Management__c))
            {
                Customer_Dispute_Management__c cdmRecordToUpdate = setCdmBlockFlags(activeCaseCount,customer.Customer_Dispute_Management__r);
                listOfCdmToInsertOrUpdate.add(cdmRecordToUpdate);
            }
            else
            {
                // Prepare a CDM records list for Insertion of CDM and update of Accounts
                Customer_Dispute_Management__c cdmRecord = new Customer_Dispute_Management__c();
                Customer_Dispute_Management__c cdmRecordToInsert = setCdmBlockFlags(activeCaseCount,cdmRecord);
                listOfCdmToInsertOrUpdate.add(cdmRecordToInsert);
                listOfCustomersToLinkWithCdm.add(customer);
            }
        }
        //Create or Update Customer Dispute Management 
        if(!listOfCdmToInsertOrUpdate.isEmpty())
        {
            cdmUpsertResult = DMLUtil.upsertRecords(listOfCdmToInsertOrUpdate, false, false);
        }
        //Update account record in order to link newly created CDM record 
        updateAccountRecordsMissingCdm(cdmUpsertResult,customerList,listOfCustomersToLinkWithCdm);
  }

  /**
   * @description To set values of flags of CDM record based on the Active Case Count
   * @param activeCaseCount active case count 
   * @param cdmRecordToInsertOrUpdate cdm record for insertion and updation before changes
   * @return cdmRecordToInsertOrUpdate cdm record for insertion and updation after changes
   */
  public static Customer_Dispute_Management__c setCdmBlockFlags(Integer activeCaseCount, Customer_Dispute_Management__c cdmRecordToInsertOrUpdate)
  {
    cdmRecordToInsertOrUpdate.Temporary_Block__c = activeCaseCount >= disputeLimit;
    if(activeCaseCount < disputeLimit)
    {
        cdmRecordToInsertOrUpdate.Temporary_Block_Overridden__c = false;
    }
    return cdmRecordToInsertOrUpdate;
  }

  /**
   * @description To link newly create CDM record with Account, needs to update account record 
   * @param cdmUpsertResult result list from upsertion of CDM records
   * @param customerList master customer list related to cases
   * @param listOfCustomersToLinkWithCdm list of customer records for which newly created CDM record needs to be linked 
   */
  public static void updateAccountRecordsMissingCdm(List<Database.UpsertResult> cdmUpsertResult,List<Account> customerList, List<Account> listOfCustomersToLinkWithCdm)
  {
    List<Account> customerToUpdateList = new List<Account>();
    for (Integer intUpsertCount = 0;intUpsertCount < cdmUpsertResult.size();intUpsertCount++) 
    {
        Database.UpsertResult cdmRecordUpserted = cdmUpsertResult.get(
            intUpsertCount
        );
        if (cdmRecordUpserted.isSuccess() && cdmRecordUpserted.isCreated() && listOfCustomersToLinkWithCdm.contains(customerList[intUpsertCount])) {
            customerList[intUpsertCount].Customer_Dispute_Management__c = cdmRecordUpserted.getId();
            customerToUpdateList.add(customerList[intUpsertCount]);
        }
    }

    if(customerToUpdateList.isEmpty())
    {
       return;
    }

    new UpdateAccountsToLinkCDM().updateAccountsMissingCDM(customerToUpdateList);
  }

/**
 * @description private without sharing class to bypass account sharing setting to link CDM with Account in System mode
 */
  private without sharing class UpdateAccountsToLinkCDM
  {
    /**
     * @description update account records to link CDM record which does not have existing CDM record
     * @param customerToUpdateList A list of account for which newly created CDM record needs to link
     */
    private void updateAccountsMissingCDM(List<Account> customerToUpdateList)
    {
        DMLUtil.updateRecords(customerToUpdateList, false, false);
    }
  }
}