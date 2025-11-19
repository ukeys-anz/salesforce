@IsTest
private class LeadEnhmentUpdateCommContactTest {
  private static Lib_MockProvider leadCommContactRepoMock;
  private static Id getMockRecordTypeId(
    SObjectType sObjectType,
    String rtName
  ) {
    return Lib_FakeIdGenerator.getMockId(sObjectType);
  }
  private static void registerMocks() {
    leadCommContactRepoMock = Lib_MockProvider.forType(
      LeadCommContactRepository.class
    );
  }

  /**
   * @description Test method for successful retrieval of related Person Accounts using mocks.
   */
  @IsTest
  static void testGetIndividualCustomerRecordSuccess() {
    registerMocks();

    Id customerAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id personAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id personAccountRecTypeId = getMockRecordTypeId(
      Account.SObjectType,
      'personAccount'
    );

    List<FinServ__AccountAccountRelation__c> mockRelations = new List<FinServ__AccountAccountRelation__c>();

    Account mockRelatedAccount = new Account(
      Id = personAccountId,
      RecordTypeId = personAccountRecTypeId,
      Name = 'Mock Individual Contact',
      FirstName = 'Mock',
      LastName = 'Contact',
      Salutation = 'Dr.',
      Phone = '5551234567',
      PersonMobilePhone = '5559876543',
      PersonOtherPhone = '5551112222',
      PersonHomePhone = '5553334444',
      Other_Email__c = 'mock.individual@test.com',
      Source_System_Name__c = 'CAP-CIS'
    );

    FinServ__AccountAccountRelation__c mockRelation = new FinServ__AccountAccountRelation__c(
      Id = Lib_FakeIdGenerator.getMockId(
        FinServ__AccountAccountRelation__c.SObjectType
      ),
      FinServ__Account__c = customerAccountId,
      FinServ__RelatedAccount__c = personAccountId,
      FinServ__RelatedAccount__r = mockRelatedAccount
    );
    mockRelations.add(mockRelation);

    leadCommContactRepoMock.mock('getRelatedIndividualAccounts', mockRelations);

    Test.startTest();
    List<FinServ__AccountAccountRelation__c> results = LeadEnhmentUpdateCommContactController.getIndividualCustomerRecord(
      customerAccountId
    );
    Test.stopTest();

    Assert.areEqual(
      1,
      results.size(),
      'Should return one mocked relation record.'
    );

    FinServ__AccountAccountRelation__c resultRelation = results[0];
    Account resultRelatedAccount = resultRelation.FinServ__RelatedAccount__r;

    Assert.areEqual(
      personAccountId,
      resultRelatedAccount.Id,
      'Related Account ID should match mock ID.'
    );
    Assert.areEqual(
      'Mock',
      resultRelatedAccount.FirstName,
      'First Name should be mocked value.'
    );
    Assert.areEqual(
      '5559876543',
      resultRelatedAccount.PersonMobilePhone,
      'Mobile Phone should be mocked value.'
    );
    Assert.areEqual(
      'mock.individual@test.com',
      resultRelatedAccount.Other_Email__c,
      'Custom Email should be mocked value.'
    );
  }

  /**
   * @description Test method for when the input account ID is null.
   */
  @IsTest
  static void testGetIndividualCustomerRecordNullI() {
    registerMocks();
    leadCommContactRepoMock.mock(
      'getRelatedIndividualAccounts',
      new List<FinServ__AccountAccountRelation__c>()
    );
    Test.startTest();
    List<FinServ__AccountAccountRelation__c> results = LeadEnhmentUpdateCommContactController.getIndividualCustomerRecord(
      null
    );
    Test.stopTest();
    Assert.areEqual(
      0,
      results.size(),
      'Should return an empty list for null input ID.'
    );
  }

  /**
   * @description Test method for when Exception is there.
   */
  @IsTest
  static void testGetIndividualCustomerRecordException() {
    registerMocks();
    Id customerAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    String expectedErrorMessage = 'Script-thrown exception';
    leadCommContactRepoMock.mock(
      'getRelatedIndividualAccounts',
      new AuraHandledException('Exception Occured')
    );
    Test.startTest();
    Boolean caughtAuraHandledException = false;
    try {
      LeadEnhmentUpdateCommContactController.getIndividualCustomerRecord(
        customerAccountId
      );
    } catch (AuraHandledException e) {
      caughtAuraHandledException = true;
      String actualMessage = e.getMessage();
      Assert.isTrue(
        actualMessage.contains(expectedErrorMessage),
        'The exception message is: ' + actualMessage
      );
    } catch (Exception e) {
      Assert.fail('Exception Occured: ' + e.getTypeName());
    }
    Test.stopTest();
    Assert.isTrue(
      caughtAuraHandledException,
      'An AuraHandledException should have been caught.'
    );
  }
}
