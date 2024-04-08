/**
 * @author Hitesh
 * @since 02/2024
 * @description Test class for MLCRMAccountActions
 */
@isTest
public class MLCRMAccountActionsTest {
  /**
   * @description test setup method
   */
  @testSetup
  static void setup() {
    User mlUser = MLCRMTestDataFactory.createMLCRMBaseUser();
    User ocvIntegrationUser = MLCRMTestDataFactory.createMLCRMIntegrationUser(
      Label.CCRM_OCVIntegrationUsername + '.test123'
    );
  }
  /**
   * @description test method for revertShellProspectBillingAddress
   */
  @isTest
  static void testRevertShellProspectBillingAddressForOCVUser() {
    User ocvIntegrationUser = [
      SELECT Id, FirstName, LastName
      FROM User
      WHERE LastName = 'MLCRM Integration'
      LIMIT 1
    ];
    Account record = new Account();
    record.BillingStreet = 'test Street';
    record.BillingCity = 'test City';
    record.BillingState = 'VIC';
    record.BillingPostalCode = '3000';
    record.BillingCountry = 'AUS';
    record.OCV_Event_Version__c = Integer.valueOf(
      Label.DCRM_ShellProspectOCVEventVersion
    );
    record.RecordTypeId = CCRMConstants.ACCOUNT_PERSON_RT_ID;
    record.FinServ__Status__c = 'Prospect';
    Test.startTest();
    System.runAs(ocvIntegrationUser) {
      MLCRMAccountActions.revertShellProspectBillingAddress(
        new List<Account>{ record }
      );
    }
    Test.stopTest();
    system.assertNotEquals(
      null,
      record.BillingStreet,
      'Shell prospect\'s Billing Address should not be cleared for OCV integration user'
    );
  }
  /**
   * @description test method for revertShellProspectBillingAddress
   */
  @isTest
  static void testRevertShellProspectBillingAddressForMLUser() {
    User mlUser = [
      SELECT Id, FirstName, LastName
      FROM User
      WHERE LastName = 'MLCRM'
      LIMIT 1
    ];
    Account record = new Account();
    record.BillingStreet = 'test Street';
    record.BillingCity = 'test City';
    record.BillingState = 'VIC';
    record.BillingPostalCode = '3000';
    record.BillingCountry = 'AUS';
    record.OCV_Event_Version__c = Integer.valueOf(
      Label.DCRM_ShellProspectOCVEventVersion
    );
    record.RecordTypeId = CCRMConstants.ACCOUNT_PERSON_RT_ID;
    record.FinServ__Status__c = 'Prospect';
    Test.startTest();
    CCRMLeadConversionActions.manualLeadConversionInitiated = true;
    System.runAs(mlUser) {
      MLCRMAccountActions.revertShellProspectBillingAddress(
        new List<Account>{ record }
      );
    }
    Test.stopTest();
    system.assertEquals(
      null,
      record.BillingStreet,
      'Shell prospect\'s Billing Address failed to clear for ML user'
    );
  }
  /**
   * @description test method for isShellProspectBillingAddressUpdated
   */
  @isTest
  static void testIsShellProspectBillingAddressUpdated() {
    User mlUser = [
      SELECT Id, FirstName, LastName
      FROM User
      WHERE LastName = 'MLCRM'
      LIMIT 1
    ];
    Account record = new Account();
    record.BillingStreet = 'test Street';
    record.BillingCity = 'test City';
    record.BillingState = 'VIC';
    record.BillingPostalCode = '3000';
    record.BillingCountry = 'AUS';
    record.OCV_Event_Version__c = Integer.valueOf(
      Label.DCRM_ShellProspectOCVEventVersion
    );
    record.RecordTypeId = CCRMConstants.ACCOUNT_PERSON_RT_ID;
    record.FinServ__Status__c = 'Prospect';
    Test.startTest();
    Boolean isShellBillingAddressUpdated = false;
    System.runAs(mlUser) {
      isShellBillingAddressUpdated = MLCRMAccountActions.isShellProspectBillingAddressUpdated(
        record
      );
    }
    Test.stopTest();
    system.assertEquals(
      true,
      isShellBillingAddressUpdated,
      'shell Billing Address is not updated'
    );
  }
  /**
   * @description test method for validateDateOfBirth
   */
  @isTest
  static void validateDateOfBirthTest() {
    User mlUser = [SELECT Id FROM User WHERE LastName = :'MLCRM' LIMIT 1];
    Account record = new Account();
    record.RecordTypeId = CCRMConstants.ACCOUNT_PERSON_RT_ID;
    record.PersonBirthdate = System.TODAY();
    Test.startTest();
    System.runAs(mlUser) {
      MLCRMAccountActions.validateDateOfBirth(new List<Account>{ record });
    }
    Test.stopTest();
    List<Database.Error> errors = record.getErrors();
    System.assertEquals(1, errors.size(), 'Birthdate is valid');
    Database.Error error = errors.get(0);
    System.assertEquals(
      Label.ML_DateOfBirth_ErrorMessage,
      error.getMessage(),
      'Date of Birth is in past'
    );
    System.assertEquals(
      StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION,
      error.getStatusCode(),
      'No Error found'
    );
  }
}
