/**
 * @author Greg Shaw
 * @since Nov 2023
 * @description Handler Apex to create `Log__c`, `LogEntry__c` and `SecureLogEntry__c` records when `LogEvent__e` is published
 */

public with sharing class LogEntryTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onAfterInsert etc.
   */
  public LogEntryTriggerHandler() {
    super();
  }

  /**
   * @description process LogEntry__c records before deletion.
   */
  public override void onBeforeDelete() {
    deleteContentDocuments(records);
  }

  /**
   * @description delete ContentDocument records referenced by LogEntry__c records
   * @param lstLogEntries list of LogEntry__c records being deleted
   */
  private static void deleteContentDocuments(List<LogEntry__c> lstLogEntries) {
    Set<Id> stDocumentIds = new Set<Id>();
    String strContentDocumentPrefix = Schema.ContentDocument.getSObjectType()
      .getDescribe()
      .getKeyPrefix();
    Integer nStart;
    if (ContentDocument.getSObjectType().getDescribe().isDeletable()) {
      for (LogEntry__c oLogEntry : lstLogEntries) {
        if (
          oLogEntry.ApexClassName__c == 'ContentDocumentLinkTriggerHandler' &&
          oLogEntry.ApexMethodName__c == 'logFileDelete'
        ) {
          if (
            String.isNotEmpty(oLogEntry.RecordId__c) &&
            oLogEntry.RecordId__c.startsWith(strContentDocumentPrefix)
          ) {
            stDocumentIds.add(oLogEntry.RecordId__c);
          } else if (
            String.isNotEmpty(oLogEntry.LogMessage__c) &&
            (nStart = oLogEntry.LogMessage__c.indexOf(
              ', ' + strContentDocumentPrefix
            )) != -1
          ) {
            stDocumentIds.add(
              oLogEntry.LogMessage__c.substring(nStart + 2, nStart + 20)
            );
          }
        }
      }
      List<ContentDocument> lstDocuments = [
        SELECT Id
        FROM ContentDocument
        WHERE Id IN :stDocumentIds
      ];
      if (lstDocuments.size() > 0) {
        // We don't care if some of the Documents are not found. They are being deleted anyway.
        Database.delete(lstDocuments, false);
      }
    }
  }
}
