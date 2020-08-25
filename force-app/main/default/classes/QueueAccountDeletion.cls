/**
 * @author Boobalakrishnan Duraisamy
 * @since 08/2020
 * @description Queueable apex class to delete Account and their related records asynchronously
 */
public class QueueAccountDeletion implements Queueable {
  Account accountToDelete = new Account();

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
    //delete releted case records
    List<Case> deleteCaseList = getRelatedRecordIds(
      accountToDelete.Id,
      'Case',
      'AccountId'
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

    //finally delete the account record only if all the related records are deleted successfully.
    if (log.log.isEmpty()) {
      Database.DeleteResult result = Database.delete(accountToDelete, false);
      if (!result.isSuccess()) {
        logError('Account', result);
      }
    }

    log.insertLog();
  }

  /**
   * @description Generic method to query and get related records id's dynamically
   * @param recordId Salesforce record Id
   * @param objectAPIName object API Name
   * @param fieldAPIName field API Name
   * @return List<SObject> returns list of Sobject with related record id's
   */
  private static List<SObject> getRelatedRecordIds(
    String recordId,
    String objectAPIName,
    String fieldAPIName
  ) {
    List<SObject> relatedRecordIds = new List<SObject>();

    String query =
      'SELECT Id FROM ' +
      objectAPIName +
      ' WHERE ' +
      fieldAPIName +
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
}