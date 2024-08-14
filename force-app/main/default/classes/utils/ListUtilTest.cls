/**
 * @description       : 
 * @author            : Madhuri Edke | Salesforce
 * @group             : 
 * @last modified on  : 08-13-2024
 * @last modified by  : Madhuri Edke | Salesforce
**/
@IsTest
private class ListUtilTest {
  static final Faker FAKER = new Faker('AU');

  @IsTest
  static void testGetPrimitiveType() {
    Assert.areEqual(
      String.class,
      ListUtil.getPrimitiveType(Case.Status),
      'Should be String type'
    );
    Assert.areEqual(
      Id.class,
      ListUtil.getPrimitiveType(Case.Id),
      'Should be Id type'
    );
    Assert.areEqual(
      Id.class,
      ListUtil.getPrimitiveType(Case.AccountId),
      'Should be Id type'
    );
    Assert.areEqual(
      DateTime.class,
      ListUtil.getPrimitiveType(Case.CreatedDate),
      'Should be DateTime type'
    );
  }

  @IsTest
  static void testGetValues() {
    List<Case> cases = new List<Case>{
      new Case(Subject = FAKER.randomString(10)),
      new Case(),
      new Case(Subject = FAKER.randomString(11))
    };

    Test.startTest();
    List<String> subjects = (List<String>) ListUtil.getValues(
      cases,
      Case.Subject
    );
    Test.stopTest();

    Assert.areEqual(
      new List<String>{ cases[0].Subject, cases[2].Subject },
      subjects,
      'Should return 2 values'
    );
  }

  @IsTest
  static void testGetIds() {
    List<Case> cases = new List<Case>{
      new Case(AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType)),
      new Case(AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType)),
      new Case()
    };

    Test.startTest();
    Set<Id> accountIds = ListUtil.getIds(cases, Case.AccountId);
    Test.stopTest();

    Assert.areEqual(
      new Set<Id>{ cases[0].AccountId, cases[1].AccountId },
      accountIds,
      'Should return 2 Account Ids'
    );
  }

  @IsTest
  static void testGetStrings() {
    List<Case> cases = new List<Case>{
      new Case(Subject = FAKER.randomString(10)),
      new Case(),
      new Case(Subject = FAKER.randomString(11))
    };

    Test.startTest();
    Set<String> subjects = ListUtil.getStrings(cases, Case.Subject);
    Test.stopTest();

    Assert.areEqual(
      new Set<String>{ cases[0].Subject, cases[2].Subject },
      subjects,
      'Should return 2 values'
    );
  }

  @IsTest
  static void testBuildIdMap() {
    List<Case> cases = new List<Case>{
      new Case(AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType)),
      new Case(),
      new Case(AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType))
    };

    Test.startTest();
    Map<Id, Case> recordMap = (Map<Id, Case>) ListUtil.mapById(
      cases,
      Case.AccountId
    );
    Test.stopTest();

    Assert.areEqual(
      new Map<Id, Case>{
        cases[0].AccountId => cases[0],
        cases[2].AccountId => cases[2]
      },
      recordMap,
      'Should return 2 key-value pairs'
    );
  }

  @IsTest
  static void testBuildStringMap() {
    List<Case> cases = new List<Case>{
      new Case(Subject = FAKER.randomString(10)),
      new Case(),
      new Case(Subject = FAKER.randomString(11))
    };

    Test.startTest();
    Map<String, Case> recordMap = (Map<String, Case>) ListUtil.mapByString(
      cases,
      Case.Subject
    );
    Test.stopTest();

    Assert.areEqual(
      new Map<String, Case>{
        cases[0].Subject => cases[0],
        cases[2].Subject => cases[2]
      },
      recordMap,
      'Should return 2 key-value pairs'
    );
  }

  @IsTest
  static void testFilterNoError() {
    Case caseWithError = new Case();
    caseWithError.addError('Error');
    List<Case> cases = new List<Case>{ new Case(), caseWithError };
    Test.startTest();
    List<Case> records = ListUtil.filterNoError(cases);
    Test.stopTest();
    Assert.areEqual(1, records.size(), 'Should return 1 record');
    Assert.isFalse(
      records[0].hasErrors(),
      'Should return the record without error'
    );
  }
}
