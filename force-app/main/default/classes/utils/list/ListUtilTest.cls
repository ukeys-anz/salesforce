
@IsTest
private class ListUtilTest {
  static final Faker FAKER = new Faker('AU');

  /**
   * @description Represents a custom implementation of the MyAccount class that implements the GenericObject interface.
   */
  public class MyAccount implements GenericObject {
    public Id id;
    public String name;
    public Integer numberOfEmployees;

    /**
     * @description Returns the value of the specified field.
     * @param fieldName The name of the field to retrieve the value for.
     * @return The value of the specified field.
     */
    public Object get(String fieldName) {
      switch on fieldName {
        when 'id' {
          return this.id;
        }
        when 'name' {
          return this.name;
        }
        when 'numberOfEmployees' {
          return this.numberOfEmployees;
        }
      }
      throw new IllegalArgumentException(
        'Field not yet supported: ' + fieldName
      );
    }

    MyAccount(Id recordId, String name, Integer numberOfEmployees) {
      this.id = recordId;
      this.name = name;
      this.numberOfEmployees = numberOfEmployees;
    }
  }
  //#region SObject Utilities Tests
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
    Map<Id, Case> recordMap = (Map<Id, Case>) ListUtil.mapBy(
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
    Map<String, Case> recordMap = (Map<String, Case>) ListUtil.mapBy(
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
  static void testGroupBy() {
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Case> cases = new List<Case>{
      new Case(AccountId = accountId, Subject = FAKER.randomString(10)),
      new Case(),
      new Case(AccountId = accountId, Subject = FAKER.randomString(11))
    };

    Test.startTest();
    Map<Id, List<Case>> recordMap = (Map<Id, List<Case>>) ListUtil.groupBy(
      cases,
      Case.AccountId
    );
    Test.stopTest();

    Assert.areEqual(
      new Map<Id, List<Case>>{
        accountId => new List<Case>{ cases[0], cases[2] }
      },
      recordMap,
      'Should return 1 group with 2 records'
    );
  }
  //#endregion

  //#region Generic Utilities Tests
  @IsTest
  static void testGenericGetValues() {
    List<MyAccount> myAccounts = new List<MyAccount>{
      new MyAccount(null, FAKER.randomString(10), null),
      new MyAccount(null, null, null),
      new MyAccount(null, FAKER.randomString(11), null)
    };

    Test.startTest();
    List<String> subjects = (List<String>) ListUtil.getValues(
      myAccounts,
      'name',
      String.class
    );
    Test.stopTest();

    Assert.areEqual(
      new List<String>{ myAccounts[0].name, myAccounts[2].name },
      subjects,
      'Should return 2 values'
    );
  }

  @IsTest
  static void testGenericGetIds() {
    List<MyAccount> myAccounts = new List<MyAccount>{
      new MyAccount(
        Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        null,
        null
      ),
      new MyAccount(
        Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        null,
        null
      ),
      new MyAccount(null, null, null)
    };

    Test.startTest();
    Set<Id> accountIds = (Set<Id>) ListUtil.getUniques(
      myAccounts,
      'id',
      Id.class
    );
    Test.stopTest();

    Assert.areEqual(
      new Set<Id>{ myAccounts[0].id, myAccounts[1].id },
      accountIds,
      'Should return 2 Account Ids'
    );
  }

  @IsTest
  static void testGenericGetStrings() {
    List<MyAccount> myAccounts = new List<MyAccount>{
      new MyAccount(null, FAKER.randomString(10), null),
      new MyAccount(null, null, null),
      new MyAccount(null, FAKER.randomString(11), null)
    };

    Test.startTest();
    Set<String> subjects = (Set<String>) ListUtil.getUniques(
      myAccounts,
      'name',
      String.class
    );
    Test.stopTest();

    Assert.areEqual(
      new Set<String>{ myAccounts[0].name, myAccounts[2].name },
      subjects,
      'Should return 2 values'
    );
  }

  @IsTest
  static void testGenericBuildIdMap() {
    List<MyAccount> myAccounts = new List<MyAccount>{
      new MyAccount(
        Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        null,
        null
      ),
      new MyAccount(null, null, null),
      new MyAccount(
        Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        null,
        null
      )
    };

    Test.startTest();
    Map<Id, MyAccount> recordMap = (Map<Id, MyAccount>) ListUtil.mapBy(
      myAccounts,
      'id',
      Id.class
    );
    Test.stopTest();

    Assert.areEqual(
      new Map<Id, MyAccount>{
        myAccounts[0].id => myAccounts[0],
        myAccounts[2].id => myAccounts[2]
      },
      recordMap,
      'Should return 2 key-value pairs'
    );
  }

  @IsTest
  static void testGenericBuildStringMap() {
    List<MyAccount> myAccounts = new List<MyAccount>{
      new MyAccount(null, FAKER.randomString(10), null),
      new MyAccount(null, null, null),
      new MyAccount(null, FAKER.randomString(11), null)
    };

    Test.startTest();
    Map<String, MyAccount> recordMap = (Map<String, MyAccount>) ListUtil.mapBy(
      myAccounts,
      'name',
      String.class
    );
    Test.stopTest();

    Assert.areEqual(
      new Map<String, MyAccount>{
        myAccounts[0].name => myAccounts[0],
        myAccounts[2].name => myAccounts[2]
      },
      recordMap,
      'Should return 2 key-value pairs'
    );
  }

  @IsTest
  static void testGenericGroupBy() {
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<MyAccount> myAccounts = new List<MyAccount>{
      new MyAccount(accountId, FAKER.randomString(10), null),
      new MyAccount(null, null, null),
      new MyAccount(accountId, FAKER.randomString(11), null)
    };

    Test.startTest();
    Map<Id, List<MyAccount>> recordMap = (Map<Id, List<MyAccount>>) ListUtil.groupBy(
      myAccounts,
      'id',
      Id.class
    );
    Test.stopTest();

    Assert.areEqual(
      new Map<Id, List<MyAccount>>{
        accountId => new List<MyAccount>{ myAccounts[0], myAccounts[2] }
      },
      recordMap,
      'Should return 1 group with 2 records'
    );
  }
  //#endregion

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

  //#region SObject Filter tests
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
  static void testFilterFieldNotContains() {
    Test.startTest();
    List<Account> results = ListUtil.filter(accounts)
      .notContains(Account.Name, accounts[0].Name.substring(0, 3))
      .toList();
    Test.stopTest();

    Assert.areEqual(
      new List<Account>{ accounts[1], accounts[2] },
      results,
      'Expected accounts without specified Name'
    );

    Assert.areEqual(
      accounts[1].Name,
      results[0].Name,
      'Expected accounts without specified Name'
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
  static void testFilterOldFieldNotEquals() {
    Set<Object> values = new Set<Object>{
      accounts[0].Name,
      FAKER.randomString(5)
    };

    Test.startTest();
    List<Account> results = ListUtil.filter(accounts, oldMap)
      .oldNotEquals(Account.Name, values)
      .toList();
    Test.stopTest();

    Assert.areEqual(
      new List<Account>{ accounts[1], accounts[2] },
      results,
      'Expected accounts without specified Name'
    );

    Assert.areEqual(
      accounts[1].Name,
      results[0].Name,
      'Expected accounts without specified Name'
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

  //#region Generic Filter tests
  static Set<String> myAccountFields = new Set<String>{
    'id',
    'name',
    'numberOfEmployees'
  };

  static List<MyAccount> myAccounts = new List<MyAccount>{
    new MyAccount(
      Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      FAKER.randomString(5),
      FAKER.randomInteger(2)
    ),
    new MyAccount(
      Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      FAKER.randomString(5),
      FAKER.randomInteger(2)
    ),
    new MyAccount(
      Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      null,
      null
    )
  };

  @IsTest
  static void testGenericFilterFieldEquals() {
    Test.startTest();
    List<MyAccount> results = (List<MyAccount>) ListUtil.filter(myAccounts)
      .equals(
        'name',
        new Set<Object>{ myAccounts[0].Name, FAKER.randomString(5) }
      )
      .toList();
    Test.stopTest();

    Assert.areEqual(
      new List<MyAccount>{ myAccounts[0] },
      results,
      'Expected myAccounts with specified Name'
    );
  }

  @IsTest
  static void testGenericFilterFieldNotEquals() {
    Test.startTest();
    List<MyAccount> results = (List<MyAccount>) ListUtil.filter(myAccounts)
      .notEquals(
        'name',
        new Set<Object>{ myAccounts[0].Name, FAKER.randomString(5) }
      )
      .toList();
    Test.stopTest();

    Assert.areEqual(
      new List<MyAccount>{ myAccounts[1], myAccounts[2] },
      results,
      'Expected myAccounts without specified Name'
    );
  }

  @IsTest
  static void testGenericFilterIsNull() {
    Test.startTest();
    List<MyAccount> results = (List<MyAccount>) ListUtil.filter(myAccounts)
      .isNull('name')
      .toList();
    Test.stopTest();

    Assert.areEqual(
      new List<MyAccount>{ myAccounts[2] },
      results,
      'Expected myAccounts without name'
    );
  }

  @IsTest
  static void testGenericFilterIsNotNull() {
    Test.startTest();
    List<MyAccount> results = (List<MyAccount>) ListUtil.filter(myAccounts)
      .isNotNull('name')
      .toList();
    Test.stopTest();

    Assert.areEqual(
      new List<MyAccount>{ myAccounts[0], myAccounts[1] },
      results,
      'Expected myAccounts with name'
    );
  }

  @IsTest
  static void testGenericFilterAllNotNull() {
    Test.startTest();
    List<MyAccount> results = (List<MyAccount>) ListUtil.filter(myAccounts)
      .allNotNull(myAccountFields)
      .toList();
    Test.stopTest();

    Assert.areEqual(
      new List<MyAccount>{ myAccounts[0], myAccounts[1] },
      results,
      'Expected myAccounts with name'
    );
  }

  @IsTest
  static void testGenericFilterFieldContains() {
    Test.startTest();
    List<MyAccount> results = (List<MyAccount>) ListUtil.filter(myAccounts)
      .contains('name', myAccounts[1].Name.substring(0, 3))
      .toList();
    Test.stopTest();

    Assert.areEqual(
      new List<MyAccount>{ myAccounts[1] },
      results,
      'Expected first account'
    );
  }

  @IsTest
  static void testGenericFilterFieldNotContains() {
    Test.startTest();
    List<MyAccount> results = (List<MyAccount>) ListUtil.filter(myAccounts)
      .notContains('name', myAccounts[1].Name.substring(0, 3))
      .toList();
    Test.stopTest();

    Assert.areEqual(
      new List<MyAccount>{ myAccounts[0], myAccounts[2] },
      results,
      'Expected first account'
    );

    Assert.areEqual(
      myAccounts[0].Name,
      results[0].Name,
      'Expected accounts without specified Name'
    );
  }

  @IsTest
  static void testGenericFilterAnyMatch() {
    Test.startTest();
    List<MyAccount> results = (List<MyAccount>) ListUtil.filter(myAccounts)
      .anyEqual(myAccountFields, myAccounts[1].Name)
      .toList();
    Test.stopTest();

    Assert.areEqual(
      new List<MyAccount>{ myAccounts[1] },
      results,
      'Expected myAccounts with specified Name'
    );
  }
  //#endregion
}
