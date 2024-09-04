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

  //#region `ListUtil.toSet`
  @IsTest
  static void testToSetFromListInteger() {
    Assert.areEqual(
      new Set<Object>{ 1 },
      ListUtil.toSet(new List<Integer>{ 1 }),
      'Should convert List<Integer> to Set<Object>'
    );
  }

  @IsTest
  static void testToSetFromListObject() {
    Assert.areEqual(
      new Set<Object>{ '1' },
      ListUtil.toSet(new List<Object>{ '1' }),
      'Should convert List<Object> to Set<Object>'
    );
  }

  @IsTest
  static void testToSetFromSetInteger() {
    Assert.areEqual(
      new Set<Object>{ 1 },
      ListUtil.toSet(new Set<Integer>{ 1 }),
      'Should convert Set<Integer> to Set<Object>'
    );
  }

  @IsTest
  static void testToSetFromSetObject() {
    Assert.areEqual(
      new Set<Object>{ '1' },
      ListUtil.toSet(new Set<Object>{ '1' }),
      'Should convert Set<Object> to Set<Object>'
    );
  }

  @IsTest
  static void testToSetFromInteger() {
    Assert.areEqual(
      new Set<Object>{ 1 },
      ListUtil.toSet(1),
      'Should convert Integer to Set<Object>'
    );
  }

  @IsTest
  static void testToSetFromString() {
    Assert.areEqual(
      new Set<Object>{ '1' },
      ListUtil.toSet('1'),
      'Should convert String to Set<Object>'
    );
  }
  //#endregion

  //#region Filter tests
  static Set<SObjectField> accountFields = new Set<SObjectField>{
    Account.Id,
    Account.Name,
    Account.NumberOfEmployees
  };
  static List<Account> accounts = new List<Account>{
    new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = FAKER.randomString(5),
      NumberOfEmployees = FAKER.randomInteger(2)
    ),
    new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = FAKER.randomString(5),
      NumberOfEmployees = FAKER.randomInteger(2)
    ),
    new Account(Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType))
  };

  static Map<Id, Account> oldMap = new Map<Id, Account>{
    accounts[0].Id => accounts[0].clone(true, true, true, true),
    accounts[1].Id => accounts[1].clone(true, true, true, true)
  };

  @IsTest
  static void testFilterNoError() {
    accounts[1].addError('Error');

    Test.startTest();
    List<Account> records = ListUtil.filter(accounts).noError().toList();
    Test.stopTest();

    Assert.areEqual(2, records.size(), 'Should return 2 record');
    Assert.isFalse(
      records[0].hasErrors(),
      'Should return the record without error'
    );
  }

  @IsTest
  static void testFilterChanged() {
    accounts[0].Name = FAKER.randomString(6);
    accounts[0].NumberOfEmployees = FAKER.randomInteger(1);
    accounts[1].Name = FAKER.randomString(6);

    Test.startTest();
    List<Account> results = ListUtil.filter(accounts, oldMap)
      .changed(Account.Name)
      .changed(Account.NumberOfEmployees)
      .toList();
    Test.stopTest();

    Assert.areEqual(
      new List<Account>{ accounts[0], accounts[2] },
      results,
      'Expected accounts that is either have updated Name & NumberOfEmployees, or no prior record'
    );
  }

  @IsTest
  static void testFilterFieldEquals() {
    Test.startTest();
    List<Account> results = ListUtil.filter(accounts)
      .equals(
        Account.Name,
        new Set<Object>{ accounts[0].Name, FAKER.randomString(5) }
      )
      .toList();
    Test.stopTest();

    Assert.areEqual(
      new List<Account>{ accounts[0] },
      results,
      'Expected accounts with specified Name'
    );
  }

  @IsTest
  static void testFilterFieldNotEquals() {
    Test.startTest();
    List<Account> results = ListUtil.filter(accounts)
      .notEquals(
        Account.Name,
        new Set<Object>{ accounts[0].Name, FAKER.randomString(5) }
      )
      .toList();
    Test.stopTest();

    Assert.areEqual(
      new List<Account>{ accounts[1], accounts[2] },
      results,
      'Expected accounts without specified Name'
    );
  }

  @IsTest
  static void testFilterIsNull() {
    Test.startTest();
    List<Account> results = ListUtil.filter(accounts)
      .isNull(Account.Name)
      .toList();
    Test.stopTest();

    Assert.areEqual(
      new List<Account>{ accounts[2] },
      results,
      'Expected accounts without name'
    );
  }

  @IsTest
  static void testFilterIsNotNull() {
    Test.startTest();
    List<Account> results = ListUtil.filter(accounts)
      .isNotNull(Account.Name)
      .toList();
    Test.stopTest();

    Assert.areEqual(
      new List<Account>{ accounts[0], accounts[1] },
      results,
      'Expected accounts with name'
    );
  }

  @IsTest
  static void testFilterAllNotNull() {
    Test.startTest();
    List<Account> results = ListUtil.filter(accounts)
      .allNotNull(accountFields)
      .toList();
    Test.stopTest();

    Assert.areEqual(
      new List<Account>{ accounts[0], accounts[1] },
      results,
      'Expected accounts with name'
    );
  }

  @IsTest
  static void testFilterFieldContains() {
    Test.startTest();
    List<Account> results = ListUtil.filter(accounts)
      .contains(Account.Name, accounts[1].Name.substring(0, 3))
      .toList();
    Test.stopTest();

    Assert.areEqual(
      new List<Account>{ accounts[1] },
      results,
      'Expected first account'
    );
  }

  @IsTest
  static void testFilterOldFieldEquals() {
    Set<Object> values = new Set<Object>{
      accounts[1].Name,
      FAKER.randomString(5)
    };

    Test.startTest();
    List<Account> results = ListUtil.filter(accounts, oldMap)
      .oldEquals(Account.Name, values)
      .toList();
    Test.stopTest();

    Assert.areEqual(
      new List<Account>{ accounts[1] },
      results,
      'Expected accounts with specified Name'
    );
  }

  @IsTest
  static void testFilterAnyMatch() {
    Test.startTest();
    List<Account> results = ListUtil.filter(accounts)
      .anyEqual(accountFields, accounts[1].Name)
      .toList();
    Test.stopTest();

    Assert.areEqual(
      new List<Account>{ accounts[1] },
      results,
      'Expected accounts with specified Name'
    );
  }
  //#endregion
}
