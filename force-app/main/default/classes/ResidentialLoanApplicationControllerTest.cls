/**
 * @author cruzb
 * @since August 2023
 * @description Controller test class for Apex remote ResidentialLoanApplicationController
 * @group Services
 */
@isTest
public with sharing class ResidentialLoanApplicationControllerTest {
  @isTest
  static void testGetSOP() {
    Faker faker = new Faker('AU');
    Account acc = TestDataFactory.createAccount(true);

    ResidentialLoanApplication rla = new ResidentialLoanApplication();
    rla.Name = 'Test Loan Application';
    rla.AccountId = acc.Id;
    rla.SOP_ID__c = '1234';
    insert rla;

    ResidentialLoanApplicationController rlaCtrl = new ResidentialLoanApplicationController();

    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> objectMap = new Map<String, Object>();

    inputMap.put('loanId', rla.Id);

    Boolean isInvoked = rlaCtrl.invokeMethod(
      'getSOP',
      inputMap,
      objectMap,
      new Map<String, Object>()
    );

    Object payload = objectMap.get('object');

    System.assert(isInvoked, 'Method not invoked');
    System.assertNotEquals(payload, null, 'Empty JSON');
    SOPModel model = SOPModel.parse(json.serialize(objectMap.get('object')));

    System.assert(
      model.parties[0].partyDependantsCount != null,
      'SOP not transformed'
    );
    System.assert(
      model.parties[0].soleIncomeEarner != null,
      'SOP not transformed'
    );
    System.assert(
      !model.parties[0].relationshipState.contains('_'),
      'SOP not transformed'
    );
  }

  @isTest
  static void testDeleteIncome() {
    Faker faker = new Faker('AU');
    Account acc = TestDataFactory.createAccount(true);

    ResidentialLoanApplication rla = new ResidentialLoanApplication();
    rla.Name = 'Test Loan Application';
    rla.AccountId = acc.Id;
    rla.SOP_ID__c = '1234';
    insert rla;

    ResidentialLoanApplicationController rlaCtrl = new ResidentialLoanApplicationController();

    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> objectMap = new Map<String, Object>();

    inputMap.put('loanId', rla.Id);
    inputMap.put('name', 'testname');
    inputMap.put('etag', 'test/etag');

    Boolean isInvoked = rlaCtrl.invokeMethod(
      'deleteIncome',
      inputMap,
      objectMap,
      new Map<String, Object>()
    );

    Object payload = objectMap.containsKey('object');

    System.assert(isInvoked, 'Method not invoked');
    System.assertNotEquals(payload, null, 'Empty JSON');
    System.assert(objectMap.containsKey('object'), 'missing response');
    System.assert(objectMap.containsKey('toast'), 'missing toast');
  }
}
