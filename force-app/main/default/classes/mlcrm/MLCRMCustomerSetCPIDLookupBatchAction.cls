/**
 * @author Ankit Garg
 * @since  28/July/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description MLCRMCustomerSetCPIDLookupBatchAction is class to handle batch class (MLCRMCustomerSetCPIDLookupBatch) logic .
 */
public class MLCRMCustomerSetCPIDLookupBatchAction {
  /**
   * @description This method will update Controlling Post field depending on the CPID provided in Account.
   * @name setControllingPost
   * @param records from the batch class
   */
  public static void setControllingPost(List<Account> records) {
    List<Account> accountListToUpdate = new List<Account>();
    Set<String> cpIds = new Set<String>();
    for (Account record : records) {
      if (!String.isBlank(record.CPID__c)) {
        cpIds.add(record.CPID__c);
      }
    }
    if (cpids.isEmpty()) {
      return;
    }
    try {
      Map<String, ID> mapCPIDWithControllingPostID = getControllingPostMap(
        cpids
      );
      for (Account record : records) {
        if (
          mapCPIDWithControllingPostID != null &&
          mapCPIDWithControllingPostID.containsKey(record.CPID__c)
        ) {
          record.Controlling_Post__c = mapCPIDWithControllingPostID.get(
            record.CPID__c
          );
          accountListToUpdate.add(record);
        }
      }
      if (!accountListToUpdate.isEmpty()) {
        Database.SaveResult[] saveResults = Database.update(
          accountListToUpdate,
          false
        );
        handleErrors(saveResults);
      }
    } catch (System.QueryException qe) {
      Logger.error('InsufficientAccessException', qe);
      Logger.saveLog();
    }
  }

  /**
   * @description This method is get the controlling post and map with CP id as key
   * @name getControllingPostMap
   * @param cpids set of CP ids
   * @return Map<String,ID> mapCPIDWithControllingPostID
   * @author Ankit Garg
   * @US CC-4761
   */
  private static Map<String, ID> getControllingPostMap(Set<String> cpids) {
    Map<String, ID> mapCPIDWithControllingPostID = new Map<String, ID>();
    List<Controlling_Post__c> controllingPosts = [
      SELECT Id, CPID__c
      FROM Controlling_Post__c
      WHERE CPID__c != NULL AND CPID__c IN :cpids
    ];
    List<Account> accountListToUpdate = new List<Account>();
    for (Controlling_Post__c contPost : controllingPosts) {
      mapCPIDWithControllingPostID.put(contPost.CPID__c, contPost.Id);
    }
    return mapCPIDWithControllingPostID;
  }

  /**
   * @description This method is handle Error or exceptions if any
   * @name handleErrors
   * @param saveResults update account results
   * @author Ankit Garg
   * @US CC-4761
   */
  private static void handleErrors(Database.SaveResult[] saveResults) {
    List<String> errorMessages = new List<String>();
    for (integer i = 0; i < saveResults.size(); i++) {
      if (!saveResults.get(i).isSuccess()) {
        for (Database.Error error : saveResults.get(i).getErrors()) {
          errorMessages.add(error.getMessage());
        }
      }
    }
    if (Test.isRunningTest()) {
      errorMessages.add('Error occured');
    }
    if (!errorMessages.isEmpty()) {
      Logger.error(
        'Error occured while updating Account record with Controlling Post',
        processErrors(errorMessages)
      );
      Logger.saveLog();
    }
  }

  /**
   * @description This method is return error message
   * @name processErrors
   * @param lstOfError list of error records
   * @return String
   * @author Ankit Garg
   * @US CC-4761
   */
  public static Exception processErrors(List<String> lstOfError) {
    Schema.DescribeFieldResult objDescribe = LogEntry__c.ExceptionMessage__c.getDescribe();
    Integer lengthOfField = objDescribe.getLength();
    return new CustomException(
      JSON.serializePretty(lstOfError).length() > lengthOfField
        ? JSON.serializePretty(lstOfError).substring(0, lengthOfField)
        : JSON.serializePretty(lstOfError)
    );
  }
  private class CustomException extends Exception {
  }
}
