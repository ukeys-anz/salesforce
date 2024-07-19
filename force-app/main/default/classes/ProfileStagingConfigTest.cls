/**
 * @author Tan Phan
 * @since 06/2024
 * @description Tests for {@link ProfileStagingConfig}
 */
@isTest
private class ProfileStagingConfigTest {
  static final Faker FAKER = new Faker('en-AU');
  static final String ACCOUNT_LABEL = Schema.SObjectType.Account.Label;
  static final String ACCOUNT_NAME_LABEL = Schema.SObjectType.Account.fields.Name.Label;
  static final List<Set<String>> FIELD_GROUPS = new List<Set<String>>{
    new Set<String>{
      'BillingStreet',
      'BillingState',
      'BillingCountry',
      'BillingPostalCode',
      'BillingCity'
    }
  };

  static ConfigTest config = new ConfigTest();

  @IsTest
  static void testProcess() {
    config.canCaptureOverride = true;
    config.revertOnDone = false;
    config.trackedFields = new Set<String>{ 'Name' };
    config.fieldGroups = FIELD_GROUPS;
    Customer_Profile_Updates__c cpu = new Customer_Profile_Updates__c();
    Account oldRecord = new Account(Name = FAKER.randomString(10));
    Account record = new Account(Name = FAKER.randomString(11));

    Test.startTest();
    Boolean success = config.process(cpu, record, oldRecord);
    Test.stopTest();

    System.debug(cpu);
    Assert.isTrue(success, 'Should be successful');
    Assert.areEqual(
      '{"Name":"' + record.Name + '"}',
      cpu.ToBeValue__c,
      'Customer_Profile_Updates__c should be updated with captured data'
    );
  }

  @IsTest
  static void testProcessUnsuccessful() {
    config.canCaptureOverride = false;
    config.trackedFields = new Set<String>{ 'Name' };
    config.copyFields = new Set<String>{ 'AccountNumber' };
    Customer_Profile_Updates__c cpu = new Customer_Profile_Updates__c();
    Account record = new Account(Name = FAKER.randomString(10));

    Test.startTest();
    Boolean success = config.process(cpu, record, null);
    Test.stopTest();

    Assert.isFalse(success, 'Should be unsuccessful');
  }

  @IsTest
  static void testCapture() {
    config.canCaptureOverride = true;
    config.trackedFields = new Set<String>{ 'Name' };
    config.copyFields = new Set<String>{ 'AccountNumber' };
    config.data = new ProfileStagingConfig.ChangeData();
    config.record = new Account(
      Name = FAKER.randomString(10),
      AccountNumber = FAKER.randomString(10)
    );

    Test.startTest();
    config.capture();
    Test.stopTest();

    Assert.isTrue(
      config.data.newData.containsKey('Name'),
      'Name should be captured'
    );
    Assert.isTrue(
      config.data.newData.containsKey('AccountNumber'),
      'AccountNumber should be copied when a change has been capture'
    );
  }

  @IsTest
  static void testCaptureCannotCapture() {
    config.canCaptureOverride = false;
    config.trackedFields = new Set<String>{ 'Name' };
    config.copyFields = new Set<String>{ 'AccountNumber' };
    config.data = new ProfileStagingConfig.ChangeData();
    config.record = new Account(
      Name = FAKER.randomString(10),
      AccountNumber = FAKER.randomString(10)
    );

    Test.startTest();
    config.capture();
    Test.stopTest();

    Assert.isFalse(
      config.data.newData.containsKey('Name'),
      'Name should not be captured'
    );
    Assert.isFalse(
      config.data.newData.containsKey('AccountNumber'),
      'AccountNumber should not be copied when no changes are captured'
    );
  }

  @IsTest
  static void testCaptureField() {
    config.data = new ProfileStagingConfig.ChangeData();
    config.oldRecord = new Account(Name = FAKER.randomString(10));
    config.record = new Account(Name = FAKER.randomString(11));

    Test.startTest();
    config.captureField('Name');
    Test.stopTest();

    Assert.isTrue(
      config.data.newData.containsKey('Name') &&
        config.data.oldData.containsKey('Name') &&
        config.data.newUiData.containsKey(ACCOUNT_NAME_LABEL) &&
        config.data.oldUiData.containsKey(ACCOUNT_NAME_LABEL),
      'Field should be captured'
    );
  }

  @IsTest
  static void testCaptureFieldHasChecked() {
    config.data = new ProfileStagingConfig.ChangeData();
    config.data.checkedFields.add('Name');
    config.record = new Account(Name = FAKER.randomString(10));

    Test.startTest();
    config.captureField('Name');
    Test.stopTest();

    Assert.isFalse(
      config.data.newData.containsKey('Name'),
      'Field should be skipped if already processed'
    );
  }

