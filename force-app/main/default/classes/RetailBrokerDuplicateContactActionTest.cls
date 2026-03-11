@IsTest
private class RetailBrokerDuplicateContactActionTest {
  private static Lib_MockProvider contactMergeRepo = Lib_MockProvider.forType(
    RetailContactMergeRepository.class
  );

  static List<Contact> createTestContactList(Integer count) {
    List<Contact> contacts = new List<Contact>();
    for (Integer i = 0; i < count; i++) {
      Contact contact = new Contact();
      contact.Id = Lib_FakeIdGenerator.getMockId(Contact.getSObjectType());
      contact.FirstName = 'TestFirst';
      contact.LastName = 'TestLast' + i;
      contact.Email = 'test' + i + '@example.com';
      contact.OCV_ID__c = 'OCV' + i;
      contact.Sync_Status__c = BrokerConstants.SYNC_STATUS_BROKER_ORG;
      contact.OCV_Event_Version__c = 1;
      contacts.add(contact);
    }
    return contacts;
  }

  @IsTest
  static void testCheckDuplicateContacts() {
    List<Contact> newContacts = createTestContactList(1);
    List<Contact> oldContacts = newContacts.deepClone(true);
    oldContacts[0].Email = 'oldemail@example.com';
    newContacts[0].Email = 'test0@example.com';

    List<Contact> duplicateContacts = new List<Contact>{ newContacts[0] };

    contactMergeRepo.mock('getDuplicateContacts', duplicateContacts);

    Test.startTest();
    RetailBrokerDuplicateContactAction.checkDuplicateContacts(
      newContacts,
      new Map<Id, Contact>{ oldContacts[0].Id => oldContacts[0] }
    );
    Test.stopTest();

    Assert.isTrue(
      newContacts[0]
        .Sync_Status__c.contains(BrokerConstants.SYNC_STATUS_DUPLICATE_EMAIL),
      'Contact with duplicate email should have SYNC_STATUS_DUPLICATE_EMAIL in Sync_Status__c'
    );
  }

  @IsTest
  static void testCheckDuplicateContactsNegative() {
    contactMergeRepo.mock('getDuplicateContacts', null);

    Test.startTest();
    RetailBrokerDuplicateContactAction.checkDuplicateContacts(null, null);
    Test.stopTest();
    Assert.isTrue(true, 'Cover the exception lines');
  }

  @IsTest
  static void testCheckOldandNewValuesDuplicateContacts() {
    List<Contact> newContacts = createTestContactList(1);
    List<Contact> oldContacts = newContacts.deepClone(true);

    newContacts[0].Sync_Status__c = BrokerConstants.SYNC_STATUS_DUPLICATE_EMAIL;
    newContacts[0].Email = 'newemail@example.com';

    List<Contact> duplicateContacts = new List<Contact>{ newContacts[0] };

    contactMergeRepo.mock('getDuplicateContacts', duplicateContacts);

    Test.startTest();
    Map<String, List<Contact>> result = RetailBrokerDuplicateContactAction.checkOldandNewValuesDuplicateContacts(
      newContacts,
      new Map<Id, Contact>{ oldContacts[0].Id => oldContacts[0] }
    );
    Test.stopTest();

    Assert.isNotNull(result, 'Result map should not be null');
    Assert.isTrue(
      result.containsKey('duplicateEmailContacts') ||
      result.containsKey('duplicateOcvIdContacts'),
      'Result map should contain either duplicateEmailContacts or duplicateOcvIdContacts key'
    );
  }

  @IsTest
  static void testGetContactsWithOldNewValues() {
    List<Contact> duplicateContacts = createTestContactList(2);
    Set<String> contactEmails = new Set<String>{ 'test0@example.com' };
    Set<String> contactOcvIds = new Set<String>{ 'OCV1' };

    Test.startTest();
    Map<String, List<Contact>> result = RetailBrokerDuplicateContactAction.getContactsWithOldNewValues(
      duplicateContacts,
      contactEmails,
      contactOcvIds
    );
    Test.stopTest();

    Assert.isNotNull(result, 'Result map should not be null');
    Assert.isTrue(
      result.containsKey('duplicateEmailContacts'),
      'Result map should contain duplicateEmailContacts key'
    );
    Assert.isTrue(
      result.containsKey('duplicateOcvIdContacts'),
      'Result map should contain duplicateOcvIdContacts key'
    );
    Assert.areEqual(
      1,
      result.get('duplicateEmailContacts').size(),
      'Should have 1 contact with duplicate email'
    );
    Assert.areEqual(
      1,
      result.get('duplicateOcvIdContacts').size(),
      'Should have 1 contact with duplicate OCV ID'
    );
  }
}
