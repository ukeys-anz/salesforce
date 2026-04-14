/**
 * @author       : Amisha Gyani
 * @since        : January, 2026
 * @description  : Test class for CCRMAgentCapDiaryCommentsPrompt invocable Apex class
 **/
@IsTest
private class CCRMAgentCapDiaryCommentsPromptTest {
  static Lib_MockProvider repoMock;
  /**
   * @description Registers the mock repository for diary comments
   */
  static void registerMocks() {
    repoMock = Lib_MockProvider.forType(CCRMAgentforceRepository.class);
  }

  /**
   * @description Helper method to format Date as DD/MM/YYYY
   * @param d The Date to format.
   * @return A string representation of the date in DD/MM/YYYY format.
   */
  private static String formatDate(Date d) {
    String dayStr = d.day() < 10
      ? '0' + String.valueOf(d.day())
      : String.valueOf(d.day());
    String monthStr = d.month() < 10
      ? '0' + String.valueOf(d.month())
      : String.valueOf(d.month());
    String yearStr = String.valueOf(d.year());
    return dayStr + '/' + monthStr + '/' + yearStr;
  }

  /**
   * @description Positive test: Validate output JSON contains comments filtered by description
   *              Expiry dates are in the future so no comments are excluded due to expiry
   */
  @IsTest
  static void testGetDiaryCommentsPositive() {
    registerMocks();
    // Create Account with Salesforce ID and random External ID
    Faker faker = new Faker('AU');
    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      External_Id__c = faker.randomString(18),
      Name = faker.randomString(6),
      RecordTypeId = RTAccount.clgAccount
    );

    // Create mock Diary Comments with future expiry
    List<Diary_Comment__x> comments = new List<Diary_Comment__x>{
      new Diary_Comment__x(
        Description__c = 'Permanent comment',
        Account__c = acc.Id,
        Permanent__c = true,
        Date_Placed__c = formatDate(Date.today().addMonths(-6)),
        Expiry_Date__c = formatDate(Date.today().addDays(30))
      ),
      new Diary_Comment__x(
        Description__c = 'Recent comment 1',
        Account__c = acc.Id,
        Permanent__c = false,
        Date_Placed__c = formatDate(Date.today().addMonths(-10)),
        Expiry_Date__c = formatDate(Date.today().addDays(30))
      ),
      new Diary_Comment__x(
        Description__c = 'CCR CHANGED FROM something',
        Account__c = acc.Id,
        Permanent__c = false,
        Date_Placed__c = formatDate(Date.today().addMonths(-6)),
        Expiry_Date__c = formatDate(Date.today().addDays(30))
      )
    };

    repoMock.mock('fetchDiaryCommentsForExternalId', comments);
    // Prepare request
    CCRMAgentCapDiaryCommentsPrompt.Request req = new CCRMAgentCapDiaryCommentsPrompt.Request();
    req.accountObj = acc;

    Test.startTest();
    List<CCRMAgentCapDiaryCommentsPrompt.Response> results = CCRMAgentCapDiaryCommentsPrompt.getDiaryComments(
      new List<CCRMAgentCapDiaryCommentsPrompt.Request>{ req }
    );
    Test.stopTest();
    // Assertions
    Assert.areEqual(
      1,
      results.size(),
      'Response wrapper must return exactly 1 item.'
    );

    Assert.isNotNull(results[0].Prompt, 'Prompt should not be null.');
  }

  /**
   * @description Negative test: Null or empty input list
   */
  @IsTest
  static void testGetDiaryCommentsNullInput() {
    registerMocks();

    Test.startTest();
    List<CCRMAgentCapDiaryCommentsPrompt.Response> results = CCRMAgentCapDiaryCommentsPrompt.getDiaryComments(
      new List<CCRMAgentCapDiaryCommentsPrompt.Request>()
    );
    Test.stopTest();

    // Assertions
    Assert.areEqual(
      'No Account provided.',
      results[0].Prompt,
      'Null or empty input should return error message.'
    );
  }

  /**
   * @description Negative test: Account without External ID
   */
  @IsTest
  static void testGetDiaryCommentsAccountWithoutExternalId() {
    registerMocks();
    // Create Account WITHOUT External ID
    Faker faker = new Faker('AU');
    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = faker.randomString(6),
      RecordTypeId = RTAccount.clgAccount
    );

    // Prepare request
    CCRMAgentCapDiaryCommentsPrompt.Request req = new CCRMAgentCapDiaryCommentsPrompt.Request();
    req.accountObj = acc;

    Test.startTest();
    List<CCRMAgentCapDiaryCommentsPrompt.Response> results = CCRMAgentCapDiaryCommentsPrompt.getDiaryComments(
      new List<CCRMAgentCapDiaryCommentsPrompt.Request>{ req }
    );
    Test.stopTest();

    // Assertions
    Assert.areEqual(
      'Account External ID is missing. Unable to fetch CAP Diary Comments.',
      results[0].Prompt,
      'Expected error message when External ID is missing.'
    );
  }
}
