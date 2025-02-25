/**
 * @author Ashwin Mohan
 * @since 11/24
 * @description test class for ContactPointObjectActions class
 */
@isTest
public with sharing class ContactPointObjectActionsTest {
  static Lib_MockProvider cpRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    cpRepoMock = Lib_MockProvider.forType(
      ContactPointObjectActionsRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  static void testUpdateActiveToDate() {
    registerMocks();
    List<ContactPointEmail> emailRecords = new List<ContactPointEmail>{
      new ContactPointEmail(
        Id = Lib_FakeIdGenerator.getMockId(ContactPointEmail.SObjectType)
      )
    };

    Test.startTest();
    List<String> result = ContactPointObjectActions.updateActiveToDate(
      new List<String>{ emailRecords[0].Id }
    );
    Test.stopTest();
    ContactPointEmail updatedRecord = (ContactPointEmail) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('record');
    Assert.areEqual(
      System.today(),
      updatedRecord.ActiveToDate,
      'ActiveToDate field is not updated'
    );
    Assert.areEqual('Success', result[0], 'ActiveToDate is not updated');
  }

  @isTest
  static void testUpdateActiveToDateError() {
    registerMocks();
    List<ContactPointPhone> phoneRecords = new List<ContactPointPhone>{
      new ContactPointPhone(
        Id = Lib_FakeIdGenerator.getMockId(ContactPointPhone.SObjectType)
      )
    };
    cpRepoMock.mock('getCustomerFromPhone', phoneRecords[0]);
    cpRepoMock.mock('getPhoneRecords', phoneRecords);
    Test.startTest();
    List<String> result = ContactPointObjectActions.updateActiveToDate(
      new List<String>{ phoneRecords[0].Id }
    );
    Test.stopTest();
    Assert.areEqual(
      'This record cannot be deleted as the customer must have at least one phone number available.',
      result[0],
      'Atleast one phone error is not received'
    );
  }
}