  @IsTest
  static void testCaptureFieldNullOnInsert() {
    config.data = new ProfileStagingConfig.ChangeData();
    config.record = new Account(Name = null);

    Test.startTest();
    config.captureField('Name');
    Test.stopTest();

    Assert.isFalse(
      config.data.newData.containsKey('Name'),
      'NULL field should not be captured on insert'
    );
  }

  @IsTest
  static void testCaptureFieldNullOnUpdate() {
    config.data = new ProfileStagingConfig.ChangeData();
    config.oldRecord = new Account(Name = FAKER.randomString(10));
    config.record = new Account(Name = null);

    Test.startTest();
    config.captureField('Name');
    Test.stopTest();

    Assert.isTrue(
      config.data.newData.containsKey('Name') &&
      config.data.newData.get('Name') == null,
      'NULL field should be captured on update'
    );
  }

  @IsTest
  static void writeNewData() {
    config.data = new ProfileStagingConfig.ChangeData();
    String name = FAKER.randomString(10);
    config.record = new Account(Name = name);

    Test.startTest();
    config.writeNewData('Name');
    Test.stopTest();

    Assert.areEqual(
      name,
      config.data.newData.get('Name'),
      'New data should be written'
    );
    Assert.areEqual(
      name,
      config.data.newUiData.get(ACCOUNT_NAME_LABEL),
      'New data should be written'
    );
  }

  @IsTest
  static void testWriteOldData() {
    config.data = new ProfileStagingConfig.ChangeData();
    String name = FAKER.randomString(10);
    config.record = new Account(Name = FAKER.randomString(11));
    config.oldRecord = new Account(Name = name);

    Test.startTest();
    config.writeOldData('Name');
    Test.stopTest();

    Assert.areEqual(
      name,
      config.data.oldData.get('Name'),
      'Old data should be written'
    );
    Assert.areEqual(
      name,
      config.data.oldUiData.get(ACCOUNT_NAME_LABEL),
      'Old data should be written'
    );
  }

  @IsTest
  static void testWriteOldDataOnInsert() {
    config.data = new ProfileStagingConfig.ChangeData();
    config.record = new Account(Name = FAKER.randomString(10));

    Test.startTest();
    config.writeOldData('Name');
    Test.stopTest();

    Assert.isFalse(
      config.data.oldData.containsKey('Name'),
      'Old data should not be written on insert'
    );
  }

  @IsTest
  static void testCaptureGroup() {
    config.canCaptureOverride = true;
    config.fieldGroups = FIELD_GROUPS;
    config.data = new ProfileStagingConfig.ChangeData();
    config.record = config.oldRecord = new Account(
      BillingStreet = FAKER.address.street(),
      BillingCity = FAKER.address.city()
    );
    config.record = config.oldRecord;

    Test.startTest();
    config.captureGroup('BillingStreet');
    Test.stopTest();

    Assert.isTrue(
      config.data.newData.containsKey('BillingCity'),
      'BillingCity should be captured as part of Billing Address'
    );
  }

  @IsTest
  static void testCaptureGroupOnInsert() {
    config.fieldGroups = FIELD_GROUPS;
    config.data = new ProfileStagingConfig.ChangeData();
    config.record = new Account(
      BillingStreet = FAKER.address.street(),
      BillingCity = FAKER.address.city()
    );

    Test.startTest();
    config.captureGroup('BillingStreet');
    Test.stopTest();

    Assert.isFalse(
      config.data.newData.containsKey('BillingCity'),
      'BillingCity should not be captured as part of Billing Address on insert'
    );
  }

  @IsTest
  static void testReport() {
    config.record = new Account();
    config.data = new ProfileStagingConfig.ChangeData();
    config.data.newData.put('Customer Name', FAKER.randomString(10));
    config.data.oldData.put('Customer ', FAKER.randomString(10));
    config.data.newUiData.put('Name', FAKER.randomString(10));
    config.data.oldUiData.put('Name', FAKER.randomString(10));
    Customer_Profile_Updates__c cpu = new Customer_Profile_Updates__c();

    Test.startTest();
    config.report(cpu);
    Test.stopTest();

    Assert.areEqual(
      new Customer_Profile_Updates__c(
        Name = ACCOUNT_LABEL,
        Object_Name__c = ACCOUNT_LABEL,
        TriggeredFrom__c = 'Account',
        OldValue__c = JSON.serializePretty(config.data.oldUiData),
        NewValue__c = JSON.serializePretty(config.data.newUiData),
        AsIsValue__c = JSON.serialize(config.data.oldData),
        ToBeValue__c = JSON.serialize(config.data.newData)
      ),
      cpu,
      'Customer_Profile_Updates__c should be updated with captured data'
    );
  }

