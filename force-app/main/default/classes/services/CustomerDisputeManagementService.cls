/**
 * @author Shivam Swaraj, Nilesh
 * @since 01/2024
 * @description This is used to create or update the Customer Dispute Manangement record when a case is inserted or updated.
 */
public with sharing class CustomerDisputeManagementService {
  public static Integer disputeLimit = (Integer) Customer_Dispute_Management_Setting__mdt.getAll()
    .get('Dispute_Limit')
    .Dispute_Limit__c;

  /**
   * @description check whether the Customer Dispute Management related to Account or not and then create the Customer Dispute Management Record to link with Customer
   * @param newCaseRecords  Case records from trigger on insert
   * @param  oldCaseRecords  Map<Id, Case> oldMap for after update
   */
  public static void handleCustomerDisputeManagementActions(
    List<Case> newCaseRecords,
    Map<Id, Case> oldCaseRecords
  ) {
    try {
      Set<Id> customerIds = filterCasesAndReturnUniqueCustomerIds(
        newCaseRecords,
        oldCaseRecords
      );

      //Added to stop further processing if no unique customer records found
      if (customerIds.isEmpty()) {
        return;
      }

      List<Account> masterAccountList = queryCustomer(customerIds);

      List<Database.UpsertResult> cdmRecordsUpsertedResult = upsertCDMRecordsAndReturnUpsertedList(
        masterAccountList
      );

      //Added to fetch the Account list in which CDM record does not exist
      List<Account> accountsToBeUpdated = getAccountsWithMissingCDM(
        masterAccountList,
        cdmRecordsUpsertedResult
      );

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
  @TestVisible
  private static Set<Id> filterCasesAndReturnUniqueCustomerIds(
    List<Case> newCaseRecords,
    Map<Id, Case> oldCaseRecords
  ) {
    Set<Id> customerIds = new Set<Id>();
    for (Case caseRecord : newCaseRecords) {
      if (
        !CheckCaseRecordType.isDispute(caseRecord) &&
        !GetHelpConstants.SELF_SERVICE_ORIGIN.contains(caseRecord.Origin)
      ) {
        continue;
      }
      if (
        (oldCaseRecords.isEmpty()) ||
        (!oldCaseRecords.isEmpty() &&
        caseRecord.IsClosed != oldCaseRecords.get(caseRecord.Id).IsClosed)
      ) {
        customerIds.add(caseRecord.AccountId);
      }
    }

    return customerIds;
  }

  /**
   * @description To query all the customers details including number of active cases and cdm record details if exist
   * @param customerIds set of customer Ids
   * @return List<Account> list of customer with all the related details
   */
  @TestVisible
  private static List<Account> queryCustomer(Set<Id> customerIds) {
    //Query Customer to find number of active cases and CDM record exist
    return [
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

  /**
   * @description upsert CDM records and prepare the upserted result list.
   * @param masterAccountList master list of customers with all the related detail
   * @return List<Database.UpsertResult>  cdm records upserted result
   */
  @TestVisible
  private static List<Database.UpsertResult> upsertCDMRecordsAndReturnUpsertedList(
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
  @TestVisible
  private static Customer_Dispute_Management__c setCdmBlockFlags(
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
  @TestVisible
  private static List<Account> getAccountsWithMissingCDM(
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
   * @description This method is called from before insert of the case and will restrict the case creation if the dispute limit reached.
   * @param newCaseRecords list of new cases to be created.
   */
  public static void restrictDisputeCreationIfLimitReached(List<Case> newCaseRecords){ 
    Set<Id> accountIdsFromCase = getRelatedAccountsFromCase(newCaseRecords);

    if(accountIdsFromCase.isEmpty()){
      return;
    }

    List<Account> accountWithCDMDetails = queryCustomer(accountIdsFromCase);
      
    Map<Id,Account> accountCDMMap = createAccountMapWithCDMDetails(accountWithCDMDetails);
	
    setErrorIfRateLimitReached(newCaseRecords,accountCDMMap);
    
  }

  /**
   * @description This method will create a set of AccountID associated with Cases.
   * @param newCaseRecords List of Cases from Trigger
   * @return accountIdsFromCase Set<Id> of the Accounts associated to Cases.
   */
  @TestVisible
  private static Set<Id> getRelatedAccountsFromCase(List<Case> newCaseRecords ){
    Set<Id> accountIdsFromCase = new Set<Id>(); 
    for (Case caseRecord : newCaseRecords) {
      if (
        !(caseRecord.AccountId != null &&
        CheckCaseRecordType.isDispute(caseRecord) &&
        GetHelpConstants.SELF_SERVICE_ORIGIN.contains(caseRecord.Origin))
      ) {
        continue;
      }
      accountIdsFromCase.add(caseRecord.AccountId);
    }
    return accountIdsFromCase;
  }

  /**
   * @description This method will create a map of AccountID and Account record with CDM data.
   * @param accountWithCDMDetails List of Account with their CDM Details If Exist.
   * @return accountCDMMap Map of AccountId and Account record with CDM data.
   */
  @TestVisible
  private static Map<Id,Account>  createAccountMapWithCDMDetails( List<Account> accountWithCDMDetails){
    Map<Id,Account> accountCDMMap = new Map<Id,Account>(accountWithCDMDetails);
    return accountCDMMap;
  }

  /**
   * @description This method will add error to the case if Rate Limit Reached.
   * @param newCaseRecords List of Cases to be inserted.
   * @param accountCDMMap Map of ID and Account record with their CDM Details If Exist.
   */
  @TestVisible
  private static void setErrorIfRateLimitReached(List<Case> newCaseRecords, Map<Id,Account> accountCDMMap){

    for (Case caseRecord : newCaseRecords) {
      if(accountCDMMap.containsKey(caseRecord.AccountId) && hasRateLimitReached(accountCDMMap.get(caseRecord.AccountId)))
      {
        caseRecord.addError(Label.CdmLimitReachedErrorMessage);
      } 
    }  

  }
    
  /**
   * @description This method will return boolean if Rate Limit Reached or Permanently Blocked for the Customer to create dispute cases.
   * @param accountWithCDMDetail Account with their CDM Details If Exist.
   * @return boolean value to identify if rete limit reached.
   */
  @TestVisible
  private static Boolean hasRateLimitReached(Account accountWithCDMDetail ){
    Boolean permanentChecked = accountWithCDMDetail.Customer_Dispute_Management__r.Permanent_Block__c;
    Boolean tempChecked = accountWithCDMDetail.Customer_Dispute_Management__r.Temporary_Block__c;
    Boolean tempOveriddenChecked = accountWithCDMDetail.Customer_Dispute_Management__r.Temporary_Block_Overridden__c;

    return (permanentChecked) || (tempChecked && !tempOveriddenChecked) ?? false ;
  }
  
  /**
   * @description private without sharing class to bypass account sharing setting to link CDM with Account in System mode
   */
  @TestVisible
  private without sharing class UpdateAccountsToLinkCDM {
    /**
     * @description update account records to link CDM record which does not have existing CDM record
     * @param customerToUpdateList A list of account for which newly created CDM record needs to link
     */
    @TestVisible
    private void updateAccountsMissingCDM(List<Account> customerToUpdateList) {
      DMLUtil.updateRecords(customerToUpdateList, false, false);
    }
  }
}
