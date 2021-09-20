trigger CFMSMigratedDocumentTrigger on CFMS_Migrated_Document__c(
  before insert,
  before update,
  before delete
) {
  CFMSMigratedDocumentTriggerHandler handler = new CFMSMigratedDocumentTriggerHandler();
}
