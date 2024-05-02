/**
 * @description To delete the custom field history records after 30 days
 * @author Arpit Pittie
 * @since Apr 24, 2024
 */
public with sharing class DataDeletionBatch implements Database.Batchable<SObject>, Schedulable {
  public List<String> objectNameList;
  public String objectToDelete;

  /**
   * @description execute method to run logic to delete the custom history records
   * @param sc SchedulableContext
   */
  public void execute(SchedulableContext sc) {
    Database.executeBatch(new DataDeletionBatch());
  }

  /**
   * @description to initialise the batch to run for the Custom MEtadata table names
   */
  public DataDeletionBatch() {
    this.objectNameList = new List<String>();
    Map<String, Custom_Dynamic_Object_History_Setting__mdt> customObjectHistoryMap = Custom_Dynamic_Object_History_Setting__mdt.getAll();
    if (customObjectHistoryMap == null || customObjectHistoryMap.isEmpty()) {
      return;
    }
    for (
      Custom_Dynamic_Object_History_Setting__mdt metadataObject : customObjectHistoryMap.values()
    ) {
      this.objectNameList.add(metadataObject.Table_Name__c);
    }
  }

  /**
   * @description to initiate the batch to run for a specific object
   * @param objectName The object whose data needs to be deleted
   */
  public DataDeletionBatch(String objectName) {
    this.objectToDelete = objectName;
  }

  /**
   * @description to initiate the batch to run recursively for multiple objects
   * @param objectName The object whose data needs to be deleted
   * @param objectList The objject list whose data needs to be deleted
   */
  public DataDeletionBatch(String objectName, List<String> objectList) {
    this.objectToDelete = objectName;
    this.objectNameList = objectList;
  }

  /**
   * @description Get all the Notification records which are due to be sent out
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator scope
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    String objectName;
    if (this.objectNameList != null && !this.objectNameList.isEmpty()) {
      objectName = this.objectNameList.get(0);
    } else {
      objectName = this.objectToDelete;
    }
    String query =
      'SELECT Id FROM ' +
      objectName +
      ' WHERE CreatedDate = LAST_N_MONTHS:1';
    return Database.getQueryLocator(String.escapeSingleQuotes(query));
  }

  /**
   * @description  method which is called when batch is exeuted and will call another method to process the notification
   * @param bc Database.BatchableContext
   * @param deletionRecords from start method
   */
  public void execute(
    Database.BatchableContext bc,
    List<SObject> deletionRecords
  ) {
    DMLUtil.deleteRecords(
      deletionRecords,
      DMLUtil.NOT_ALLOW_PARTIAL_UPDATE,
      DMLUtil.SYSTEM_MODE
    );
  }

  /**
   * @description To execute any post processing steps
   * @param bc Database.BatchableContext
   */
  public void finish(Database.BatchableContext bc) {
    if (
      this.objectNameList == null ||
      this.objectNameList.isEmpty() ||
      this.objectNameList.size() == 1
    ) {
      return;
    }
    this.objectNameList.remove(0);
    Database.executeBatch(
      new DataDeletionBatch(this.objectNameList.get(0), this.objectNameList)
    );
  }
}