  @IsTest
  static void testRevert() {
    config.record = (Account) TestUtil.setFields(
      new Account(Name = FAKER.randomString(10)),
      new Map<String, Object>{ 'LastModifiedDate' => System.now().addDays(1) }
    );
    config.oldRecord = (Account) TestUtil.setFields(
      new Account(Name = FAKER.randomString(11)),
      new Map<String, Object>{ 'LastModifiedDate' => System.now() }
    );

    Test.startTest();
    config.revert();
    Test.stopTest();

    Assert.areEqual(
      config.oldRecord.get('Name'),
      config.record.get('Name'),
      'Name should be reverted'
    );
    Assert.areNotEqual(
      config.oldRecord.get('LastModifiedDate'),
      config.record.get('LastModifiedDate'),
      'Readonly field should not be reverted'
    );
  }

  @IsTest
  static void testRevertOnInsert() {
    String name = FAKER.randomString(10);
    config.record = new Account(Name = name);

    Test.startTest();
    config.revert();
    Test.stopTest();

    Assert.areEqual(name, config.record.get('Name'), 'Should not be reverted');
  }

  @IsTest
  static void testRevertDisabled() {
    config.revertOnDone = false;
    config.record = new Account(Name = FAKER.randomString(10));
    config.oldRecord = new Account(Name = FAKER.randomString(11));

    Test.startTest();
    config.revert();
    Test.stopTest();

    Assert.areNotEqual(
      config.oldRecord.get('Name'),
      config.record.get('Name'),
      'Should not be reverted'
    );
  }

  @IsTest
  static void testGetFieldName() {
    Test.startTest();
    String field = config.getFieldName('Name');
    Test.stopTest();

    Assert.areEqual('Name', field, 'Field name should match');
  }

  @IsTest
  static void testGetFieldLabel() {
    config.record = new Account();

    Test.startTest();
    String label = config.getFieldLabel('Name');
    Test.stopTest();

    Assert.areEqual(ACCOUNT_NAME_LABEL, label, 'Field label should match');
  }

  @IsTest
  static void testGetFieldValue() {
    Account record = new Account(Name = FAKER.randomString(10));

    Test.startTest();
    String value = (String) config.getFieldValue(record, 'Name');
    Test.stopTest();

    Assert.areEqual(record.Name, value, 'Field value should match');
  }

  @IsTest
  static void testCanCaptureYesOnInsert() {
    config.record = new Account();

    Test.startTest();
    Boolean canCapture = config.canCapture('Name');
    Test.stopTest();

    Assert.isTrue(canCapture, 'Should be true');
  }

  @IsTest
  static void testCanCaptureNoOnInsert() {
    config.record = new Account();

    Test.startTest();
    Boolean canCapture = config.canCapture('CreatedDate');
    Test.stopTest();

    Assert.isFalse(canCapture, 'Should be false');
  }

  @IsTest
  static void testCanCaptureYesOnUpdate() {
    config.record = new Account(Name = FAKER.randomString(10));
    config.oldRecord = new Account(Name = FAKER.randomString(10));

    Test.startTest();
    Boolean canCapture = config.canCapture('Name');
    Test.stopTest();

    Assert.isTrue(canCapture, 'Should be true');
  }

  @IsTest
  static void testCanCaptureNoOnUpdateNoChange() {
    config.record = new Account(Name = FAKER.randomString(10));
    config.oldRecord = config.record;

    Test.startTest();
    Boolean canCapture = config.canCapture('Name');
    Test.stopTest();

    Assert.isFalse(canCapture, 'Should be false');
  }

  @IsTest
  static void testCanCaptureNoOnUpdateReadonly() {
    config.record = (Account) TestUtil.setFields(
      new Account(),
      new Map<String, Object>{ 'LastModifiedDate' => System.now().addDays(1) }
    );
    config.oldRecord = (Account) TestUtil.setFields(
      new Account(),
      new Map<String, Object>{ 'LastModifiedDate' => System.now() }
    );

    Test.startTest();
    Boolean canCapture = config.canCapture('LastModifiedDate');
    Test.stopTest();

    Assert.isFalse(canCapture, 'Should be false');
  }

  @IsTest
  static void testIsNullOnInsertYesNull() {
    config.record = new Account();

    Test.startTest();
    Boolean isNullOnInsert = config.isNullOnInsert('Name');
    Test.stopTest();

    Assert.isTrue(isNullOnInsert, 'Should be true when value is null');
  }

