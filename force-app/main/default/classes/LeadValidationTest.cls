/**
 * @author Emma Bindi
 * @since  05/2022
 * @description Test class to cover validation rules for Lead object
 */
@isTest
public with sharing class LeadValidationTest {
  public static final String LEAD_VR1_ERROR = 'Lead Status cannot be changed to Converted manually. A lead has to be converted by the conversion process.';
  public static final String LEAD_VR2_ERROR = 'A mobile number is required.';
  public static final String LEAD_VR3_ERROR = 'An email address is required';

  @isTest
  static void testLeadsV1Rule() {
    Lead l = createLead();
    insert l;

    try {
      l.Status = 'Converted';
      update l;
      System.assert(
        false,
        'Failed to prevent against user coverting lead when status is converted manually'
      );
    } catch (DmlException e) {
      System.assertEquals(
        true,
        e.getMessage().contains(LEAD_VR1_ERROR),
        'Error messages should match.'
      );
    }
  }

  @isTest
  static void testLeadsV2RuleWithError() {
    Lead l = createLead();
    l.MobilePhone = '';

    Test.startTest();

    try {
      insert l;
      System.assert(
        false,
        'Failed to prevent against user creating lead when mobile number is missing'
      );
    } catch (DmlException e) {
      System.assertEquals(
        true,
        e.getMessage().contains(LEAD_VR2_ERROR),
        'Error messages should match.'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testLeadsV2RuleWithoutError() {
    Lead l = createLead();
    Test.startTest();

    try {
      insert l;
    } catch (DmlException e) {
      System.assertEquals(null, e, 'Error message should be null.');
    }

    System.assertEquals(
      1,
      [SELECT Id FROM Lead].size(),
      'Lead should be created.'
    );
    Test.stopTest();
  }

  @isTest
  static void testLeadsV3RuleWithError() {
    Lead l = createLead();
    l.Email = '';

    Test.startTest();

    try {
      insert l;
      System.assert(
        false,
        'Failed to prevent against user creating lead when email address is missing.'
      );
    } catch (DmlException e) {
      System.assertEquals(
        true,
        e.getMessage().contains(LEAD_VR3_ERROR),
        'Error messages should match.'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testLeadsV3RuleWithoutError() {
    Lead l = createLead();

    Test.startTest();

    try {
      insert l;
    } catch (DmlException e) {
      System.assertEquals(null, e, 'Error message should be null.');
    }

    System.assertEquals(
      1,
      [SELECT Id FROM Lead].size(),
      'Lead should be created.'
    );
    Test.stopTest();
  }

  private static Lead createLead() {
    Faker faker = new Faker('AU');

    Lead l = new Lead();
    l.Firstname = faker.person.firstName();
    l.Lastname = faker.person.lastName();
    l.Email = faker.internet.email();
    l.MobilePhone = faker.person.phone();
    l.RecordTypeId = GetHelpConstants.LEAD_ANZX_RT_ID;

    return l;
  }
}
