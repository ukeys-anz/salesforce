@IsTest
private class AutoKYCQARestraintTest {
  static final Faker FAKER = new Faker('en-AU');

  static Account acc = (Account) TestUtil.setFields(
    new Account(),
    new Map<String, Object>{
      'FinServ__ClientFinancialAccounts__r' => new List<FinServ__FinancialAccount__c>{
        new FinServ__FinancialAccount__c(
          FinServ__FinancialAccountNumber__c = FAKER.randomString(5),
          Product_Type__c = 'CAP_CIS:DDA'
        )
      }
    }
  );
  static Case kycQaCase = (Case) TestUtil.setFields(
    new Case(),
    new Map<String, Object>{ 'CaseNumber' => FAKER.randomString(6) }
  );
  static Map<Id, Case> mapAccToCase = new Map<Id, Case>{ acc.Id => kycQaCase };
  static AutoKYCQARestraintHandler handler {
    get {
      return new AutoKYCQARestraintHandler();
    }
  }

  @IsTest
  static void testProcess() {
    Lib_MockProvider.forType(AutoKYCQACaseRepository.class)
      .mock('isRestraintEnabled', true);
    Lib_MockProvider stagingHandlerMock = Lib_MockProvider.forType(
      ProfileStagingHandler.class
    );

    Test.startTest();
    handler.process(new List<Account>{ acc }, mapAccToCase);
    Test.stopTest();

    Assert.isNotNull(
      stagingHandlerMock.getHistory('process'),
      'Should call ProfileStagingHandler.process'
    );
  }

  @IsTest
  static void testGenerateUpdates() {
    Test.startTest();
    List<Customer_Profile_Updates__c> updates = handler.generateUpdates(
      new List<Account>{ acc },
      mapAccToCase
    );
    Test.stopTest();

    Assert.areEqual(2, updates.size(), 'Should generate 2 updates');
  }

  @IsTest
  static void testGenerateUpdate() {
    FinServ__FinancialAccount__c fa = acc.FinServ__ClientFinancialAccounts__r[0];
    Test.startTest();
    Customer_Profile_Updates__c cpu = handler.generateUpdate(fa, kycQaCase, 60);
    Test.stopTest();

    Assert.areEqual(
      'Case.KYC_QA.AddRestraints',
      cpu.TriggeredFrom__c,
      'Incorrect TriggeredFrom__c'
    );
  }

  @IsTest
  static void testCreateRestraintPayload() {
    FinServ__FinancialAccount__c fa = acc.FinServ__ClientFinancialAccounts__r[0];
    Test.startTest();
    String record = handler.createRestraintPayload(fa, 60);
    Test.stopTest();

    Assert.isTrue(
      record.contains('"productCode":"DDA"'),
      'Incorrect productCode'
    );
  }
}
