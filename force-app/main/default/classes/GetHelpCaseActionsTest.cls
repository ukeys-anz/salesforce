/**
 * @author shawg2
 * @since Jan 2024
 * @description Test class for GetHelpCaseActions
 */
@IsTest
private class GetHelpCaseActionsTest {
  static final Faker FAKER = new Faker('en-AU');

  static final String MSG_DATE_TIME_PROVISIONALLY_CLOSED_CURRENT_DATE = 'Date_Time_Provisionally_Closed__c should be the current date and time';
  static final String MSG_DATE_TIME_PROVISIONALLY_CLOSED_NULL = 'Date_Time_Provisionally_Closed__c should be null';

  static Id caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
  static final String EXTERNAL_SYSTEM_VALUE = 'Pega_Smarts';
  static final String EXTERNAL_CASE_ID = FAKER.randomString(10);

  //Used as oldMap case record
  static Case case0 = new Case(
    Status = GetHelpConstants.OPEN_STATUS,
    External_System__c = EXTERNAL_SYSTEM_VALUE,
    External_Case_ID__c = EXTERNAL_CASE_ID,
    Id = caseId,
    RecordTypeId = RTCase.cardDispute
  );

  static Case case1 = new Case(
    Status = GetHelpConstants.PROVISIONALLY_CLOSED_STATUS,
    External_System__c = EXTERNAL_SYSTEM_VALUE,
    External_Case_ID__c = EXTERNAL_CASE_ID,
    Id = caseId,
    RecordTypeId = RTCase.cardDispute
  );

  static Case case2 = new Case(
    Status = GetHelpConstants.PROVISIONALLY_CLOSED_STATUS,
    External_System__c = EXTERNAL_SYSTEM_VALUE,
    External_Case_ID__c = EXTERNAL_CASE_ID,
    Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    RecordTypeId = RTCase.cardDispute
  );

  static Case case3 = new Case(
    Status = GetHelpConstants.OPEN_STATUS,
    External_System__c = EXTERNAL_SYSTEM_VALUE,
    External_Case_ID__c = FAKER.randomString(10),
    Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    RecordTypeId = RTCase.cardDispute
  );

  @IsTest
  static void setOwnerToIDOpsQueue() {
    Account oAccount = TestDataFactory.createAccount(true);

    List<Case> lstCases = new List<Case>{
      new Case(
        AccountId = oAccount.Id,
        RecordTypeId = RTCase.profileUpdate,
        Type = GetHelpConstants.RESIDENTIAL_ADDRESS_QA,
        Status = GetHelpConstants.OPEN_STATUS
      ),
      new Case(AccountId = oAccount.Id, RecordTypeId = RTCase.generalInquiry)
    };

    Test.startTest();
    GetHelpCaseActions.setOwnerToIDOpsQueue(lstCases);
    Test.stopTest();

    for (Case oCase : lstCases) {
      if (oCase.RecordTypeId == RTCase.profileUpdate) {
        Assert.areEqual(
          GetHelpCaseActions.idOpsQueue.Id,
          oCase.OwnerId,
          'Profile Update cases should be assigned to the ID Ops Queue on insert'
        );
      } else {
        Assert.areNotEqual(
          GetHelpCaseActions.idOpsQueue.Id,
          oCase.OwnerId,
          'Non-Profile Update cases should not be assigned to ID Ops Queue on insert'
        );
      }
    }
  }

  @isTest
  public static void testCaseProvisionallyClosedDateTimeUpdateScenario() {
    List<Case> cases = new List<Case>{ case1, case2, case3 };
    Map<Id, Case> oldMap = new Map<Id, Case>{ case0.Id => case0 };

    Test.startTest();
    GetHelpCaseActions.handleProvisionallyClosedDateTimeField(oldMap, cases);
    Test.stopTest();

    Assert.areEqual(
      case1.Date_Time_Provisionally_Closed__c,
      DateTime.now(),
      MSG_DATE_TIME_PROVISIONALLY_CLOSED_CURRENT_DATE
    );
    Assert.areEqual(
      case2.Date_Time_Provisionally_Closed__c,
      DateTime.now(),
      MSG_DATE_TIME_PROVISIONALLY_CLOSED_CURRENT_DATE
    );
    Assert.areEqual(
      case3.Date_Time_Provisionally_Closed__c,
      null,
      MSG_DATE_TIME_PROVISIONALLY_CLOSED_NULL
    );
  }

  @isTest
  public static void testCaseProvisionallyClosedDateTimeInsertScenario() {
    List<Case> cases = new List<Case>{ case0, case2 };

    Test.startTest();
    GetHelpCaseActions.handleProvisionallyClosedDateTimeField(null, cases);
    Test.stopTest();

    Assert.areEqual(
      case0.Date_Time_Provisionally_Closed__c,
      null,
      MSG_DATE_TIME_PROVISIONALLY_CLOSED_NULL
    );
    Assert.areEqual(
      case2.Date_Time_Provisionally_Closed__c,
      DateTime.now(),
      MSG_DATE_TIME_PROVISIONALLY_CLOSED_CURRENT_DATE
    );
  }
}
