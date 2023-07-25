/**
 * @description Test class for {@link CommonUtil}
 * @author Olivier Saier
 * @since May 2021
 * @group Utils
 */
@isTest
public with sharing class CommonUtilTest {
  @isTest
  static void testGenerateUUID() {
    //WHEN UUIDs are generated
    String[] uuids = new List<String>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      uuids.add(CommonUtil.generateuUID());
    }

    //THEN they all match the UUID pattern
    Pattern uuidPattern = Pattern.compile(
      '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    );
    for (String uuid : uuids) {
      Matcher uuidMatcher = uuidPattern.matcher(uuid);
      System.assert(uuidMatcher.matches(), 'UUID should match the pattern');
    }

    //THEN They're all unique from each other
    Set<String> unique = new Set<String>();
    unique.addAll(uuids);
    System.assertEquals(
      unique.size(),
      uuids.size(),
      'The generated UUIDs should be unique from each other'
    );
  }

  @isTest
  static void logAndThrowIAETest() {
    Test.startTest();
    try {
      //WHEN I call logAndThrowIAE
      CommonUtil.logAndThrowIAE(
        'CommonUtilTest',
        'logAndThrowTest',
        'Error message'
      );

      //THEN an InsufficientAccessException exception is thrown
      System.assertEquals(
        true,
        false,
        'An exception should have been caught before reaching this assert.'
      );
    } catch (Exception ex) {
      System.assertEquals(
        'Error message',
        ex.getMessage(),
        'Error message should be thrown'
      );
      System.assertEquals(
        'CommonUtil.InsufficientAccessException',
        ex.getTypeName(),
        'InsufficientAccessException should be thrown'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testGetCustomNotifTypeByName() {
    // GIVEN
    // an engineer wants to get the Id of a particular CustomNotificationType
    String caseSLANotificationName = 'Case_SLA';
    CustomNotificationType type = new CustomNotificationType();

    // WHEN
    // getCustomNotificationTypeByName() method is called by passing the DeveloperName of the CustomNotificationType
    Test.startTest();
    type = CommonUtil.getCustomNotificationTypeByName(caseSLANotificationName);
    Test.stopTest();

    // THEN
    // it should return a valid Id
    System.assert(
      type != null &&
      type.Id != null,
      'Failed to get CustomNotificationType by DeveloperName.'
    );
  }

  @isTest
  static void testBase64Conversion() {
    // WHEN
    // base64urlToBase64() method is called passing the base64url
    Test.startTest();
    String base64 = CommonUtil.base64URLToBase64('hJ-QWHABDBjoPHor_YF5/xghQ+');
    Test.stopTest();
    // THEN
    // it should return a valid base64 string
    System.assertEquals(
      base64,
      'hJ+QWHABDBjoPHor/YF5/xghQ+==',
      'Failed to convert base64url to base64.'
    );
  }

  @isTest
  static void testBildTrimedConcatenatedString() {
    String strWithSpace = 'string   with space';
    String strAdditional = 'additional string';
    List<String> items = new List<String>{
      '   ',
      '',
      null,
      ' ',
      '  ' +
      strWithSpace +
      '   ',
      strAdditional
    };

    String trimmedConcatenated = CommonUtil.buildTrimedConcatenatedString(
      items
    );

    String expected = strWithSpace + ' ' + strAdditional;
    Assert.areEqual(
      expected,
      trimmedConcatenated,
      'The trimmed concatenated string should be ' + expected
    );
  }

  @isTest
  static void testFilterCasesByRecordTypeId() {
    List<Case> cases = new List<Case>();

    Integer kycQACaseCount = 2;

    List<Id> recordTypes = new List<Id>{
      GetHelpConstants.CUSTOMER_FEEDBACK_RT_ID
    };

    for (Integer i = 0; i < kycQACaseCount; i++) {
      recordTypes.add(GetHelpConstants.KYCQA_RT_ID);
    }

    for (Id recordType : recordTypes) {
      cases.add(new Case(RecordTypeId = recordType));
    }

    List<Case> filteredKYCQACases = CommonUtil.filterCasesByRecordTypeId(
      cases,
      GetHelpConstants.KYCQA_RT_ID
    );

    Assert.areEqual(
      kycQACaseCount,
      filteredKYCQACases.size(),
      'Should be ' +
      kycQACaseCount +
      ' filtered Cases'
    );
  }

  static void testGetSLAProcess() {
    SlaProcess sla = CommonUtil.getSLAProcess(
      GetHelpConstants.ANZ_PLUS_BASIC_SUBSCRIPTION_SLA_PROCESS_NAME
    );

    Assert.isNotNull(
      sla,
      'There should be SLA Process named ' +
      GetHelpConstants.ANZ_PLUS_BASIC_SUBSCRIPTION_SLA_PROCESS_NAME
    );
  }

  static void testGetSLAProcessNoSlaProcessName() {
    SlaProcess sla = CommonUtil.getSLAProcess(null);

    Assert.isNull(sla, 'There should be no SLA Process found.');
  }

  static void testAddPersonAccountEntitlements() {
    Faker faker = new Faker('AU');
    List<Account> accs = new List<Account>();
    Account acc = new Account(
      FirstName = faker.person.firstName(),
      LastName = faker.person.lastName(),
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID
    );

    accs.add(acc);
    insert accs;

    List<Entitlement> entitlements = CommonUtil.addPersonAccountEntitlements(
      accs,
      GetHelpConstants.ANZ_PLUS_BASIC_SUBSCRIPTION_SLA_PROCESS_NAME,
      GetHelpConstants.BASIC_SUBSCRIPTION_ENTITLEMENT_NAME
    );

    Assert.areEqual(
      accs.size(),
      entitlements.size(),
      'Should be ' +
      accs.size() +
      ' entitlements'
    );
  }
}
