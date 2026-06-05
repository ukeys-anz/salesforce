/**
 * @description Test class for CustomerSummaryController.
 */
@IsTest
private class CustomerSummaryControllerTest {
  private static Account createAccount() {
    // Follow existing project test patterns: create a mock Account without DML using Lib_FakeIdGenerator
    return new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = 'Test Account'
    );
  }

  /**
   * @description Tests all generate* methods return mocked HTML when PromptUtils.mockResponseText is set to a non-blank value.
   */
  @IsTest
  static void testGenerateMethodsWithNonBlankResponse() {
    Account acct = createAccount();

    // Set PromptUtils test hook to return a non-blank HTML fragment
    String expectedHtml = '<div>Generated summary for ' + acct.Id + '</div>';
    PromptUtils.mockResponseText = expectedHtml;

    Test.startTest();
    String res2 = CustomerSummaryController.generateKeyDisscussionPoints(
      acct.Id
    );
    String res3 = CustomerSummaryController.generateAccountSnapshotAndDiaryComments(
      acct.Id
    );
    String res4 = CustomerSummaryController.generateOpportunitiesAndLeads(
      acct.Id
    );
    String res5 = CustomerSummaryController.generateOtherAndTasks(acct.Id);
    Test.stopTest();

    System.assertEquals(
      expectedHtml,
      res2,
      'generateKeyDisscussionPoints should return mocked HTML'
    );
    System.assertEquals(
      expectedHtml,
      res3,
      'generateAccountSnapshotAndDiaryComments should return mocked HTML'
    );
    System.assertEquals(
      expectedHtml,
      res4,
      'generateOpportunitiesAndLeads should return mocked HTML'
    );
    System.assertEquals(
      expectedHtml,
      res5,
      'generateOtherAndTasks should return mocked HTML'
    );

    // Clean up
    PromptUtils.mockResponseText = null;
  }
}
