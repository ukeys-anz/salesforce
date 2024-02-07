/**
 * @author Shivam Swaraj, Nilesh
 * @since 01/2024
 * @description This is used to create or update the Customer Dispute Manangement record when a case is inserted or updated.
 */
public with sharing class CustomerDisputeManagementService {
  public static Integer disputeLimit = (Integer) Max_Open_Self_Service_Dispute__mdt.getAll()
    .get('Dispute_Limit')
    .Dispute_Limit__c;

  /**
   * @description check whether the Customer Dispute Management related to Account or not and then create the Customer Dispute Management Record to link with Customer
   * @param newCaseRecords  Case records from trigger
   * @param  oldCaseRecords  Map<Id, Case> oldMap for after update
   */
  public static void handleCustomerDisputeManagementActions(
    List<Case> newCaseRecords,
    Map<Id, Case> oldCaseRecords
  ) {
    try {
      //Added to filter out Cases to process and return Unique Customer Ids
      Set<Id> customerIds = filterCasesAndReturnUniqueCustomerIds(
        newCaseRecords,
        oldCaseRecords
      );

      //Added to stop further processing if no unique customer records found
      if (customerIds.isEmpty()) {
        return;
      }

      //Query the Customers and it's related Customer Dispute Management record details and active Self Service Dispute Cases
      List<Account> masterAccountList = queryCustomer(customerIds);

      //Added to upsert CDM records and fetch the upserted result
      List<Database.UpsertResult> cdmRecordsUpsertedResult = fetchCDMRecordsUpsertedList(
        masterAccountList
      );

      //Added to fetch the Account list in which CDM record does not exist
      List<Account> accountsToBeUpdated = updateAccountsWithMissingCDM(
        masterAccountList,
        cdmRecordsUpsertedResult
      );

      //Return if no updation of Account needed
      if (accountsToBeUpdated.isEmpty()) {
        return;
      }

      //Added to update Accounts to link CDM if does not exist
      new UpdateAccountsToLinkCDM()
        .updateAccountsMissingCDM(accountsToBeUpdated);
    } catch (Exception objException) {
      Logger.error(
        'Error in Customer Dispute Management Service ',
        objException
      );
      Logger.saveLog();
    }
  }

  /**
   * @description To filter out the cases to processs and return related customer ids set.
   * @param newCaseRecords List of cases inserted
   * @param oldCaseRecords Map of cases updated
   * @return customerIds Set of Customer Ids to process
   */
  private static Set<Id> filterCasesAndReturnUniqueCustomerIds(
    List<Case> newCaseRecords,
    Map<Id, Case> oldCaseRecords
  ) {
    Set<Id> customerIds = new Set<Id>();
    for (Case caseRecord : newCaseRecords) {
      if (
        CheckCaseRecordType.isDispute(caseRecord) &&
        GetHelpConstants.SELF_SERVICE_ORIGIN.contains(caseRecord.Origin)
      ) {
        if (
          (Trigger.isAfter && Trigger.isUpdate) &&
          caseRecord.IsClosed != oldCaseRecords.get(caseRecord.Id).IsClosed
        ) {
          //Do the transaction only when the status is changed in after update of the case
          customerIds.add(caseRecord.AccountId);
        } else if (Trigger.isAfter && Trigger.isInsert) {
          //Handle after insert of the Self Service Dispute cases
          customerIds.add(caseRecord.AccountId);
        }
      }
    }

    return customerIds;
  }

  /**
   * @description To query all the customers details including number of active cases and cdm record details if exist
   * @param customerIds set of customer Ids
   * @return List<Account> list of customer with all the related details
   */
  private static List<Account> queryCustomer(Set<Id> customerIds) {
    PermissionUtils.canQueryAllObjects(
      new List<String>{ 'Case', 'Account', 'Customer_Dispute_Management__c' }
    );
    //Query Customer to find number of active cases and CDM record exist
    return [
      SELECT
        Id,
        Customer_Dispute_Management__c,
        Customer_Dispute_Management__r.Id,
        Customer_Dispute_Management__r.Temporary_Block__c,
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

  /**
   * @description upsert CDM records and prepare the upserted result list.
   * @param masterAccountList master list of customers with all the related detail
   * @return List<Database.UpsertResult>  cdm records upserted result
   */
  private static List<Database.UpsertResult> fetchCDMRecordsUpsertedList(
    List<Account> masterAccountList
  ) {
    List<Customer_Dispute_Management__c> cdmRecordsToBeUpserted = new List<Customer_Dispute_Management__c>();

    for (Account customer : masterAccountList) {
      Integer activeCaseCount = customer.Cases.size();
      if (String.isNotBlank(customer.Customer_Dispute_Management__c)) {
        Customer_Dispute_Management__c cdmRecordToUpdate = setCdmBlockFlags(
          activeCaseCount,
          customer.Customer_Dispute_Management__r
        );
        cdmRecordsToBeUpserted.add(cdmRecordToUpdate);
      } else {
        // Prepare a CDM records list for Insertion and set the flags values based on Active Self Service Dispute cases count.
        Customer_Dispute_Management__c cdmRecordToInsert = setCdmBlockFlags(
          activeCaseCount,
          null
        );
        cdmRecordsToBeUpserted.add(cdmRecordToInsert);
      }
    }
    return DMLUtil.upsertRecords(cdmRecordsToBeUpserted, false, false);
  }

  /**
   * @description To set values of flags of CDM record based on the Active Case Count
   * @param activeCaseCount active case count
   * @param cdmRecordToInsertOrUpdate cdm record for insertion and updation before changes
   * @return cdmRecordToInsertOrUpdate cdm record for insertion and updation after changes
   */
  public static Customer_Dispute_Management__c setCdmBlockFlags(
    Integer activeCaseCount,
    Customer_Dispute_Management__c cdmRecordToInsertOrUpdate
  ) {
    if (cdmRecordToInsertOrUpdate == null) {
      cdmRecordToInsertOrUpdate = new Customer_Dispute_Management__c();
    }
    cdmRecordToInsertOrUpdate.Temporary_Block__c =
      activeCaseCount >= disputeLimit;
    if (activeCaseCount < disputeLimit) {
      cdmRecordToInsertOrUpdate.Temporary_Block_Overridden__c = false;
    }
    return cdmRecordToInsertOrUpdate;
  }

  /**
   * @description This method will update the Account to link the newly created CDM record if it does not exist.
   * @param masterAccountList Master Customer list for which processing will happen.
   * @param cdmRecordsUpsertedResult <Database.UpsertResult> of CDM Records upserted
   * @return accountToBeUpdated list of account to be update to link CDM
   */
  private static List<Account> updateAccountsWithMissingCDM(
    List<Account> masterAccountList,
    List<Database.UpsertResult> cdmRecordsUpsertedResult
  ) {
    List<Account> accountToBeUpdated = new List<Account>();
    for (Integer i = 0; i < cdmRecordsUpsertedResult.size(); i++) {
      Database.UpsertResult eachUpsertResult = cdmRecordsUpsertedResult[i];
      if (eachUpsertResult.isCreated()) {
        accountToBeUpdated.add(
          new Account(
            Id = masterAccountList[i].Id,
            Customer_Dispute_Management__c = eachUpsertResult.getId()
          )
        );
      }
    }
    return accountToBeUpdated;
  }

  /**
   * @description private without sharing class to bypass account sharing setting to link CDM with Account in System mode
   */
  private without sharing class UpdateAccountsToLinkCDM {
    /**
     * @description update account records to link CDM record which does not have existing CDM record
     * @param customerToUpdateList A list of account for which newly created CDM record needs to link
     */
    private void updateAccountsMissingCDM(List<Account> customerToUpdateList) {
      DMLUtil.updateRecords(customerToUpdateList, false, false);
    }
  }
}
