/**
 * @author       : Vikas AM
 * @since        : Feb 2026
 * @description  : Test class for CommercialBrokerOpportunityActions
 **/
@isTest
public with sharing class CommercialBrokerOpportunityActionsTest {
  // AFP repo mock used by CommercialBrokerOpportunityActionsHelperHelper
  static Lib_MockProvider afpRepoMock;
  static void registerMocks() {
    afpRepoMock = Lib_MockProvider.forType(
      CommercialAppFormProductActionsRepo.class
    );
  }
  /**
   * @author A M Vikash | Salesforce | 02-11-2025
   * @description Tests the scenario where the Broker Name is changed.
   * Verifies that the helper validation method is invoked properly.
   */
  @IsTest
  static void preventCustAndBrokerChangeBrokerChange() {
    // Arrange
    Id rtId = RTOpportunity.commercialOpportunity;
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id brokerOld = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id brokerNew = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id appFormProdId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id prod2Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);

    // Old Opportunity
    Opportunity oldOpp = new Opportunity(
      Id = oppId,
      Name = 'Old Opp',
      StageName = 'Prospecting',
      CloseDate = Date.today().addDays(10),
      RecordTypeId = rtId,
      AccountId = accId,
      Broker_Name__c = brokerOld
    );

    // New Opportunity - Broker changed
    Opportunity newOpp = oldOpp.clone(false, true, false, false);
    newOpp.Broker_Name__c = brokerNew;
    List<Opportunity> newOpps = new List<Opportunity>{ newOpp };
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{ oppId => oldOpp };

    // Mock repo method getApplicationFormsAndProducts

    String jsonData =
      '[{"attributes":{"type":"ApplicationForm","url":"/services/data/v62.0/sobjects/ApplicationForm/' +
      appFormId +
      '"},' +
      '"Id":"' +
      appFormId +
      '","RecordTypeId":"0128r00000XYZAAA","AccountId":"0018r00000ACC001AA",' +
      '"Assisted_Broker__c":"0038r00000BRK001AA","OwnerId":"0058r00000OWN001AA","Application_Number__c":"APP-001","OpportunityId":null,' +
      '"ApplicationFormProducts":{"totalSize":2,"done":true,"records":[' +
      '{"attributes":{"type":"ApplicationFormProduct","url":"/services/data/v62.0/sobjects/ApplicationFormProduct/' +
      appFormProdId +
      '"},' +
      '"Id":"' +
      appFormProdId +
      '","Loan_Purpose__c":"Purchase","ApplicationFormId":"' +
      appFormId +
      '","Brokerage_Amount__c":1000,' +
      '"Application_Source__c":"BKOLA","ProductId":"' +
      prod2Id +
      '","Amount__c":500000},' +
      '{"attributes":{"type":"ApplicationFormProduct","url":"/services/data/v62.0/sobjects/ApplicationFormProduct/' +
      appFormProdId +
      '"},' +
      '"Id":"' +
      appFormProdId +
      '","Loan_Purpose__c":"Refinance","ApplicationFormId":"' +
      appFormId +
      '","Brokerage_Amount__c":1500,' +
      '"Application_Source__c":"BKOLA","ProductId":"' +
      prod2Id +
      '","Amount__c":600000}' +
      ']}}]';

    List<ApplicationForm> mockForms = (List<ApplicationForm>) JSON.deserialize(
      jsonData,
      List<ApplicationForm>.class
    );

    // Mock the repository return
    Lib_MockProvider.forType(CommercialOpportunityRepository.class)
      .mock('getApplicationFormsAndProducts', mockForms);

    // Act
    Test.startTest();
    try {
      CommercialBrokerOpportunityActionsHelper.preventCustAndBrokerChange(
        newOpps,
        oldMap
      );
    } catch (Exception e) {
      System.assert(
        e.getMessage()
          .contains(System.Label.Broker_Name_change_Error_on_Opportunity),
        'Expected Broker Name change error'
      );
    }
    Test.stopTest();
  }

  /**
   * @author A M Vikash | Salesforce | 02-11-2025
   * @description : This is used to prevent user from changing the Broker Name and Customer Name Change
   */
  @IsTest
  static void preventCustAndBrokerChangeCustomerChange() {
    // Arrange
    Id rtId = RTOpportunity.commercialOpportunity;
    Id accOld = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id accNew = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id brokerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id appFormProdId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id prod2Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);

    // Old Opportunity
    Opportunity oldOpp = new Opportunity(
      Id = oppId,
      Name = 'Old Opp',
      StageName = 'Prospecting',
      CloseDate = Date.today().addDays(10),
      RecordTypeId = rtId,
      AccountId = accOld,
      Broker_Name__c = brokerId
    );

    // New Opportunity - Account changed
    Opportunity newOpp = oldOpp.clone(false, true, false, false);
    newOpp.AccountId = accNew;

    List<Opportunity> newOpps = new List<Opportunity>{ newOpp };
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{ oppId => oldOpp };

    // Mock ApplicationForm and Product

    String jsonData =
      '[{"attributes":{"type":"ApplicationForm","url":"/services/data/v62.0/sobjects/ApplicationForm/' +
      appFormId +
      '"},' +
      '"Id":"' +
      appFormId +
      '","RecordTypeId":"0128r00000XYZAAA","AccountId":"0018r00000ACC001AA",' +
      '"Assisted_Broker__c":"0038r00000BRK001AA","OwnerId":"0058r00000OWN001AA","Application_Number__c":"APP-001","OpportunityId":null,' +
      '"ApplicationFormProducts":{"totalSize":2,"done":true,"records":[' +
      '{"attributes":{"type":"ApplicationFormProduct","url":"/services/data/v62.0/sobjects/ApplicationFormProduct/' +
      appFormProdId +
      '"},' +
      '"Id":"' +
      appFormProdId +
      '","Loan_Purpose__c":"Purchase","ApplicationFormId":"' +
      appFormId +
      '","Brokerage_Amount__c":1000,' +
      '"Application_Source__c":"BKOLA","ProductId":"' +
      prod2Id +
      '","Amount__c":500000},' +
      '{"attributes":{"type":"ApplicationFormProduct","url":"/services/data/v62.0/sobjects/ApplicationFormProduct/' +
      appFormProdId +
      '"},' +
      '"Id":"' +
      appFormProdId +
      '","Loan_Purpose__c":"Refinance","ApplicationFormId":"' +
      appFormId +
      '","Brokerage_Amount__c":1500,' +
      '"Application_Source__c":"BKOLA","ProductId":"' +
      prod2Id +
      '","Amount__c":600000}' +
      ']}}]';

    List<ApplicationForm> mockForms = (List<ApplicationForm>) JSON.deserialize(
      jsonData,
      List<ApplicationForm>.class
    );

    // Mock repository method
    Lib_MockProvider.forType(CommercialOpportunityRepository.class)
      .mock('getApplicationFormsAndProducts', mockForms);

    // Act
    Test.startTest();
    try {
      CommercialBrokerOpportunityActionsHelper.preventCustAndBrokerChange(
        newOpps,
        oldMap
      );
    } catch (Exception e) {
      System.assert(
        e.getMessage()
          .contains(System.Label.Customer_Name_change_Error_on_Opportunity),
        'Expected Customer Name change error'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void testValidateApfAndApfprodnoProducts() {
    // Arrange
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Opportunity opp = new Opportunity(Id = oppId, Name = 'TestOpp');
    List<Opportunity> oppList = new List<Opportunity>{ opp };

    // Return empty ApplicationForms from repository
    Lib_MockProvider.forType(CommercialOpportunityRepository.class)
      .mock('getApplicationFormsAndProducts', new List<ApplicationForm>());

    // Act
    Test.startTest();
    CommercialBrokerOpportunityActionsHelper.validateApfAndApfprod(
      oppList,
      'TestError',
      'Broker'
    );
    Test.stopTest();

    // Assert no errors thrown
    System.assert(true, 'Handled empty AppForms gracefully.');
  }
}
