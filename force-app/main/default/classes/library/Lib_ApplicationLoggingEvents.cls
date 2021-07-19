/**
 * @author
 * @since 2019
 * @group Logging
 * @description  Lib_ApplicationLoggingEvents is handler for trigger on Application_Logging__e that creates Logs in Application_Log__c Object
 * {@link triggers.lib_ApplicationLoggingEventTrigger} is the trigger which uses this handler
 * which is received from a platform event based on {@link Lib_SystemLog}
 * @group Library
 */
public without sharing class Lib_ApplicationLoggingEvents extends Lib_TriggerHandler {
  /**
   * @description Constructor Lib_ApplicationLoggingEvents
   */
  public Lib_ApplicationLoggingEvents() {
    super();
  }

  public static BigObjectHelper bigObjectHelper = new BigObjectHelper();

  /**
   * @description The method onAfterInsert overridden method from {@link Lib_TriggerHandler} which gets called automatically as part of the Trigger.
   * In this method we extract the sfLog__c to get the event as JSON and deserialize to {@link lib_SystemLog} and store the events as
   * Application_Log__c records.
   */
  public override void onAfterInsert() {
    List<Traced_Application_Log__b> applicationLogs = new List<Traced_Application_Log__b>();
    for (SObject record : records) {
      applicationLogs.addAll(juiceLogs(record));
    }

    bigObjectHelper.insertBigObject(
      applicationLogs,
      'Traced_Application_Log__b'
    );
  }

  /**
   * @description This method is used to extracts the sfLog__c from platform even Application_Logging__e and deserialize JSON to List<Application_Log__c>
   * @param record which contains sfLog__c column which has serialized json log
   * @return `List<Application_Log__c>` which is list of log records that needs to be inserted in Application_Log__c Object
   */
  private static List<Traced_Application_Log__b> juiceLogs(SObject record) {
    String sfLogJson = (String) record.get('sfLog__c') != null
      ? (String) record.get('sfLog__c')
      : null;

    if (sfLogJson != null) {
      lib_SystemLog sfLog = (lib_SystemLog) JSON.deserialize(
        sfLogJson,
        lib_SystemLog.class
      );
      return sfLog.logList;
    }

    return null;
  }
}
