/**
 * @author Adnan
 * @since  10/2023
 * @description Batch class for migrating complaint resolution records from case object to a new object
 */
public with sharing class IDRComplaintResolutionMigrationBatch implements Database.Batchable<SObject> {
  private static final String NO_POST_PROCESSING_STEPS_MSG = 'No post processing steps as of now';

  /**
   * @description Get all the task records whose type is Pend Case and withing due date window
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator scope
   */

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      'SELECT Id, IDR_Complaint_Remedy__c, IDR_Complaint_Remedy_2__c, IDR_Complaint_Remedy_3__c, IDR_Complaint_Sub_Remedy__c, IDR_Complaint_Sub_Remedy_2__c, IDR_Complaint_Sub_Remedy_3__c, IDR_Other_Remedy_Provided__c, IDR_Other_Remedy_Provided_2__c, IDR_Other_Remedy_Provided_3__c, IDR_Financial_Compensation__c, IDR_Financial_Compensation_2__c, IDR_Financial_Compensation_3__c, IDR_Financial_Remedy_Points__c, IDR_Financial_Remedy_Points_2__c, IDR_Financial_Remedy_Points_3__c, Provided_details_to_Product_Manufacturer__c, Provided_details_to_Prod_Manufacturer_2__c, Provided_details_to_Prod_Manufacturer_3__c, IDR_Duration_of_Remedy__c, IDR_Duration_of_Remedy_2__c, IDR_Duration_of_Remedy_3__c, IDR_Total_Financial_Amount__c ' +
      'FROM Case ' +
      'WHERE ( IDR_Other_Remedy_Provided__c != null OR IDR_Financial_Remedy_Points__c != null OR IDR_Financial_Compensation__c != null OR IDR_Duration_of_Remedy__c != null OR IDR_Complaint_Sub_Remedy__c != null OR IDR_Complaint_Remedy__c != null ) AND (RecordType.Name = \'Customer Complaint\' OR RecordType.Name = \'Non-Customer Complaint\')'
    );
  }

  /**
   * @description  method which is called when batch is exeuted and will call another method to process the notification
   * @param bc Database.BatchableContext
   * @param caseScope from start method
   */
  public void execute(Database.BatchableContext bc, List<Case> caseScope) {
    List<Complaint_Resolution__c> crList = new List<Complaint_Resolution__c>();
    for (Case c : caseScope) {
      if (c.IDR_Complaint_Remedy__c != null) {
        Complaint_Resolution__c cr1 = new Complaint_Resolution__c();
        //Map Complaint Remedy 1 fields to cr1
        cr1.IDR_Complaint__c = c.Id;
        cr1.IDR_Duration_of_Remedy__c = c.IDR_Duration_of_Remedy__c;
        cr1.IDR_Other_Remedy_Provided__c = c.IDR_Other_Remedy_Provided__c;
        cr1.IDR_Financial_Compensation__c = c.IDR_Financial_Compensation__c;
        cr1.IDR_Complaint_Remedy__c = c.IDR_Complaint_Remedy__c;
        cr1.IDR_Complaint_Sub_Remedy__c = c.IDR_Complaint_Sub_Remedy__c;
        cr1.IDR_Financial_Remedy_Points__c = c.IDR_Financial_Remedy_Points__c;
        crList.add(cr1);
        if (c.IDR_Complaint_Remedy_2__c != null) {
          Complaint_Resolution__c cr2 = new Complaint_Resolution__c();
          //Map Complaint Remedy 2 fields to cr2
          cr2.IDR_Complaint__c = c.Id;
          cr2.IDR_Duration_of_Remedy__c = c.IDR_Duration_of_Remedy_2__c;
          cr2.IDR_Other_Remedy_Provided__c = c.IDR_Other_Remedy_Provided_2__c;
          cr2.IDR_Financial_Compensation__c = c.IDR_Financial_Compensation_2__c;
          cr2.IDR_Complaint_Remedy__c = c.IDR_Complaint_Remedy_2__c;
          cr2.IDR_Complaint_Sub_Remedy__c = c.IDR_Complaint_Sub_Remedy_2__c;
          cr2.IDR_Financial_Remedy_Points__c = c.IDR_Financial_Remedy_Points_2__c;
          crList.add(cr2);
          if (c.IDR_Complaint_Remedy_3__c != null) {
            Complaint_Resolution__c cr3 = new Complaint_Resolution__c();
            //Map Complaint Remedy 3 fields to cr3
            cr3.IDR_Complaint__c = c.Id;
            cr3.IDR_Duration_of_Remedy__c = c.IDR_Duration_of_Remedy_3__c;
            cr3.IDR_Other_Remedy_Provided__c = c.IDR_Other_Remedy_Provided_3__c;
            cr3.IDR_Financial_Compensation__c = c.IDR_Financial_Compensation_3__c;
            cr3.IDR_Complaint_Remedy__c = c.IDR_Complaint_Remedy_3__c;
            cr3.IDR_Complaint_Sub_Remedy__c = c.IDR_Complaint_Sub_Remedy_3__c;
            cr3.IDR_Financial_Remedy_Points__c = c.IDR_Financial_Remedy_Points_3__c;
            crList.add(cr3);
          }
        }
      }
    }
    List<Database.SaveResult> results = Database.Insert(crList);
    Logger.error('', results);
    Logger.saveLog();
  }

  /**
   * @description To execute any post processing steps
   * @param bc Database.BatchableContext
   */
  public void finish(Database.BatchableContext bc) {
    System.debug(LoggingLevel.debug, NO_POST_PROCESSING_STEPS_MSG);
  }
}
