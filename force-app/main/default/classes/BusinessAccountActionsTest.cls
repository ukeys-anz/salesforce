@isTest
public class BusinessAccountActionsTest {
  static Lib_MockProvider accRepoMock;
  static void registerMocks() {
    accRepoMock = Lib_MockProvider.forType(AccountActionsRepository.class);
  }

  @isTest
  static void testsetErrorForOCVIdChange() {
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Account> records = new List<Account>{
      new Account(Id = accId, OCV_ID__c = '40186141')
    };
    Map<Id, Account> oldMap = new Map<Id, Account>{
      accId => new Account(Id = accId, OCV_ID__c = '40186140')
    };
    registerMocks();
    accRepoMock.mock('isCurrentUserML', true);
    BusinessAccountActions.setErrorForOCVIdChange(records, oldMap);
    Assert.areEqual(
      Label.OCV_ID_Update_ErrorMessage,
      records[0].getErrors()[0].getMessage(),
      'Error message is not received while updating OCV Id'
    );
  }
}
