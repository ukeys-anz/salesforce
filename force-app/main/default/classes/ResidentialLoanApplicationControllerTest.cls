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

  @isTest
  static void testSetUamForBtns() {
    ResidentialLoanApplication rla = new ResidentialLoanApplication();
    rla.Status = 'STATE_REFERRED';
    List<ResidentialLoanApplication> loanRec = new List<ResidentialLoanApplication>{
      rla
    };
    ResidentialLoanApplicationModel sopAssets = prepareRla();

    User coach = TestUtil.createTestUserWithProfile('ANZx Standard User');
    UserRole coachRole = [
      SELECT Id, Name
      FROM UserRole
      WHERE Name = :'BOH Coach'
    ];
    coach.UserRoleId = coachRole.Id;
    insert coach;

    System.runAs(coach) {
      ResidentialLoanApplicationController.setUamForBtns(sopAssets, loanRec);
      System.assertEquals(true, sopAssets.showEditExpenseBtn);
      System.assertEquals(true, sopAssets.showAddIncomeBtn);
    }
  }

  @isTest
  static void testSetUamForBtnsNegative() {
    ResidentialLoanApplication rla = new ResidentialLoanApplication();
    rla.Status = 'Completed';
    List<ResidentialLoanApplication> loanRec = new List<ResidentialLoanApplication>{
      rla
    };
    ResidentialLoanApplicationModel sopAssets = prepareRla();

    User coach = TestUtil.createTestUserWithProfile('ANZx Standard User');
    UserRole coachRole = [
      SELECT Id, Name
      FROM UserRole
      WHERE Name = :'BOH Coach'
    ];
    coach.UserRoleId = coachRole.Id;
    insert coach;

    System.runAs(coach) {
      ResidentialLoanApplicationController.setUamForBtns(sopAssets, loanRec);
      System.assertEquals(false, sopAssets.showAddIncomeBtn);
    }
  }

  static ResidentialLoanApplicationModel prepareRla() {
    ResidentialLoanApplicationModel sopAssets = new ResidentialLoanApplicationModel();
    ResidentialLoanApplicationModel.SOPIncomeSummary incomesSummary = new ResidentialLoanApplicationModel.SOPIncomeSummary();
    ResidentialLoanApplicationModel.SOPIncome income = new ResidentialLoanApplicationModel.SOPIncome();
    incomesSummary.incomes = new List<ResidentialLoanApplicationModel.SOPIncome>();
    incomesSummary.incomes.add(income);
    sopAssets.incomesSummary = incomesSummary;

    SOPAccounts acc = new SOPAccounts();
    acc.status = 'ACCOUNT_STATE_CLOSED';

    SOPDebtSummary liabilitiesSummary = new SOPDebtSummary();
    SOPDebt debt = new SOPDebt();
    debt.account = acc;
    debt.sources = new List<String>{ 'Manual' };
    liabilitiesSummary.liabilities = new List<SOPDebt>();
    liabilitiesSummary.liabilities.add(debt);
    sopAssets.liabilitiesSummary = liabilitiesSummary;

    ResidentialLoanApplicationModel.SOPAssetSummary assetsSummary = new ResidentialLoanApplicationModel.SOPAssetSummary();
    SOPAsset asset = new SOPAsset();
    asset.type = 'ASSET_TYPE_PROPERTY';
    asset.account = acc;
    assetsSummary.assets = new List<SOPAsset>();
    assetsSummary.assets.add(asset);
    sopAssets.assetsSummary = assetsSummary;

    return sopAssets;
  }

  @isTest
  static void testSetRefinanceSettings() {
    ResidentialLoanApplicationModel sopAssets = prepareRla();
    ResidentialLoanApplicationController.setRefinanceSettings(
      sopAssets,
      'TestAbc'
    );

    System.assertEquals(
      false,
      sopAssets.liabilitiesSummary.liabilities[0].hasRefinance
    );
  }

  @isTest
  static void testFilterAssets() {
    ResidentialLoanApplicationModel sopAssets = prepareRla();
    List<SOPAsset> assets = ResidentialLoanApplicationController.filterAssets(
      sopAssets
    );
    System.assertEquals(
      1,
      sopAssets.assetsSummary.assets.size(),
      'expect 1 asset in test data'
    );
    System.assertEquals(0, assets.size(), 'expect 0 asset after filter');
  }
  @isTest
  static void testFilterLiabilities() {
    ResidentialLoanApplicationModel sopAssets = prepareRla();
    List<SOPDebt> debts = ResidentialLoanApplicationController.filterLiabilities(
      sopAssets
    );
    System.assertEquals(
      1,
      sopAssets.liabilitiesSummary.liabilities.size(),
      'expect 1 debt in test data'
    );
    System.assertEquals(0, debts.size(), 'expect 0 debts after filter');
  }

  @isTest
  static void testEditDebts() {
    SOPDebtModel updateModel = new SOPDebtModel();
    updateModel.name = 'testName';
    updateModel.uid = 'testUid';
    updateModel.etag = 'testEtag';
    updateModel.outstandingBalance = new SOPDebtModel.SOPDebtMoney();
    updateModel.outstandingBalance.currencyCode = 'AUD';
    updateModel.outstandingBalance.units = '100';
    updateModel.outstandingBalance.nanos = 50;
    Account acc = TestDataFactory.createAccount(true);
    ResidentialLoanApplication rla = new ResidentialLoanApplication();
    rla.Name = 'Test Loan Application';
    rla.AccountId = acc.Id;
    rla.SOP_ID__c = '1234';
    insert rla;

    Map<String, Object> inputMap = new Map<String, Object>();
    inputMap.put('liabilities', updateModel);
    inputMap.put('loanAppId', rla.Id);

    Map<String, Object> outMap = new Map<String, Object>();

    ResidentialLoanApplicationController rlaCtrl = new ResidentialLoanApplicationController();
    Boolean result = rlaCtrl.editDebt(
      inputMap,
      outMap,
      new Map<String, Object>()
    );
    System.assertEquals(true, result, 'edit debt callout failed');
  }

  @isTest
  static void testDeleteDebt() {
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
      'deleteDebt',
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

  @isTest
  static void testGetBelongsToOptions() {
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> objectMap = new Map<String, Object>();

    inputMap.put('Tester A', '6771cd6f-27dc-4f1a-a51d-cb6bddf231dc');
    inputMap.put('Tester B', '963b62eb-5f65-434e-80bd-f67342c099d1');
    inputMap.put(
      'Joint',
      '6771cd6f-27dc-4f1a-a51d-cb6bddf231dc,963b62eb-5f65-434e-80bd-f67342c099d1'
    );

    ResidentialLoanApplicationController rlaCtrl = new ResidentialLoanApplicationController();
    Boolean isInvoked = rlaCtrl.invokeMethod(
      'getBelongsToOptions',
      inputMap,
      objectMap,
      new Map<String, Object>()
    );

    Object payload = objectMap.containsKey('object');

    System.assert(isInvoked, 'Method not invoked');
    System.assertNotEquals(payload, null, 'Empty JSON');
    System.assert(objectMap.containsKey('options'), 'missing options');
  }
}