  @IsTest
  static void testIsNullOnInsertYesFalse() {
    config.record = new Account();

    Test.startTest();
    Boolean isFalseOnInsert = config.isNullOnInsert('IsPersonAccount');
    Test.stopTest();

    Assert.isTrue(isFalseOnInsert, 'Should be true when value is false');
  }

  @IsTest
  static void testIsNullOnInsertNoOnInsert() {
    config.record = new Account(Name = FAKER.randomString(10));

    Test.startTest();
    Boolean isNullOnInsert = config.isNullOnInsert('Name');
    Test.stopTest();

    Assert.isFalse(isNullOnInsert, 'Should be false when value not null');
  }

  @IsTest
  static void testIsNullOnInsertNoOnUpdate() {
    config.record = new Account();
    config.oldRecord = new Account();

    Test.startTest();
    Boolean isNullOnInsert = config.isNullOnInsert('Name');
    Test.stopTest();

    Assert.isFalse(isNullOnInsert, 'Should be false on record update');
  }

  @IsTest
  static void testHasChangesYes() {
    config.data = new ProfileStagingConfig.ChangeData();
    config.data.newData.put('Name', FAKER.randomString(10));

    Test.startTest();
    Boolean hasChanges = config.hasChanges();
    Test.stopTest();

    Assert.isTrue(hasChanges, 'Should have changes');
  }

  @IsTest
  static void testHasChangesNo() {
    config.data = new ProfileStagingConfig.ChangeData();

    Test.startTest();
    Boolean hasChanges = config.hasChanges();
    Test.stopTest();

    Assert.isFalse(hasChanges, 'Should have no changes');
  }

  @IsTest
  static void testHasCheckedYes() {
    config.data = new ProfileStagingConfig.ChangeData();
    config.data.checkedFields.add('Name');

    Test.startTest();
    Boolean checked = config.hasChecked('Name');
    Test.stopTest();

    Assert.isTrue(checked, 'Field should have been checked');
    Assert.isTrue(
      config.data.checkedFields.contains('Name'),
      'Field should be added after checked'
    );
  }

  @IsTest
  static void testHasCheckedNo() {
    config.data = new ProfileStagingConfig.ChangeData();

    Test.startTest();
    Boolean checked = config.hasChecked('Name');
    Test.stopTest();

    Assert.isFalse(checked, 'Field should not have beeen checked');
    Assert.isTrue(
      config.data.checkedFields.contains('Name'),
      'Field should be added after checked'
    );
  }

  @IsTest
  static void testGetFieldInfo() {
    config.record = new Account();

    Test.startTest();
    DescribeFieldResult fieldInfo = config.getFieldInfo('Name');
    Test.stopTest();

    Assert.areEqual(
      'Name',
      fieldInfo.Name,
      'Field info should be result for Name field'
    );
    Assert.isTrue(
      config.fieldInfoMap.containsKey('Name'),
      'DescribeFieldResult should be cached'
    );
  }

  @IsTest
  static void testIsChangedYes() {
    config.record = new Account(Name = FAKER.randomString(10));
    config.oldRecord = new Account(Name = FAKER.randomString(11));

    Test.startTest();
    Boolean isChanged = config.isChanged('Name');
    Test.stopTest();

    Assert.isTrue(isChanged, 'Should be true when field is changed');
  }

  @IsTest
  static void testIsChangedNoOnInsert() {
    config.record = new Account();

    Test.startTest();
    Boolean isChanged = config.isChanged('Name');
    Test.stopTest();

    Assert.isFalse(isChanged, 'Should be false on insert');
  }

  @IsTest
  static void testIsChangedNoOnUpdate() {
    config.record = new Account(Name = FAKER.randomString(10));
    config.oldRecord = config.record;

    Test.startTest();
    Boolean isChanged = config.isChanged('Name');
    Test.stopTest();

    Assert.isFalse(isChanged, 'Should be false when no changes are made');
  }

  /**
   * @description Extending ProfileStagingConfig for tests
   */
  class ConfigTest extends ProfileStagingConfig {
    Boolean canCaptureOverride;

    /**
     * @description This method is used to finalize the customer profile updates.
     * @param cpu The Customer_Profile_Updates__c object containing the profile updates.
     */
    protected override void finalise(Customer_Profile_Updates__c cpu) {
    }

    /**
     * @description Overriding base "canCapture" method to ignore FLS for tests
     * @param field The name of the field to check.
     * @return True if the field can be captured, false otherwise.
     */
    protected override Boolean canCapture(String field) {
      if (canCaptureOverride == null) {
        return super.canCapture(field);
      }
      return this.canCaptureOverride;
    }
  }
}
