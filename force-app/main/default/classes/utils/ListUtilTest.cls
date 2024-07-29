@IsTest
private class ListUtilTest {
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
    Faker faker = new Faker('AU');

    List<Case> cases = new List<Case>{
      new Case(PersonaId__c = faker.randomString(10)),
      new Case(),
      new Case(PersonaId__c = faker.randomString(11))
    };

    Test.startTest();
    Set<String> personaIds = ListUtil.getStrings(cases, Case.PersonaId__c);
    Test.stopTest();

    Assert.areEqual(
      new Set<String>{ cases[0].PersonaId__c, cases[2].PersonaId__c },
      personaIds,
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
    Faker faker = new Faker('AU');

    List<Case> cases = new List<Case>{
      new Case(PersonaId__c = faker.randomString(10)),
      new Case(),
      new Case(PersonaId__c = faker.randomString(11))
    };

    Test.startTest();
    Map<String, Case> recordMap = (Map<String, Case>) ListUtil.mapByString(
      cases,
      Case.PersonaId__c
    );
    Test.stopTest();

    Assert.areEqual(
      new Map<String, Case>{
        cases[0].PersonaId__c => cases[0],
        cases[2].PersonaId__c => cases[2]
      },
      recordMap,
      'Should return 2 key-value pairs'
    );
  }
}
