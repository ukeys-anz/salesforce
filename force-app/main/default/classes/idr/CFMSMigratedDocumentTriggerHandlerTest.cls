@isTest
private with sharing class CFMSMigratedDocumentTriggerHandlerTest {
  @TestSetup
  static void makeData() {
    Case c = new Case(RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID);
    insert c;
    CFMS_Migrated_Document__c[] docs = new List<CFMS_Migrated_Document__c>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      docs.add(
        new CFMS_Migrated_Document__c(
          Parent_Complaint__c = c.Id,
          URL__c = 'https://anz.com/12345678',
          Description__c = 'Test description 1234-5678-9101-7632-3321 check mask',
          UUID__c = CommonUtil.generateUUID()
        )
      );
    }
    insert docs;
  }

  @isTest
  static void testDelete() {
    //GIVEN Docs
    CFMS_Migrated_Document__c[] docs = [
      SELECT Id
      FROM CFMS_Migrated_Document__c
    ];
    //WHEN I try to delete them
    try {
      delete docs;
    } catch (DMLexception e) {
      //THEN I get an error
      system.assert(
        e.getMessage().contains('You may not delete CFMS migrated documents.'),
        'Deletion prevention should be on.'
      );
    }
  }

  @isTest
  static void testMaskingInsert() {
    String description = [
      SELECT Description__c
      FROM CFMS_Migrated_Document__c
      LIMIT 1
    ]
    .Description__c;
    System.assertEquals(
      'Test description ****************3321 check mask',
      Description,
      'Free text field should have been masked on insert.'
    );
  }

  @isTest
  static void testMaskingUpdate() {
    //GIVEN docs with a descriptionm
    CFMS_Migrated_Document__c[] docs = [
      SELECT Description__c
      FROM CFMS_Migrated_Document__c
    ];
    //WHEN I update it
    for (CFMS_Migrated_Document__c doc : docs) {
      doc.Description__c = 'Test description 1234-5678-9101-7632-3321 check mask';
    }
    update docs;
    //THEN the updated description was masked
    String description = [
      SELECT Description__c
      FROM CFMS_Migrated_Document__c
      LIMIT 1
    ]
    .Description__c;
    System.assertEquals(
      'Test description ****************3321 check mask',
      Description,
      'Free text field should have been masked'
    );
  }
}
