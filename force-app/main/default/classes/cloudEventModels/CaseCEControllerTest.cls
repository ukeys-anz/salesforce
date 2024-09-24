/**
 * @author Hrushikesh Pathak
 * @since  06/2024
 * @description  Test Class of CaseCEController
 */
@isTest
public class CaseCEControllerTest {
  // test cloud event for the NPP Dispute
  @isTest
  public static void testNPPDisputeCase() {
    Case theCase = TestDataFactory.createCase('NPP_Dispute');
    RecordType rt = [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE Id = :(theCase.RecordTypeId)
      LIMIT 1
    ];
    theCase = (Case) TestDataFactory.populateRecordType(theCase, rt);
    theCase.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    Test.startTest();
    CaseCEController.publishCloudEvents(new List<Case>{ theCase });
    Test.stopTest();
    String payload = CloudEventController.cloudEvents[0].Data_1__c;
    NPPDisputeCaseCloudEventModel nppDisputeCaseCloudEventModel = (NPPDisputeCaseCloudEventModel) JSON.deserialize(
      payload,
      NPPDisputeCaseCloudEventModel.class
    );
    Assert.isTrue(
      nppDisputeCaseCloudEventModel.ce_type.contains('v1beta1.dispute.npp'),
      'ce_type is incorrect'
    );
    Assert.areEqual(
      1,
      CloudEventController.cloudEvents.size(),
      'Cloud Event should be generated'
    );
  }

  // test cloud event for the NPP Dispute
  @isTest
  public static void testNPPDisputeCaseForStatusChange() {
    Map<String, Case> theCaseMap = getTestCaseRecord('NPP_Dispute');
    Test.startTest();
    CaseCEController.publishCloudEvents(
      new List<Case>{ theCaseMap.get('newCase') },
      new Map<Id, Case>{
        theCaseMap.get('oldCase').Id => theCaseMap.get('oldCase')
      }
    );
    Test.stopTest();
    String payload = CloudEventController.cloudEvents[0].Data_1__c;
    NPPDisputeCaseCloudEventModel nppDisputeCaseCloudEventModel = (NPPDisputeCaseCloudEventModel) JSON.deserialize(
      payload,
      NPPDisputeCaseCloudEventModel.class
    );
    Assert.isTrue(
      nppDisputeCaseCloudEventModel.ce_type.contains('v1beta1.dispute.npp'),
      'ce_type is incorrect'
    );
    Assert.areEqual(
      2,
      CloudEventController.cloudEvents.size(),
      'Cloud Event should be generated'
    );
  }

  // test cloud event for the NPP Fraud Dispute
  @isTest
  public static void testNPPFraudDisputeCaseForStatusChange() {
    Map<String, Case> theCaseMap = getTestCaseRecord('NPP_Dispute');
    theCaseMap.get('newCase').Dispute_Reason__c = 'Unauthorised Transaction';
    Test.startTest();
    CaseCEController.publishCloudEvents(
      new List<Case>{ theCaseMap.get('newCase') },
      new Map<Id, Case>{
        theCaseMap.get('oldCase').Id => theCaseMap.get('oldCase')
      }
    );
    Test.stopTest();
    String payload = CloudEventController.cloudEvents[0].Data_1__c;
    NPPFraudDisputeCaseCloudEventModel nppFruadDisputeCaseCloudEventModel = (NPPFraudDisputeCaseCloudEventModel) JSON.deserialize(
      payload,
      NPPFraudDisputeCaseCloudEventModel.class
    );
    Assert.isTrue(
      nppFruadDisputeCaseCloudEventModel.ce_type.contains(
        'v1beta1.dispute.nppfraud'
      ),
      'ce_type is incorrect'
    );
    Assert.areEqual(
      2,
      CloudEventController.cloudEvents.size(),
      'Cloud Event should be generated'
    );
  }

  // test cloud event for the BPay Dispute
  @isTest
  public static void testBPayDisputeCaseForStatusChange() {
    Map<String, Case> theCaseMap = getTestCaseRecord('BPAY_Dispute');
    Test.startTest();
    CaseCEController.publishCloudEvents(
      new List<Case>{ theCaseMap.get('newCase') },
      new Map<Id, Case>{
        theCaseMap.get('oldCase').Id => theCaseMap.get('oldCase')
      }
    );
    Test.stopTest();
    String payload = CloudEventController.cloudEvents[0].Data_1__c;
    BPayDisputeCaseCloudEventModel bpayDisputeCaseCloudEventModel = (BPayDisputeCaseCloudEventModel) JSON.deserialize(
      payload,
      BPayDisputeCaseCloudEventModel.class
    );
    Assert.isTrue(
      bpayDisputeCaseCloudEventModel.ce_type.contains('v1beta1.dispute.bpay'),
      'ce_type is incorrect'
    );
    Assert.areEqual(
      2,
      CloudEventController.cloudEvents.size(),
      'Cloud Event should be generated'
    );
  }

  // test cloud event for the Direct Debit Dispute
  @isTest
  public static void testDDDisputeCaseForStatusChange() {
    Map<String, Case> theCaseMap = getTestCaseRecord('Direct_Debit_Dispute');
    Test.startTest();
    CaseCEController.publishCloudEvents(
      new List<Case>{ theCaseMap.get('newCase') },
      new Map<Id, Case>{
        theCaseMap.get('oldCase').Id => theCaseMap.get('oldCase')
      }
    );
    Test.stopTest();
    String payload = CloudEventController.cloudEvents[0].Data_1__c;
    DirectDebitDisputeCaseCloudEventModel ddDisputeCaseCloudEventModel = (DirectDebitDisputeCaseCloudEventModel) JSON.deserialize(
      payload,
      DirectDebitDisputeCaseCloudEventModel.class
    );
    Assert.isTrue(
      ddDisputeCaseCloudEventModel.ce_type.contains(
        'v1beta1.dispute.directdebit'
      ),
      'ce_type is incorrect'
    );
    Assert.areEqual(
      2,
      CloudEventController.cloudEvents.size(),
      'Cloud Event should be generated'
    );
  }

