@IsTest
private class AutoKYCQAUnrestraintTest {
  static final Faker FAKER = new Faker('en-AU');

  static CustomerRestraintModel oldPayload {
    get {
      if (oldPayload != null) {
        return oldPayload;
      }
      oldPayload = new CustomerRestraintModel();
      oldPayload.accountNumber = FAKER.randomString(5);
      oldPayload.productCode = 'DDA';
      oldPayload.restraints.restraintClass = 1;
      oldPayload.restraints.restraintType = 60;
      oldPayload.restraints.datePlaced = DateTime.now().format('YYYY-MM-dd');
      oldPayload.restraints.dateExpires = '';
      return oldPayload;
    }
    set;
  }

  static Account constructAccount(String restraintAction, String status) {
    return (Account) TestUtil.setFields(
      new Account(),
      new Map<String, Object>{
        'Customer_Profile_Updates__r' => new List<Customer_Profile_Updates__c>{
          new Customer_Profile_Updates__c(
            TriggeredFrom__c = 'Case.KYC_QA.' + restraintAction + 'Restraints',
            NewValue__c = 'Apply Restraints Type 60 of Class Hard Hold',
            Name = 'KYC QA Case ' +
              FAKER.randomString(6) +
              ' ' +
              restraintAction +
              ' Type 60 Restraint on ' +
              FAKER.randomString(5),
            Occurrence_Number__c = FAKER.randomInteger(4),
            ToBeValue__c = JSON.serialize(oldPayload),
            LastModifiedDate = DateTime.now(),
            Status__c = status
          )
        }
      }
    );
  }
  static AutoKYCQAUnrestraintHandler handler {
    get {
      return new AutoKYCQAUnrestraintHandler();
    }
  }

  @IsTest
  static void testProcess() {
    Lib_MockProvider.forType(AutoKYCQACaseRepository.class)
      .mock('isRestraintEnabled', true);
    Lib_MockProvider stagingHandlerMock = Lib_MockProvider.forType(
      ProfileStagingHandler.class
    );

    Account acc = constructAccount('Add', 'Completed');
    Test.startTest();
    handler.process(new List<Account>{ acc });
    Test.stopTest();

    Assert.isNotNull(
      stagingHandlerMock.getHistory('process'),
      'Should call ProfileStagingHandler.process'
    );
  }

  @IsTest
  static void testGenerateUpdatesAddRestraintsCompleted() {
    Account acc = constructAccount('Add', 'Completed');
    Test.startTest();
    List<Customer_Profile_Updates__c> updates = handler.generateUpdates(
      new List<Account>{ acc }
    );
    Test.stopTest();

    Assert.areEqual(1, updates.size(), 'Should generate 1 updates');
  }

  @IsTest
  static void testGenerateUpdatesRemoveRestraints() {
    Account acc = constructAccount('Remove', 'Completed');
    Test.startTest();
    List<Customer_Profile_Updates__c> updates = handler.generateUpdates(
      new List<Account>{ acc }
    );
    Test.stopTest();

    Assert.areEqual(0, updates.size(), 'Should not generate any updates');
  }

  @IsTest
  static void testGenerateUpdate() {
    Account acc = constructAccount('Add', 'Completed');
    Customer_Profile_Updates__c oldCpu = acc.Customer_Profile_Updates__r[0];
    Test.startTest();
    Customer_Profile_Updates__c cpu = handler.generateUpdate(oldCpu);
    Test.stopTest();

    Assert.areEqual(
      'Case.KYC_QA.RemoveRestraints',
      cpu.TriggeredFrom__c,
      'Incorrect TriggeredFrom__c'
    );
  }
}
