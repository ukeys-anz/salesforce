/**
 * @author MLCRM developer
 * @since 07/2024
 * @description Test class for LeadConversionActions
 */
@isTest
private class LeadConversionActionsTest {
  static Id idAccount = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
  static Id idContact = Lib_FakeIdGenerator.getMockId(contact.SObjectType);
  static Id idLead = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
  static Id idOpp = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);

  /**
   * @description test method for getSuccessConvertedLeads
   */
  @isTest
  static void getSuccessConvertedLeadsTest() {
    List<Database.LeadConvertResult> lcResults = new List<Database.LeadConvertResult>{
      getMockLeadConvertResult('{"success":true}')
    };
    LeadConversionActions objClass = new LeadConversionActions();
    Test.startTest();
    List<Database.LeadConvertResult> lcSucessResults = objClass.getSuccessConvertedLeads(
      lcResults
    );
    Test.stopTest();
    Assert.areEqual(
      lcSucessResults.size(),
      lcResults.size(),
      'There are some issue during Lead conversion'
    );
  }

  /**
   * @description Returns a mock Database.LeadConvertResult record
   * @param mockLeadConvertResultString The mock LeadConvert result string
   * @return A mock Database.LeadConvertResult record
   */
  private static Database.LeadConvertResult getMockLeadConvertResult(
    String mockLeadConvertResultString
  ) {
    return (Database.LeadConvertResult) JSON.deserialize(
      mockLeadConvertResultString,
      Database.LeadConvertResult.class
    );
  }

  /**
   * @description test method for getConvertedLeads
   */
  @isTest
  static void getConvertedLeadsTest() {
    List<Lead> lstOfLead = new List<Lead>();
    Map<Id, Id> mapOfOpportunityId = new Map<Id, Id>();
    Map<Id, List<Lead>> matchingLeadsByAccIdMap = new Map<Id, List<Lead>>();
    Lead objLead = new Lead(
      Lead_Originator__c = 'Unica',
      RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID,
      Id = idLead
    );
    lstOfLead.add(objLead);
    matchingLeadsByAccIdMap.put(idAccount, lstOfLead);
    Database.LeadConvertResult objLcResults = (Database.LeadConvertResult) JSON.deserialize(
      JSON.serialize(
        new Map<String, Object>{
          'accountid' => idAccount,
          'contactid' => idContact,
          'leadid' => idLead,
          'opportunityid' => idOpp
        }
      ),
      Database.LeadConvertResult.class
    );
    List<Database.LeadConvertResult> lcResults = new List<Database.LeadConvertResult>();
    lcResults.add(objLcResults);
    LeadConversionActions objClass = new LeadConversionActions();
    Test.startTest();
    List<Lead> convertedLeads = objClass.getConvertedLeads(
      lcResults,
      matchingLeadsByAccIdMap
    );
    Test.stopTest();
    Assert.areEqual(
      true,
      convertedLeads.size() > 0,
      'There are some issue during Lead conversion'
    );
  }
  /**
   * @description test method for getLeadListForUnicaAdobeOnLC
   */
  @isTest
  static void getLeadListForUnicaAdobeOnLCTest() {
    List<Lead> lstOfLead = new List<Lead>();
    Lead objLead = new Lead(
      Lead_Originator__c = 'Adobe',
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID,
      Id = idLead
    );
    lstOfLead.add(objLead);

    LeadConversionActions objClass = new LeadConversionActions();
    Test.startTest();
    Set<Id> leadIdSet = objClass.getLeadListForUnicaAdobeOnLC(lstOfLead);
    Test.stopTest();
    Assert.areEqual(
      1,
      leadIdSet.size(),
      'getLeadListForUnicaAdobeOnLCTest method failed to validate'
    );
  }
  /**
   * @description test method for getCCRMLeadsMap
   */
  @isTest
  static void getCCRMLeadsMapWithCCRMLeadTest() {
    List<Lead> lstOfLead = new List<Lead>();
    Lead objLead = new Lead(
      Lead_Originator__c = 'Adobe',
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID,
      Id = idLead
    );
    lstOfLead.add(objLead);

    LeadConversionActions objClass = new LeadConversionActions();
    Test.startTest();
    Map<Id, Lead> leadMap = objClass.getCCRMLeadsMap(lstOfLead);
    Test.stopTest();
    Assert.areEqual(
      1,
      leadMap.size(),
      'getCCRMLeadsMapTest method failed to validate'
    );
  }
  /**
   * @description test method for getCCRMLeadsMap
   */
  @isTest
  static void getCCRMLeadsMapWithMLCRMLeadTest() {
    List<Lead> lstOfLead = new List<Lead>();
    Lead objLead = new Lead(
      Lead_Originator__c = 'Adobe',
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID,
      Id = idLead
    );
    lstOfLead.add(objLead);

    LeadConversionActions objClass = new LeadConversionActions();
    Test.startTest();
    Map<Id, Lead> leadMap = objClass.getCCRMLeadsMap(lstOfLead);
    Test.stopTest();
    Assert.areEqual(
      0,
      leadMap.size(),
      'getCCRMLeadsMapTest method failed to validate'
    );
  }
  /**
   * @description test method for getDCRMLeadsMap
   */
  @isTest
  static void getDCRMLeadsMapTest() {
    List<Lead> lstOfLead = new List<Lead>();
    Lead objLead = new Lead(
      Lead_Originator__c = 'Adobe',
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID,
      Id = idLead
    );
    lstOfLead.add(objLead);

    LeadConversionActions objClass = new LeadConversionActions();
    Test.startTest();
    Map<Id, Lead> leadMap = objClass.getDCRMLeadsMap(lstOfLead);
    Test.stopTest();
    Assert.areEqual(
      1,
      leadMap.size(),
      'getDCRMLeadsMapTest method failed to validate'
    );
  }
  /**
   * @description test method for isAutoMisMatchTaskRequired
   */
  @isTest
  static void isAutoMisMatchTaskRequiredForMLCRMTest() {
    List<Lead> lstOfLead = new List<Lead>();
    Lead objLead = new Lead(
      Lead_Originator__c = 'Adobe',
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID,
      Id = idLead
    );
    lstOfLead.add(objLead);

    LeadConversionActions objClass = new LeadConversionActions();
    Test.startTest();
    Boolean autoMisMatchTaskRequired = objClass.isAutoMisMatchTaskRequired(
      lstOfLead
    );
    Test.stopTest();
    Assert.areEqual(
      true,
      autoMisMatchTaskRequired,
      'isAutoMisMatchTaskRequiredTest method failed to validate'
    );
  }
  /**
   * @description test method for getContactsToDelete
   */
  @isTest
  static void getContactsToDeleteTest() {
    Map<Id, Lead> mapOfLead = new Map<Id, Lead>();
    Lead objLead = new Lead(
      Lead_Originator__c = 'Adobe',
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID,
      Id = idLead
    );
    mapOfLead.put(idLead, objLead);

    Database.LeadConvertResult objLcResults = (Database.LeadConvertResult) JSON.deserialize(
      JSON.serialize(
        new Map<String, Object>{
          'accountid' => idAccount,
          'contactid' => idContact,
          'leadid' => idLead,
          'opportunityid' => idOpp
        }
      ),
      Database.LeadConvertResult.class
    );
    List<Database.LeadConvertResult> lcResults = new List<Database.LeadConvertResult>();
    lcResults.add(objLcResults);
    LeadConversionActions objClass = new LeadConversionActions();
    Test.startTest();
    Set<ID> contactIDSet = objClass.getContactsToDelete(lcResults, mapOfLead);
    Test.stopTest();
    Assert.areEqual(
      1,
      contactIDSet.size(),
      'getContactsToDeleteTest method failed to validate'
    );
  }
  /**
   * @description test method for getMapOfAccountIdWithCCRMLead
   */
  @isTest
  static void getMapOfAccountIdWithCCRMLeadTest() {
    Map<Id, Lead> mapOfLead = new Map<Id, Lead>();
    Lead objLead = new Lead(
      Lead_Originator__c = 'Adobe',
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID,
      Id = idLead
    );
    mapOfLead.put(idLead, objLead);

    Database.LeadConvertResult objLcResults = (Database.LeadConvertResult) JSON.deserialize(
      JSON.serialize(
        new Map<String, Object>{
          'accountid' => idAccount,
          'contactid' => idContact,
          'leadid' => idLead,
          'opportunityid' => idOpp
        }
      ),
      Database.LeadConvertResult.class
    );
    List<Database.LeadConvertResult> lcResults = new List<Database.LeadConvertResult>();
    lcResults.add(objLcResults);
    LeadConversionActions objClass = new LeadConversionActions();
    Test.startTest();
    Map<Id, Id> mapOfAccountIdWithLead = objClass.getMapOfAccountIdWithCCRMLead(
      lcResults,
      mapOfLead
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      mapOfAccountIdWithLead.size(),
      'getMapOfAccountIdWithCCRMLeadTest method failed to validate'
    );
  }
}
