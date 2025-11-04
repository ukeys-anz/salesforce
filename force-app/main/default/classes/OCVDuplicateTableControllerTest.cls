/**
 * @author Prahlad Bhadani
 * @since  09/2024
 * @group Platform
 * @description Test class of OCVDuplicateTableController
 */
@isTest
public with sharing class OCVDuplicateTableControllerTest {
  static Lib_MockProvider controllerRepoMock;
  static void registerMocks() {
    controllerRepoMock = Lib_MockProvider.forType(
      OCVDuplicateTableControllerRepository.class
    );
  }

  @isTest
  static void getAllCustomersByOCVIdTest() {
    registerMocks();
    Id newAccId = Lib_FakeIdGenerator.getMockId(
      Schema.Account.getSObjectType()
    );
    Account cust = new Account(
      Id = newAccId,
      Name = 'Test Test',
      OCV_Id__c = '12345'
    );

    List<Account> duplicateAccounts = new List<Account>{
      cust,
      new Account(
        Id = Lib_FakeIdGenerator.getMockId(Schema.Account.getSObjectType()),
        Name = 'Duplicate Account 1',
        OCV_Id__c = '12345'
      ),
      new Account(
        Id = Lib_FakeIdGenerator.getMockId(Schema.Account.getSObjectType()),
        Name = 'Duplicate Account 2',
        OCV_Id__c = '12345'
      )
    };
    controllerRepoMock.mock('getCustomer', cust);
    controllerRepoMock.mock('getAllCustomers', duplicateAccounts);
    Test.startTest();
    List<Account> result = OCVDuplicateTableController.getAllCustomersByOCVId(
      newAccId
    );
    Test.stopTest();
    System.assertEquals(3, result.size(), 'Three accounts should be returned!');
  }

  @isTest
  static void getAllCustomersByOCVIdNoRecordIdTest() {
    Test.startTest();
    List<Account> result = OCVDuplicateTableController.getAllCustomersByOCVId(
      null
    );
    Test.stopTest();
    System.assertEquals(0, result.size(), 'No accounts should be returned!');
  }

  @isTest
  static void getAllCustomersByOCVIdNoOCVIdTest() {
    registerMocks();
    Id newAccId = Lib_FakeIdGenerator.getMockId(
      Schema.Account.getSObjectType()
    );
    Account cust = new Account(Id = newAccId, Name = 'Test Test');
    controllerRepoMock.mock('getCustomer', cust);
    controllerRepoMock.mock('getAllCustomers', new List<Account>());
    Test.startTest();
    List<Account> result = OCVDuplicateTableController.getAllCustomersByOCVId(
      newAccId
    );
    Test.stopTest();
    System.assertEquals(0, result.size(), 'No accounts should be returned!');
  }

  @isTest
  static void getAllCustomersByOCVNegativeTest() {
    registerMocks();
    Id newAccId = Lib_FakeIdGenerator.getMockId(
      Schema.Account.getSObjectType()
    );
    Account cust = new Account(Id = newAccId, Name = 'Test Test');
    controllerRepoMock.mockException(
      'getCustomer',
      new QueryException('insufficient permissions!')
    );
    try {
      Test.startTest();
      List<Account> result = OCVDuplicateTableController.getAllCustomersByOCVId(
        newAccId
      );
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'insufficient permissions!'
      );
    }
  }
}
