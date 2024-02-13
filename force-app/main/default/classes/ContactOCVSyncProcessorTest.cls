/**
 * @author Zhiren Jason Guan
 * @since 20/12/2023
 * @description Test class for Contact record processing functionalities
 */

@IsTest
private class ContactOCVSyncProcessorTest {
  @IsTest
  static void testBehavior() {
    // Test data set 1
    List<Contact> testContacts = new List<Contact>();
    Map<Id, Contact> testContactMap = new Map<Id, Contact>();
    // Test data set 2
    List<Contact> testContacts2 = new List<Contact>();
    Map<Id, Contact> testContactMap2 = new Map<Id, Contact>();
    // Test data set 3
    List<Contact> testContacts3 = new List<Contact>();
    Map<Id, Contact> testContactMap3 = new Map<Id, Contact>();
    // Test data set 4
    List<Contact> testContacts4 = new List<Contact>();
    Map<Id, Contact> testContactMap4 = new Map<Id, Contact>();
    // Test data set 5
    List<Contact> testContacts5 = new List<Contact>();
    Map<Id, Contact> testContactMap5 = new Map<Id, Contact>();

    // Setup bulk of 10 mocked data
    for (Integer i = 0; i < 10; i++) {
      // Setup positive test Contact with Sync Status = null
      Contact testContact = new Contact(
        Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType),
        OCV_Event_Version__c = i + 2
      );
      testContacts.add(testContact);
      Contact oldContact = testContact.clone(true);
      oldContact.OCV_Event_Version__c = i + 1;
      testContactMap.put(oldContact.Id, oldContact);
      // Setup positive test Contact with Sync Status = Other (Other does not exist as a valid picklist value, only 'Blocked' or 'Broker Org')
      // Note: This invalid 'Other' test scenario is created in order to address the code review feedback and still achieve 100% coverage
      Contact testContact2 = new Contact(
        Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType),
        OCV_Event_Version__c = i + 2,
        Sync_Status__c = 'Other'
      );
      testContacts2.add(testContact2);
      Contact oldContact2 = testContact2.clone(true);
      oldContact2.OCV_Event_Version__c = i + 1;
      testContactMap2.put(oldContact2.Id, oldContact2);

      // Setup negative test Contact with OCV Event Version Unchanged
      Contact testContact3 = new Contact(
        Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType),
        OCV_Event_Version__c = i + 1
      );
      testContacts3.add(testContact3);
      Contact oldContact3 = testContact3.clone(true);
      testContactMap3.put(oldContact3.Id, oldContact3);
      // Setup negative test Contact with Sync Status = Broker Org
      Contact testContact4 = new Contact(
        Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType),
        OCV_Event_Version__c = i + 2,
        Sync_Status__c = ContactOCVSyncProcessor.SYNC_STATUS_BROKER_ORG
      );
      testContacts4.add(testContact4);
      Contact oldContact4 = testContact4.clone(true);
      oldContact4.OCV_Event_Version__c = i + 1;
      testContactMap4.put(oldContact4.Id, oldContact4);
      // Setup negative test Contact with Sync Status = Blocked
      Contact testContact5 = new Contact(
        Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType),
        OCV_Event_Version__c = i + 2,
        Sync_Status__c = ContactOCVSyncProcessor.SYNC_STATUS_BLOCKED
      );
      testContacts5.add(testContact5);
      Contact oldContact5 = testContact5.clone(true);
      oldContact5.OCV_Event_Version__c = i + 1;
      testContactMap5.put(oldContact5.Id, oldContact5);
    }

    Test.startTest();
    // Positive
    ContactOCVSyncProcessor.updateRecordsForOCVVersionChanged(
      testContacts,
      testContactMap
    );
    ContactOCVSyncProcessor.updateRecordsForOCVVersionChanged(
      testContacts2,
      testContactMap2
    );
    // Negative
    ContactOCVSyncProcessor.updateRecordsForOCVVersionChanged(
      testContacts3,
      testContactMap3
    );
    ContactOCVSyncProcessor.updateRecordsForOCVVersionChanged(
      testContacts4,
      testContactMap4
    );
    ContactOCVSyncProcessor.updateRecordsForOCVVersionChanged(
      testContacts5,
      testContactMap5
    );
    Test.stopTest();

    // Assert Positive: Broker Org added
    for (Contact resultAcc : testContacts) {
      Assert.areEqual(
        true,
        resultAcc.Sync_Status__c.contains(
          ContactOCVSyncProcessor.SYNC_STATUS_BROKER_ORG
        )
      );
    }
    // Assert Positive: Broker Org added
    for (Contact resultAcc : testContacts2) {
      Assert.areEqual(
        true,
        resultAcc.Sync_Status__c.contains(
          ContactOCVSyncProcessor.SYNC_STATUS_BROKER_ORG
        )
      );
    }
    // Assert Negative: Sync_Status__c unchanged
    for (Contact resultAcc : testContacts3) {
      Assert.areEqual(
        false,
        resultAcc.Sync_Status__c ==
        ContactOCVSyncProcessor.SYNC_STATUS_BROKER_ORG
      );
    }
    // Assert Negative: Sync_Status__c unchanged
    for (Contact resultAcc : testContacts4) {
      Assert.areEqual(
        true,
        resultAcc.Sync_Status__c.contains(
          ContactOCVSyncProcessor.SYNC_STATUS_BROKER_ORG
        )
      );
    }
    // Assert Negative: Sync_Status__c unchanged
    for (Contact resultAcc : testContacts5) {
      Assert.areEqual(
        false,
        resultAcc.Sync_Status__c.contains(
          ContactOCVSyncProcessor.SYNC_STATUS_BROKER_ORG
        )
      );
    }
  }
}
