/**
 *
 * @author Peter Charalambous
 * @since 2021
 * @description RecordAccessLogController is the apex side controller for the record access log monitor LWC
 */
public with sharing class RecordAccessLogController {
  public static BigObjectHelper bigObjectHelper = new BigObjectHelper();
  /**
   * @description Used to insert the access log entry into the Big Object (Log_Record_Access__b)
   * @param browserDetails String contains the browser and browser version
   * @param objectName String the name of the object accessed
   * @param recordId Id the Id of the record accessed
   * @param userId Id the Id of the user accessing the record
   * @return Boolean success of insert
   */
  @AuraEnabled
  public static Boolean createLog(
    String browserDetails,
    String objectName,
    Id recordId,
    Id userId
  ) {
    DateTime timestamp = System.Now();

    Log_Record_Access__b al = new Log_Record_Access__b();
    al.Access_Id__c = userId + ' | ' + recordId + ' | ' + timestamp;
    al.Browser_Details__c = browserDetails;
    al.Object_Name__c = objectName;
    al.Record_Id__c = recordId;
    al.User__c = userId;
    al.Time_Accessed__c = timestamp;

    List<Log_Record_Access__b> alList = new List<Log_Record_Access__b>();
    alList.add(al);
    return bigObjectHelper.insertBigObject(alList, 'Log_Record_Access__b');
  }
}