  // test cloud event for the Direct Entry Dispute
  @isTest
  public static void testDEDisputeCaseForStatusChange() {
    Map<String, Case> theCaseMap = getTestCaseRecord('Direct_Entry_Dispute');
    Test.startTest();
    CaseCEController.publishCloudEvents(
      new List<Case>{ theCaseMap.get('newCase') },
      new Map<Id, Case>{
        theCaseMap.get('oldCase').Id => theCaseMap.get('oldCase')
      }
    );
    Test.stopTest();
    String payload = CloudEventController.cloudEvents[0].Data_1__c;
    DirectEntryDisputeCaseCloudEventModel deDisputeCaseCloudEventModel = (DirectEntryDisputeCaseCloudEventModel) JSON.deserialize(
      payload,
      DirectEntryDisputeCaseCloudEventModel.class
    );
    Assert.isTrue(
      deDisputeCaseCloudEventModel.ce_type.contains(
        'v1beta1.dispute.directentry'
      ),
      'ce_type is incorrect'
    );
    Assert.areEqual(
      2,
      CloudEventController.cloudEvents.size(),
      'Cloud Event should be generated'
    );
  }

  // test cloud event for the PayTo Dispute
  @isTest
  public static void testPayToDisputeCaseForStatusChange() {
    Map<String, Case> theCaseMap = getTestCaseRecord('PayTo_Dispute');
    Test.startTest();
    CaseCEController.publishCloudEvents(
      new List<Case>{ theCaseMap.get('newCase') },
      new Map<Id, Case>{
        theCaseMap.get('oldCase').Id => theCaseMap.get('oldCase')
      }
    );
    Test.stopTest();
    String payload = CloudEventController.cloudEvents[0].Data_1__c;
    PayToDisputeCaseCloudEventModel payToDisputeCaseCloudEventModel = (PayToDisputeCaseCloudEventModel) JSON.deserialize(
      payload,
      PayToDisputeCaseCloudEventModel.class
    );
    Assert.isTrue(
      payToDisputeCaseCloudEventModel.ce_type.contains('v1beta1.dispute.payto'),
      'ce_type is incorrect'
    );
    Assert.areEqual(
      2,
      CloudEventController.cloudEvents.size(),
      'Cloud Event should be generated'
    );
  }

  // test cloud event for the ATM Dispute
  @isTest
  public static void testAtmDisputeCaseForStatusChange() {
    Map<String, Case> theCaseMap = getTestCaseRecord('ATM_Dispute');
    Test.startTest();
    CaseCEController.publishCloudEvents(
      new List<Case>{ theCaseMap.get('newCase') },
      new Map<Id, Case>{
        theCaseMap.get('oldCase').Id => theCaseMap.get('oldCase')
      }
    );
    Test.stopTest();
    List<Cloud_Event__e> payloads = CloudEventController.cloudEvents;
    Boolean isAtmTypeEvent = false;
    for (Cloud_Event__e payload : payloads) {
      Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(
        payload.Data_1__c
      );
      if (((String) payloadMap.get('ce_type')).contains('dispute.atm')) {
        isAtmTypeEvent = true;
      }
    }
    Assert.isTrue(isAtmTypeEvent, 'ce_type is incorrect');
    Assert.areEqual(
      4,
      CloudEventController.cloudEvents.size(),
      'Cloud Event should be generated'
    );
  }

  // test cloud event for the Card Dispute
  @isTest
  public static void testCardDisputeCaseForStatusChange() {
    Map<String, Case> theCaseMap = getTestCaseRecord('Card_Dispute');
    Test.startTest();
    CaseCEController.publishCloudEvents(
      new List<Case>{ theCaseMap.get('newCase') },
      new Map<Id, Case>{
        theCaseMap.get('oldCase').Id => theCaseMap.get('oldCase')
      }
    );
    Test.stopTest();
    List<Cloud_Event__e> payloads = CloudEventController.cloudEvents;
    Boolean isCardTypeEvent = false;
    for (Cloud_Event__e payload : payloads) {
      Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(
        payload.Data_1__c
      );
      if (((String) payloadMap.get('ce_type')).contains('dispute.card')) {
        isCardTypeEvent = true;
      }
    }
    Assert.isTrue(isCardTypeEvent, 'ce_type is incorrect');
    Assert.areEqual(
      4,
      CloudEventController.cloudEvents.size(),
      'Cloud Event should be generated'
    );
  }

  /**
   * @description get test case and old case record for test
   * @param recordTypeDeveloperName developer name of record type
   * @return Map of new case and old case
   */
  private static Map<String, Case> getTestCaseRecord(
    String recordTypeDeveloperName
  ) {
    Case theCase = TestDataFactory.createCase(recordTypeDeveloperName);
    RecordType rt = [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE Id = :(theCase.RecordTypeId)
      LIMIT 1
    ];
    theCase = (Case) TestDataFactory.populateRecordType(theCase, rt);
    theCase.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    theCase.AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    theCase.OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Case theOldCase = TestDataFactory.createCase(recordTypeDeveloperName);
    theOldCase.Id = theCase.Id;
    theOldCase.Status = 'On Hold';
    theOldCase = (Case) TestDataFactory.populateRecordType(theOldCase, rt);
    return new Map<String, Case>{
      'newCase' => theCase,
      'oldCase' => theOldCase
    };
  }
}
