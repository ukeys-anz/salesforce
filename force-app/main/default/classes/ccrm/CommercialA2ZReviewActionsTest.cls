/**
 * @author       : Advait Yermalkar
 * @since        : 05/2024
 * @description  : unit testing class for CommercialA2ZReviewActions
 **/
@isTest
private class CommercialA2ZReviewActionsTest {
  static Lib_MockProvider azRepoMock;
  static Lib_MockProvider leadRepoMock;
  static void registerMocks() {
    azRepoMock = Lib_MockProvider.forType(CommercialA2ZReviewRepository.class);
    leadRepoMock = Lib_MockProvider.forType(LeadActionsRepository.class);
  }

  @isTest
  static void testSetCustomerOnA2ZReview() {
    registerMocks();

    //  Create Mock Ids
    Id azReviewId1 = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType);
    Id azReviewId2 = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType);
    Id mockAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id mockLeadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id mockOppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);

    // Create A2Z Reviews
    List<A_Z_Review__c> reviewList = new List<A_Z_Review__c>{
      new A_Z_Review__c(
        Id = azReviewId1,
        Lead__c = mockLeadId,
        Status__c = 'In Progress'
      ),
      new A_Z_Review__c(
        Id = azReviewId2,
        Opportunity__c = mockOppId,
        Status__c = 'In Progress'
      )
    };

    //  Create mock Lead and Opportunity records
    List<Lead> mockLeads = new List<Lead>{
      new Lead(Id = mockLeadId, FinServ__RelatedAccount__c = mockAccountId)
    };

    List<Opportunity> mockOpportunities = new List<Opportunity>{
      new Opportunity(Id = mockOppId, AccountId = mockAccountId)
    };

    // Mock repository method responses
    azRepoMock.mock('getLeads', mockLeads);

    azRepoMock.mock('getOpportunities', mockOpportunities);

    // Step 6: Execute the actual method under test
    Test.startTest();
    CommercialA2ZReviewActions.setCustomerOnA2ZReview(reviewList);
    Test.stopTest();

    Assert.areEqual(
      mockAccountId,
      reviewList[0].Customer__c,
      'Customer__c should be set to the mock Account Id.'
    );
    Assert.areEqual(
      mockAccountId,
      reviewList[1].Customer__c,
      'Customer__c should be set to the mock Account Id.'
    );
  }
  @isTest
  static void testSetCustomerOnA2ZReviewNegative() {
    registerMocks();

    //  Create Mock Ids
    Id azReviewId1 = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType);
    Id azReviewId2 = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType);
    Id mockLeadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id mockOppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);

    // Create A2Z Reviews
    List<A_Z_Review__c> reviewList = new List<A_Z_Review__c>{
      new A_Z_Review__c(
        Id = azReviewId1,
        Lead__c = mockLeadId,
        Status__c = 'In Progress'
      ),
      new A_Z_Review__c(
        Id = azReviewId2,
        Opportunity__c = mockOppId,
        Status__c = 'In Progress'
      )
    };

    // Mock repository method exception
    azRepoMock.mockException(
      'getLeads',
      new QueryException('invalid parameters')
    );
    azRepoMock.mockException(
      'getOpportunities',
      new QueryException('invalid parameters')
    );
    try {
      // Step 6: Execute the actual method under test
      Test.startTest();
      CommercialA2ZReviewActions.setCustomerOnA2ZReview(reviewList);
      Test.stopTest();
      Assert.fail('Should not reach this line'); // Code shouldn't reach this line
    } catch (Exception ex) {
      Assert.isInstanceOfType(
        ex,
        QueryException.class,
        'Incorrect exception type'
      );
      Assert.areEqual(
        'invalid parameters',
        ex.getMessage(),
        'Message does not match'
      );
    }
  }
  @isTest
  static void testPerformRedactionTest() {
    User ccrmBaseUser = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      FirstName = 'BaseUser',
      LastName = 'CCRM'
    );
    List<A_Z_Review__c> lstReviews = new List<A_Z_Review__c>{
      new A_Z_Review__c(
        Id = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType),
        Name = 'Test 1234123412341234',
        OwnerId = ccrmBaseUser.Id,
        Business_Details__c = 'Test 1234123412341234',
        Personal_Banking__c = 'Test 1234123412341234',
        Transaction_Banking__c = 'Test 1234123412341234',
        Borrowing_OFI_Relationship__c = 'Test 1234123412341234'
      )
    };

    String expectedResult = 'Test ************1234';

    Test.startTest();
    CommercialA2ZReviewActions.performRedaction(lstReviews);
    Test.stopTest();

    A_Z_Review__c actualResultReviewInstance = lstReviews[0];

    Assert.areEqual(
      expectedResult,
      actualResultReviewInstance.Name,
      'Redaction is Not Completed'
    );
    Assert.areEqual(
      expectedResult,
      actualResultReviewInstance.Business_Details__c,
      'Redaction is Not Completed'
    );
    Assert.areEqual(
      expectedResult,
      actualResultReviewInstance.Personal_Banking__c,
      'Redaction is Not Completed'
    );
    Assert.areEqual(
      expectedResult,
      actualResultReviewInstance.Transaction_Banking__c,
      'Redaction is Not Completed'
    );
    Assert.areEqual(
      expectedResult,
      actualResultReviewInstance.Borrowing_OFI_Relationship__c,
      'Redaction is Not Completed'
    );
  }
  @isTest
  public static void testCompletedDateOnUpdate() {
    User ccrmUser = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      FirstName = 'BaseUser',
      LastName = 'CCRM'
    );
    String azId = (String) Lib_FakeIdGenerator.getMockId(
      A_Z_Review__c.getSobjectType()
    );

    Map<Id, A_Z_Review__c> oldRecordMap = new Map<Id, A_Z_Review__c>{
      azId => new A_Z_Review__c(
        Id = azId,
        Name = 'A-Z Review Record',
        Status__c = 'In Progress',
        RecordTypeId = RTA2ZReview.commercialA2ZReview,
        OwnerId = ccrmUser.Id
      )
    };

    List<A_Z_Review__c> azReviewList = new List<A_Z_Review__c>{
      new A_Z_Review__c(
        Id = azId,
        Name = 'A-Z Review Record',
        Status__c = 'Completed',
        RecordTypeId = RTA2ZReview.commercialA2ZReview,
        OwnerId = ccrmUser.Id
      )
    };

    //WHEN Calling updateCompletedDate
    Test.startTest();
    CommercialA2ZReviewActions.updateCompletedDate(azReviewList, oldRecordMap);
    Test.stopTest();

    Assert.areEqual(
      azReviewList[0].Completed_Date__c,
      Date.Today(),
      'Completed date not updated when status changes'
    );
  }
  @isTest
  static void testRestrictImagesInRichTextFields() {
    //GIVEN List of A-Z Review Record
    List<A_Z_Review__c> azReviewList = new List<A_Z_Review__c>{
      new A_Z_Review__c(
        Id = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType),
        Status__c = 'In Progress'
      )
    };

    //WHEN calling a restrictImagesInRichTextFields method
    Test.startTest();
    CommercialA2ZReviewActions.restrictImagesInRichTextFields(
      azReviewList,
      null
    );
    Test.stopTest();

    //THEN it shouldn't throw any error
    Assert.isFalse(
      azReviewList[0].hasErrors(),
      'Error while inserting A-Z Review record with Image.'
    );
  }
  @isTest
  static void setBusinessContactToBlankTest() {
    //GIVEN records, oldMap
    Id azReviewId = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType);
    List<A_Z_Review__c> records = new List<A_Z_Review__c>{
      new A_Z_Review__c(
        Id = azReviewId,
        Existing_Business_Owner__c = 'Yes',
        Business_Contact__c = 'Sample Contact'
      )
    };

    Map<Id, A_Z_Review__c> oldMap = new Map<Id, A_Z_Review__c>{
      azReviewId => new A_Z_Review__c(
        Id = azReviewId,
        Existing_Business_Owner__c = 'No',
        Business_Contact__c = 'Sample Contact'
      )
    };

    //WHEN calling a method
    Test.startTest();
    CommercialA2ZReviewActions.setBusinessContactToBlank(records, oldMap);
    Test.stopTest();

    //THEN it should set the Business contact to null
    Assert.isNull(
      records[0].Business_Contact__c,
      'should set business contact to null'
    );
  }
  @isTest
  static void populateBusinessOwnerPositiveTest() {
    registerMocks();
    //GIVEN records, oldMap
    Id azReviewId = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType);
    Id individualCustomerId = Lib_FakeIdGenerator.getMockId(
      Account.SObjectType
    );
    Id businessCustomerId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<A_Z_Review__c> records = new List<A_Z_Review__c>{
      new A_Z_Review__c(
        Id = azReviewId,
        Existing_Business_Owner__c = 'Yes',
        Customer__c = individualCustomerId,
        Customer__r = (Account) TestUtil.setFields(
          new Account(
            Id = individualCustomerId,
            Name = 'Test',
            RecordTypeId = RTAccount.personAccount
          ),
          new Map<String, Object>()
        ),
        Business_Owner__c = businessCustomerId,
        Business_Owner__r = (Account) TestUtil.setFields(
          new Account(
            Id = businessCustomerId,
            Name = 'Test2',
            RecordTypeId = RTAccount.personAccount
          ),
          new Map<String, Object>()
        )
      )
    };

    Map<Id, A_Z_Review__c> oldMap = new Map<Id, A_Z_Review__c>{
      azReviewId => new A_Z_Review__c(
        Id = azReviewId,
        Existing_Business_Owner__c = 'Yes',
        Customer__c = individualCustomerId,
        Business_Owner__c = individualCustomerId,
        Customer__r = (Account) TestUtil.setFields(
          new Account(
            Id = individualCustomerId,
            Name = 'Test',
            RecordTypeId = RTAccount.personAccount
          ),
          new Map<String, Object>()
        ),
        Business_Owner__r = (Account) TestUtil.setFields(
          new Account(
            Id = individualCustomerId,
            Name = 'Test',
            RecordTypeId = RTAccount.personAccount
          ),
          new Map<String, Object>()
        )
      )
    };
    azRepoMock.mock('getA2ZRecordsAssociatedWithIndividualCustomers', records);
    //WHEN calling a method
    Test.startTest();
    CommercialA2ZReviewActions.populateBusinessOwner(records, oldMap);
    Test.stopTest();

    Assert.areEqual(
      records[0].Business_Owner__c,
      individualCustomerId,
      'Value changed to customer'
    );
  }
  @isTest
  static void populateBusinessOwnerNegativeTest() {
    registerMocks();
    Id azReviewId = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType);
    Id individualCustomerId = Lib_FakeIdGenerator.getMockId(
      Account.SObjectType
    );
    Id businessCustomerId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<A_Z_Review__c> records = new List<A_Z_Review__c>{
      new A_Z_Review__c(
        Id = azReviewId,
        Existing_Business_Owner__c = 'Yes',
        Customer__c = businessCustomerId,
        Customer__r = (Account) TestUtil.setFields(
          new Account(
            Id = businessCustomerId,
            Name = 'Test',
            RecordTypeId = RTAccount.businessAccount
          ),
          new Map<String, Object>()
        ),
        Business_Owner__c = individualCustomerId,
        Business_Owner__r = (Account) TestUtil.setFields(
          new Account(
            Id = individualCustomerId,
            Name = 'Test2',
            RecordTypeId = RTAccount.personAccount
          ),
          new Map<String, Object>()
        )
      )
    };
    azRepoMock.mock(
      'getA2ZRecordsAssociatedWithIndividualCustomers',
      new List<A_Z_Review__c>()
    );
    //WHEN calling a method
    Test.startTest();
    CommercialA2ZReviewActions.populateBusinessOwner(records, null);
    Test.stopTest();

    Assert.areEqual(
      records[0].Business_Owner__c,
      individualCustomerId,
      'Value did not change to customer'
    );
  }
  @isTest
  static void setBusinessOwnerToBlankTest() {
    registerMocks();
    Id azReviewId = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType);
    Id individualCustomerId = Lib_FakeIdGenerator.getMockId(
      Account.SObjectType
    );
    Id businessCustomerId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<A_Z_Review__c> records = new List<A_Z_Review__c>{
      new A_Z_Review__c(
        Id = azReviewId,
        Existing_Business_Owner__c = 'No',
        Customer__c = businessCustomerId,
        Customer__r = (Account) TestUtil.setFields(
          new Account(
            Id = businessCustomerId,
            Name = 'Test',
            RecordTypeId = RTAccount.businessAccount
          ),
          new Map<String, Object>()
        ),
        Business_Owner__c = individualCustomerId,
        Business_Owner__r = (Account) TestUtil.setFields(
          new Account(
            Id = individualCustomerId,
            Name = 'Test2',
            RecordTypeId = RTAccount.personAccount
          ),
          new Map<String, Object>()
        )
      )
    };

    Map<Id, A_Z_Review__c> oldMap = new Map<Id, A_Z_Review__c>{
      azReviewId => new A_Z_Review__c(
        Id = azReviewId,
        Existing_Business_Owner__c = 'Yes',
        Customer__c = individualCustomerId,
        Business_Owner__c = individualCustomerId,
        Customer__r = (Account) TestUtil.setFields(
          new Account(
            Id = individualCustomerId,
            Name = 'Test',
            RecordTypeId = RTAccount.personAccount
          ),
          new Map<String, Object>()
        ),
        Business_Owner__r = (Account) TestUtil.setFields(
          new Account(
            Id = individualCustomerId,
            Name = 'Test',
            RecordTypeId = RTAccount.personAccount
          ),
          new Map<String, Object>()
        )
      )
    };
    //WHEN calling a method
    Test.startTest();
    CommercialA2ZReviewActions.setBusinessOwnerToBlank(records, oldMap);
    Test.stopTest();

    Assert.areEqual(
      null,
      records[0].Business_Owner__c,
      'Business Owner is not set to blank.'
    );
  }
  @isTest
  static void validateAndPopulateCLGInfoTest() {
    registerMocks();

    // GIVEN records
    Account orgRec = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      RecordTypeId = RTAccount.businessAccount,
      FirstName = 'Org',
      LastName = 'Account'
    );
    Account orgRecTwo = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      RecordTypeId = RTAccount.businessAccount,
      FirstName = 'OrgTwo',
      LastName = 'Account'
    );
    Account relatedClgRec = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      RecordTypeId = RTAccount.clgAccount,
      FirstName = 'RelatedCLG',
      LastName = 'Account'
    );
    List<A_Z_Review__c> records = new List<A_Z_Review__c>{
      new A_Z_Review__c(Customer__c = orgRec.Id)
    };
    A_Z_Review__c oldRec = new A_Z_Review__c(Customer__c = orgRecTwo.Id);
    Map<Id, A_Z_Review__c> oldMap = new Map<Id, A_Z_Review__c>{
      records[0].Id => oldRec
    };
    List<FinServ__AccountAccountRelation__c> listAAR = new List<FinServ__AccountAccountRelation__c>{
      new FinServ__AccountAccountRelation__c(
        Id = Lib_FakeIdGenerator.getMockId(
          FinServ__AccountAccountRelation__c.SObjectType
        ),
        FinServ__Account__c = orgRec.Id,
        FinServ__RelatedAccount__c = relatedClgRec.Id
      )
    };

    leadRepoMock.mock('getAccountList', new List<Account>{ orgRec });
    leadRepoMock.mock('getAccountAccountRelations', listAAR);

    // WHEN calling method
    Test.startTest();
    CommercialA2ZReviewActions.validateAndPopulateCLGInfo(records, oldMap);
    Test.stopTest();

    // THEN record should have error
    Assert.areEqual(
      records[0].hasErrors(),
      true,
      'Should have errors since no related CLG record is selected'
    );
  }
  @isTest
  static void populateCLGInfoTest() {
    registerMocks();

    // GIVEN records
    Account orgRec = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      RecordTypeId = RTAccount.businessAccount,
      FirstName = 'Org',
      LastName = 'Account'
    );
    Account relatedClgRec = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      RecordTypeId = RTAccount.clgAccount,
      FirstName = 'RelatedCLG',
      LastName = 'Account'
    );
    List<A_Z_Review__c> records = new List<A_Z_Review__c>{
      new A_Z_Review__c(Customer__c = orgRec.Id)
    };
    List<FinServ__AccountAccountRelation__c> listAAR = new List<FinServ__AccountAccountRelation__c>{
      new FinServ__AccountAccountRelation__c(
        Id = Lib_FakeIdGenerator.getMockId(
          FinServ__AccountAccountRelation__c.SObjectType
        ),
        FinServ__Account__c = orgRec.Id,
        FinServ__RelatedAccount__c = relatedClgRec.Id,
        FinServ__RelatedAccount__r = relatedClgRec
      )
    };

    leadRepoMock.mock('getAccountList', new List<Account>{ orgRec });
    leadRepoMock.mock('getAccountAccountRelations', listAAR);

    // WHEN calling method
    Test.startTest();
    CommercialA2ZReviewActions.populateCLGInfo(records);
    Test.stopTest();

    // THEN record should have error
    Assert.areEqual(
      relatedClgRec.Id,
      records[0].CLGCustomer__c,
      'Related CLG Customer should be auto populated.'
    );
  }
}
