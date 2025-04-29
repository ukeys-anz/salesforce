/**
 * @description To delete inactive ContactPointEmail/ContactPointPhone/ContactPointAddress records weekly
 * @author Ashwin Mohan
 * @since 11/2024
 */
public with sharing class DeleteContactPointBatch implements Database.Batchable<SObject> {
  public String contactPointObjectName;
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description to initiate the batch to run for a specific contactpoint object
   * @param contactPointObjectName The object whose data needs to be deleted
   */
  public DeleteContactPointBatch(String contactPointObjectName) {
    this.contactPointObjectName = contactPointObjectName;
  }

  /**
   * @description to query all inactive contactpoint records
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    String query =
      'SELECT Id FROM ' +
      this.contactPointObjectName +
      ' WHERE ActiveToDate <= TODAY ';
    return Database.getQueryLocator(String.escapeSingleQuotes(query));
  }

  /**
   * @description method to delete CP records
   * @param bc Database.BatchableContext
   * @param contactPointsToDelete records retrieved in start method
   */
  public void execute(
    Database.BatchableContext bc,
    List<SObject> contactPointsToDelete
  ) {
    DML_REPOSITORY.doDelete(
      contactPointsToDelete,
      new DmlConfig().allowPartial()
    );
  }

  /**
   * @description This method runs when all batch job gets completed
   * @name finish
   * @param bc standard database batachable variable
   */
  public void finish(Database.BatchableContext bc) {
  }
}
