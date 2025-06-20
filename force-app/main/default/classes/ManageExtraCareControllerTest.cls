/**
 * @description       : Test Class for ManageExtraCareController
 * @author            : Akshat Khandelwal
 * @group             :
 * @last modified on  : Apr 2025
 **/
@IsTest
public with sharing class ManageExtraCareControllerTest {
  private static final Faker FAKER = new Faker('AU');
  static Lib_MockProvider manageExtraCareControllerRepositoryMock;
  static Lib_MockProvider profileStagingHandlerMock;
  static void registerMocks() {
    manageExtraCareControllerRepositoryMock = Lib_MockProvider.forType(
      ManageExtraCareControllerRepository.class
    );
    profileStagingHandlerMock = Lib_MockProvider.forType(
      ProfileStagingHandler.class
    );
  }

  static Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
  static Account record = new Account(
    Id = accountId,
    ExtraCareTimePeriod__c = 'Temporarily required',
    ExtraCareReason__c = 'Administration Order;Power of Attorney;Cognitive capacity concerns',
    ExtraCareNotes__c = 'Updating',
    ExtraCareReviewDate__c = Date.today(),
    ExtraCareDisclosure__c = true,
    ExtraCareConsent__c = true
  );
  static Account oldRecord = new Account(
    Id = accountId,
    ExtraCareTimePeriod__c = 'Temporarily required',
    ExtraCareReason__c = 'Administration Order;Power of Attorney',
    ExtraCareNotes__c = 'Updating',
    ExtraCareReviewDate__c = Date.today(),
    ExtraCareDisclosure__c = false,
    ExtraCareConsent__c = false
  );

  @IsTest
  private static void testHandleExtraCareUpdate() {
    registerMocks();
    Test.startTest();
    ManageExtraCareController.handleExtraCareUpdate(oldRecord, record);
    Test.stopTest();
    List<Account> newAccList = (List<Account>) profileStagingHandlerMock
      .getHistory('process')
      .getParam('records');
    Assert.areEqual(
      true,
      newAccList[0].ExtraCareConsent__c,
      'Extra Care Consent should be true.'
    );
    Assert.areEqual(
      true,
      newAccList[0].ExtraCareDisclosure__c,
      'Extra Care Disclosure should be true.'
    );
    Assert.areEqual(
      'Temporarily required',
      newAccList[0].ExtraCareTimePeriod__c,
      'Extra Care Time Period should be Temporarily required.'
    );
    Assert.areEqual(
      'Administration Order;Power of Attorney;Cognitive capacity concerns',
      newAccList[0].ExtraCareReason__c,
      'Extra Care Reason does not have correct values.'
    );
  }

  @IsTest
  private static void testGetStagingRecordStatus() {
    registerMocks();
    Id mockAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id customerProfileUpdatesId = Lib_FakeIdGenerator.getMockId(
      Customer_Profile_Updates__c.SObjectType
    );

    ManageExtraCareControllerRepositoryMock.mock(
      'queryCustomerProfileUpdateRecordByCustomerId',
      new Customer_Profile_Updates__c(
        id = customerProfileUpdatesId,
        Customer_Name__c = mockAccountId,
        Status__c = 'Pending'
      )
    );
    Test.startTest();
    String status = ManageExtraCareController.getStagingRecordStatus(
      mockAccountId
    );
    Test.stopTest();

    Assert.areEqual(
      'Pending',
      status,
      'The staging record status should be "Pending".'
    );
  }
}
