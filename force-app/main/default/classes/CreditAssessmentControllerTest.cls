/**
 * @author cruzb
 * @since May 2023
 * @description Controller test class for Apex remote CreditAssessmentController
 * @group Services
 */
@isTest
public with sharing class CreditAssessmentControllerTest {
  /**
   * @description This setup method creates the record(s) required for the test classes
   */
  @testSetup
  public static void setup() {
    insert new Referral_Reason__c(Reason_Code__c = 'RE202');
    ResidentialLoanApplication[] newRLA = new List<ResidentialLoanApplication>();
    Account rlaCustomer = TestDataFactory.createAccount('CustomerRLA', true);
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      ResidentialLoanApplication rla = TestDataFactory.createTestResidentialLoanApplication(
        String.valueOf(i)
      );
      rla.Credit_ID__c = '000-000-000-00' + String.valueOf(i);
      rla.AccountId = rlaCustomer.Id;

      newRLA.add(rla);
    }
    insert newRLA;
  }

  @isTest
  static void testGetCreditAssessments() {
    Account acc = [SELECT Id FROM Account WHERE Name = 'CustomerRLA' LIMIT 1];

    Case c = new Case(
      RecordTypeID = GetHelpConstants.CREDIT_REFERRAL_RT_ID,
      Subject = 'Test Credit Referral',
      Status = 'Open',
      AccountId = acc.Id,
      Credit_Id__c = '000-000-000-001'
    );
    insert c;
    Map<String, Object> objectMap = new Map<String, Object>();
    CreditAssessmentController crAssessment = new CreditAssessmentController();
    Map<String, Object> inputMap = new Map<String, Object>();
    inputMap.put('creditId', '1231');
    inputMap.put('recordId', c.Id);
    inputMap.put('ocvId', '123123');
    Boolean isInvoked = crAssessment.invokeMethod(
      'getCreditAssessments',
      inputMap,
      objectMap,
      new Map<String, Object>()
    );
    Object payload = objectMap.get('object');
    System.assert(isInvoked, 'Method not invoked');
    System.assertNotEquals(payload, null, 'Empty JSON');
    System.assertNotEquals(
      ((Map<String, Object>) payload).get('current'),
      null,
      'Missing `current` node'
    );
    System.assertNotEquals(
      ((Map<String, Object>) payload).get('history'),
      null,
      'Missing `history` node'
    );
    CreditReferralModel model = CreditReferralModel.parse(
      json.serialize(((Map<String, Object>) payload).get('current'))
    );
    System.assert(
      !model.assessments[0].outcome.contains('_'),
      'Outcome not transformed'
    );
  }

  @isTest
  static void testgetAssessmentOutcome() {
    Account customer = TestDataFactory.createAccount('test customer', true);
    ResidentialLoanApplication r = TestDataFactory.createTestResidentialLoanApplication(
      '1'
    );
    r.accountId = customer.Id;
    r.Status = 'STATE_DECLINED';
    insert r;
    system.debug(r.id);
    Map<String, Object> objectMap = new Map<String, Object>();
    CreditAssessmentController crAssessment = new CreditAssessmentController();
    Map<String, Object> inputMap = new Map<String, Object>();
    inputMap.put('ApplicationId', r.Id);
    Boolean isInvoked = crAssessment.invokeMethod(
      'getAssessmentOutcome',
      inputMap,
      objectMap,
      new Map<String, Object>()
    );
    Object payload = objectMap.get('object');
    System.assert(isInvoked, 'Method not invoked');
    System.assertNotEquals(payload, null, 'Empty JSON');
    System.assertNotEquals(
      ((Map<String, Object>) payload).get('lastModified'),
      null,
      'Missing `lastModified` node'
    );
    System.assertNotEquals(
      ((Map<String, Object>) payload).get('rows'),
      null,
      'Missing `rows` node'
    );
  }
}
