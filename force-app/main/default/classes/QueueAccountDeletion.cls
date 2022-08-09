/**
 * @author Boobalakrishnan Duraisamy
 * @since 08/2020
 * @description Queueable apex class to delete Account and their related records asynchronously
 */
public with sharing class QueueAccountDeletion implements Queueable {
  Account accountToDelete;

  //call application log function to log results incase of failure
  lib_systemLog log = new lib_systemLog(
    QueueAccountDeletion.class.getName(),
    'execute'
  );

  /**
   * @description Constructor
   * @param accountFromTrigger account record passed from trigger
   */
  public QueueAccountDeletion(Account accountFromTrigger) {
    accountToDelete = accountFromTrigger;
  }

  /**
   * @description execute method
   * @param context QueueableContext
   */
  public void execute(QueueableContext context) {
    // We want to delete accounts only after all related records were successfully deleted,
    // hence everything must be deletable for the current user
    if (
      !Case.sObjectType.getDescribe().isDeletable() ||
      !Entitlement.sObjectType.getDescribe().isDeletable() ||
      !Account.sObjectType.getDescribe().isDeletable()
    ) {
      Lib_SystemLog.createSingleLog(
        QueueAccountDeletion.class.getName(),
        'execute',
        '',
        'Must be deletable: Case, Entitlement, Account.',
        Lib_SystemLog.Severity.ERROR
      );
      new QueueAccountDeletionException(
        'Must be deletable: Case, Entitlement, Account.'
      );
    }

    //delete related case records
    List<Case> deleteCaseList = getRelatedRecordIds(
      accountToDelete.Id,
      Case.SobjectType,
      Case.AccountId.getDescribe().getSObjectField()
    );

    if (!deleteCaseList.isEmpty()) {
      List<Database.DeleteResult> results = Database.delete(
        deleteCaseList,
        false
      );
      for (Database.DeleteResult dr : results) {
        if (!dr.isSuccess()) {
          logError('Case', dr);
        }
      }
    }

    //delete related entitlement records
    List<Entitlement> deleteEntitlementList = getRelatedRecordIds(
      accountToDelete.Id,
      Entitlement.SobjectType,
      Entitlement.AccountId.getDescribe().getSObjectField()
    );

    if (!deleteEntitlementList.isEmpty()) {
      List<Database.DeleteResult> results = Database.delete(
        deleteEntitlementList,
        false
      );
      for (Database.DeleteResult dr : results) {
        if (!dr.isSuccess()) {
          logError('Entitlement', dr);
        }
      }
    }

    //finally delete the account record only if all the related records are deleted successfully.
    if (log.logList.isEmpty()) {
      Database.DeleteResult result = Database.delete(accountToDelete, false);
      if (!result.isSuccess()) {
        logError('Account', result);
      }
    }

    log.insertLogAsync();
  }

  /**
   * @description Generic method to query and get related records id's dynamically
   * @param recordId Salesforce record Id
   * @param objectAPIType object API Name
   * @param field API Name
   * @return List<SObject> returns list of Sobject with related record id's
   */
  private static List<SObject> getRelatedRecordIds(
    String recordId,
    SObjectType objectAPIType,
    SObjectField field
  ) {
    List<SObject> relatedRecordIds = new List<SObject>();

    String query =
      'SELECT Id FROM ' +
      objectAPIType +
      ' WHERE ' +
      field +
      '= :recordId';
    relatedRecordIds = Database.query(query);

    return relatedRecordIds;
  }

  /**
   * @description Generic method to log delete failures in Lib_SystemLog.addObjectMessage
   * @param objectAPIName object API Name
   * @param deleteResult Database.DeleteResult
   */
  private void logError(
    String objectAPIName,
    Database.DeleteResult deleteResult
  ) {
    for (Database.Error err : deleteResult.getErrors()) {
      String errNo = String.valueof(err.getStatusCode());
      log.addObjectMessage(
        objectAPIName,
        deleteResult.Id,
        errNo,
        'Id=' +
        deleteResult.Id +
        ',Message:' +
        err.getMessage() +
        'Fields:' +
        err.getFields(),
        lib_systemLog.Severity.ERROR
      );
    }
  }

  /**
   * @description extend the Exception class to allow errors to be thrown if the user does not have access
   */
  private class QueueAccountDeletionException extends Exception {
  }
}
