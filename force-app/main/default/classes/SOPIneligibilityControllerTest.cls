/**
 * @author @ramvilas
 * @since August 2024
 * @description Test class for SOPIneligibilityController
 */
@isTest
public class SOPIneligibilityControllerTest {
  static Lib_MockProvider loanRecordMock;

  static void registerMocks() {
    loanRecordMock = Lib_MockProvider.forType(
        ResidentialLoanApplicationRepository.class
      )
      .mock('queryRLAById', getRLA);
  }

  @isTest
  static void testInvokeMethodInvalidMethod() {
    SOPIneligibilityController sopCtrl = new SOPIneligibilityController();

    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> objectMap = new Map<String, Object>();

    Test.StartTest();
    Boolean isInvoked = sopCtrl.invokeMethod(
      'invalidMethodName',
      inputMap,
      objectMap,
      new Map<String, Object>()
    );

    Test.stopTest();
    Assert.isFalse(isInvoked, 'Method not invoked');
  }

  @isTest
  static void testGetSOPSuccess() {
    registerMocks();

    SOPIneligibilityController sopCtrl = new SOPIneligibilityController();

    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> objectMap = new Map<String, Object>();
    Map<String, Map<String, Object>> args = new Map<String, Map<String, Object>>();

    inputMap.put(
      'loanId',
      Lib_FakeIdGenerator.getMockId(ResidentialLoanApplication.SObjectType)
    );
    args.put('input', inputMap);
    args.put('output', objectMap);

    Test.startTest();
    sopCtrl.call('getIneligibleReasons', args);
    Test.stopTest();

    Object payload = objectMap.get('object');

    Assert.areNotEqual(payload, null, 'Empty JSON');

    SOPIneligibleModel model = (SOPIneligibleModel) JSON.deserialize(
      json.serialize(objectMap.get('object')),
      SOPIneligibleModel.class
    );

    Assert.areEqual(
      'Has an unsupported ANZ Product',
      model.ineligibleReasonsWithInfo[0].ineligibleReasonType,
      'SOP not transformed'
    );
  }

  @isTest
  static void testInvokeMethodInvalidLoanId() {
    Id invalidId;

    SOPIneligibilityController sopCtrl = new SOPIneligibilityController();

    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> objectMap = new Map<String, Object>();
    Map<String, Map<String, Object>> args = new Map<String, Map<String, Object>>();

    inputMap.put('loanId', invalidId);
    args.put('input', inputMap);
    Boolean isInvoked = true;
    try {
      Test.startTest();
      isInvoked = sopCtrl.invokeMethod(
        'getIneligibleReasons',
        inputMap,
        objectMap,
        new Map<String, Object>()
      );
      Test.stopTest();
    } catch (Exception e) {
      isInvoked = false;
    }

    Assert.isFalse(isInvoked, 'Method not invoked');
  }

  static ResidentialLoanApplication getRLA {
    get {
      ResidentialLoanApplication rla = new ResidentialLoanApplication();
      rla.Id = Lib_FakeIdGenerator.getMockId(
        ResidentialLoanApplication.SObjectType
      );
      rla.Name = 'Test Loan Application';
      rla.AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
      rla.SOP_ID__c = '1234';

      return rla;
    }
  }
}
