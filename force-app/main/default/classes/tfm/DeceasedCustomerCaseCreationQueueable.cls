/**
 * @author Shivraj Kadam
 * @since  08/2025
 * @description creates Cases for Deceased Customers when Display Name is updated to Executor on Account
 */
public class DeceasedCustomerCaseCreationQueueable implements Queueable {
  private static final String CASE_SUBJECT = 'Deceased Estate - Removal of Electronic Access';
  private static final String CASE_DESCRIPTION =
    'Notification of deceased customer received.' +
    '\nCase created for ID Ops Team to:' +
    '\n• Deregister Customer Device' +
    '\n• Apply App Pin Block' +
    '\n• Delete Web Banking Passkey';
  private static final String CASE_STATUS = 'Open';
  private static final String CASE_TYPE = 'Deceased Estate';
  private static final String CASE_SUB_TYPE = 'Removal of Electronic Access';
  private static final String CASE_PRIORITY = 'Critical';
  private static final String CASE_ORIGIN = 'Other';
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  public Map<Id, String> accountIdToCapCisIdMap;

  /**
   * @description onAfterInsert: After Insert actions.
   * @param records - ContentDocumentIds List to be deleted
   */
  public DeceasedCustomerCaseCreationQueueable(Map<Id, String> records) {
    accountIdToCapCisIdMap = records;
  }

  /**
   * @description onAfterUpdate: After update of Display Name to Executor on Account
   * @param context contex variable
   */
  public void execute(QueueableContext context) {
    List<Case> deceasedCasesToBeCreated = new List<Case>();
    for (Id accountId : accountIdToCapCisIdMap.keySet()) {
      Case caseRecord = new Case(
        Subject = CASE_SUBJECT,
        Description = CASE_DESCRIPTION,
        AccountId = accountId,
        Status = CASE_STATUS,
        Type = CASE_TYPE,
        Sub_Type__c = CASE_SUB_TYPE,
        Priority = CASE_PRIORITY,
        Auto_Created__c = true,
        Origin = CASE_ORIGIN,
        RecordTypeId = RTCase.generalInquiry,
        OwnerId = QueryQueue.get('ID_Ops_Queue').Id
      );
      deceasedCasesToBeCreated.add(caseRecord);
    }
    List<Database.SaveResult> results = DML_REPOSITORY.doInsert(
      deceasedCasesToBeCreated,
      new DmlConfig().allowPartial().systemMode()
    );

    errorLogging(deceasedCasesToBeCreated, results);
  }

  /**
   * @description error loggging for case creation failures
   * @param deceasedCasesToBeCreated cases to created
   * @param results SaveResult
   */
  public void errorLogging(
    List<Case> deceasedCasesToBeCreated,
    List<Database.SaveResult> results
  ) {
    List<Id> errorAccountsToUpdate = new List<Id>();
    List<Account> updateAccountsList = new List<Account>();
    for (Integer i = 0; i < deceasedCasesToBeCreated.size(); i++) {
      if (!results[i].isSuccess()) {
        Logger.error(
          'Error occurred while creating case for Deceased Customer having Account with CAP-CIS: ' +
            accountIdToCapCisIdMap.get(deceasedCasesToBeCreated[i].AccountId) +
            ' Account Id: ' +
            deceasedCasesToBeCreated[i].AccountId +
            ' Error_Message: ' +
            results[i].getErrors()[0].getMessage(),
          Logger.Severity.HIGH
        );
        errorAccountsToUpdate.add(deceasedCasesToBeCreated[i].AccountId);
      }
    }
    Logger.saveLog();

    for (Id accountId : errorAccountsToUpdate) {
      Account accountRecord = new Account(
        Id = accountId,
        DeceasedEstateStatus__c = 'Error'
      );
      updateAccountsList.add(accountRecord);
    }

    DML_REPOSITORY.doUpdate(updateAccountsList, new DmlConfig().allowPartial());
  }
}
