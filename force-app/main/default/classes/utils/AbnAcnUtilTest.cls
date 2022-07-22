/**
 * @author Olivier Saier
 * @since 10/2021
 * @group CCRM (Commercial CRM)
 * @description AbnAcnUtilTest is the test class to cover tests for {@link AbnAcnUtil.cls}
 */
@isTest
private class AbnAcnUtilTest {
  @TestSetup
  static void makeData() {
    User ccrmUser = CCRMTestDataFactory.createCCRMBaseUser();
    Lead[] leads = new List<Lead>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      leads.add(
        new Lead(
          RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID,
          FirstName = 'First',
          LastName = 'Name',
          Company = 'Company',
          Email = 'test@test.test',
          ABN__c = '11005 357 522',
          ACN__c = '004085616',
          LeadSource = 'Individual'
        )
      );
    }

    System.runAs(ccrmUser) {
      insert leads;
    }
  }

  @isTest
  static void checkInsertedWithCleanFormat() {
    Lead[] l = [SELECT id FROM Lead WHERE ABN__c = '11 005 357 522'];
    System.assert(l.size() > 0, 'ABN should be properly formatted');
    l = [SELECT id FROM Lead WHERE ACN__c = '004 085 616' LIMIT 1];
    System.assert(l.size() > 0, 'ACN should be properly formatted');
  }

  @isTest
  static void testUpdateWithInvalidABNFormat() {
    User ccrmUser = [SELECT Id FROM User WHERE LastName = 'CCRM'];
    String msg = '';
    Lead[] leads = [SELECT ABN__c FROM Lead];
    for (Lead l : leads) {
      l.ABN__c = 'Invalid';
    }
    try {
      System.runAs(ccrmUser) {
        update leads;
      }
    } catch (Exception e) {
      msg = e.getMessage();
    }
    System.assert(
      msg.contains('ABN should be 11 digits'),
      'An error should be thrown when ABN is not 11 digits with or without spaces.'
    );
  }

  @isTest
  static void testUpdateWithInvalidABN() {
    User ccrmUser = [SELECT Id FROM User WHERE LastName = 'CCRM'];
    String invalidABN = '12345678901';
    String msg = '';
    Lead[] leads = [SELECT ABN__c FROM Lead];
    for (Lead l : leads) {
      l.ABN__c = invalidABN;
    }
    try {
      System.runAs(ccrmUser) {
        update leads;
      }
    } catch (Exception e) {
      msg = e.getMessage();
    }
    System.assert(
      msg.contains('not a valid ABN.'),
      'An error should be thrown if ABN is invalid'
    );
  }

  @isTest
  static void testUpdateWithInvalidACNFormat() {
    User ccrmUser = [SELECT Id FROM User WHERE LastName = 'CCRM'];
    String msg = '';
    Lead[] leads = [SELECT ACN__c FROM Lead];
    for (Lead l : leads) {
      l.ACN__c = 'Invalid';
    }
    try {
      System.runAs(ccrmUser) {
        update leads;
      }
    } catch (Exception e) {
      msg = e.getMessage();
    }
    System.assert(
      msg.contains('ACN should be 9 digits'),
      'An error should be thrown when ACN is not 9 digits with or without spaces.'
    );
  }

  @isTest
  static void testUpdateWithInvalidACN() {
    User ccrmUser = [SELECT Id FROM User WHERE LastName = 'CCRM'];
    String invalidACN = '004085615';
    String msg = '';
    Lead[] leads = [SELECT ACN__c FROM Lead];
    for (Lead l : leads) {
      l.ACN__c = invalidACN;
    }
    try {
      System.runAs(ccrmUser) {
        update leads;
      }
    } catch (Exception e) {
      msg = e.getMessage();
    }
    System.assert(
      msg.contains('not a valid ACN.'),
      'An error should be thrown if ACN is invalid'
    );
  }
}
