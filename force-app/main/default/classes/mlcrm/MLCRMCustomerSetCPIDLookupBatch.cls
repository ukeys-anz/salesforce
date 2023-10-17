/**
 * @author Ankit Garg
 * @since  28/July/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description MLCRMCustomerSetCPIDLookupBatch is batch class to populate Controlling Post Id based on CP Id on Account records.
 */
public class MLCRMCustomerSetCPIDLookupBatch implements Database.Batchable<sObject> {
  /**
   * @description This method is used to collect the data from Account.
   * @name start
   * @param objSchedule standard database batachable varaible
   * @return Database.QueryLocator locator object
   * @author Ankit Garg
   * @US CC-4761
   */
  public Database.QueryLocator start(Database.BatchableContext objSchedule) {
    String query = 'Select id, CPID__c, Controlling_Post__c FROM Account WHERE CPID__c <> \'\' and Controlling_Post__c = null';
    return Database.getQueryLocator(query);
  }

  /**
   * @description This method is used topopulate Controlling Post Id based on CP Id on Account records.
   * @name execute
   * @param objSchedule standard database batachable varaible
   * @param scope List of chunk records for which share records needs to be updated.
   * @author Ankit Garg
   * @US CC-4761
   */
  public void execute(
    Database.BatchableContext objSchedule,
    List<Account> scope
  ) {
    if (!scope.isEmpty()) {
      MLCRMCustomerSetCPIDLookupBatchAction.setControllingPost(scope);
    }
  }

  /**
   * @description This method runs when all batch job gets completed
   * @name finish
   * @param objSchedule standard database batachable varaible
   * @author Ankit Garg
   * @US CC-4761
   */
  public void finish(Database.BatchableContext objSchedule) {
  }
}
