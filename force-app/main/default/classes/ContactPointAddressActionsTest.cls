/**
 * @author Ashwin Mohan
 * @since 11/2024
 * @description ContactPointAddressActionsTest is the test class for ContactPointAddressActions Class.
 */
@isTest
public with sharing class ContactPointAddressActionsTest {
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  static void testDeleteExpiredRecords() {
    registerMocks();
    List<ContactPointAddress> addressRecords = new List<ContactPointAddress>{
      new ContactPointAddress(
        Id = Lib_FakeIdGenerator.getMockId(ContactPointAddress.SObjectType),
        ActiveToDate = System.today().addDays(-2)
      )
    };
    Map<Id, ContactPointAddress> oldMap = new Map<Id, ContactPointAddress>{
      addressRecords[0].Id => new ContactPointAddress(
        Id = addressRecords[0].Id,
        ActiveToDate = null
      )
    };
    Test.startTest();
    ContactPointAddressActions.deleteExpiredRecords(addressRecords, oldMap);
    Test.stopTest();
    List<ContactPointAddress> deletedRecords = (List<ContactPointAddress>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      deletedRecords.size(),
      'The inactive address record is not deleted'
    );
  }
}
