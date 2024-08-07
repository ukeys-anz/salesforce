/**
 * @author MLCRM-Developer
 * @since 06/2024
 * @description AccountCommonActionsTest is the test class for AccountCommonActions Class.
 */
@isTest
public class AccountCommonActionsTest {
  /**
   * @description test method for divCRMPostLeadConversionActions
   */
  @isTest
  static void testDivCRMPostLeadConversionActions() {
    List<Lead> lstOfLead = new List<Lead>();
    Map<Id, Id> mapOfOpportunityId = new Map<Id, Id>();
    Map<Id, List<Lead>> matchingLeadsByAccIdMap = new Map<Id, List<Lead>>();
    Id idLead = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id idOpp = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id idAccount = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id idContact = Lib_FakeIdGenerator.getMockId(contact.SObjectType);
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Lead objLead = new Lead(
      OwnerId = idOwner,
      Territory__c = idTerritory,
      Lead_Originator__c = 'Unica',
      RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID,
      Id = idLead
    );
    lstOfLead.add(objLead);
    Task objTask = new Task(
      id = Lib_FakeIdGenerator.getMockId(Task.SObjectType),
      whoid = idLead,
      subject = 'Test Task'
    );
    CCRMLeadPlatformEventHelper.leadTask = new List<Task>{ objTask };
    matchingLeadsByAccIdMap.put(idAccount, lstOfLead);
    mapOfOpportunityId.put(idLead, idOpp);
    Database.LeadConvertResult objLcResults = (Database.LeadConvertResult) JSON.deserialize(
      JSON.serialize(
        new Map<String, Object>{
          'accountid' => idAccount,
          'contactid' => idContact,
          'leadid' => idLead,
          'opportunityid' => idOpp,
          'success' => true
        }
      ),
      Database.LeadConvertResult.class
    );
    List<Database.LeadConvertResult> lcResults = new List<Database.LeadConvertResult>{
      objLcResults
    };
    Test.startTest();
    AccountCommonActions.LeadDMLOperator objClass = new AccountCommonActions.LeadDMLOperator();
    objClass.divCRMPostLeadConversionActions(
      matchingLeadsByAccIdMap,
      lcResults,
      mapOfOpportunityId
    );
    Test.stopTest();
    System.AssertEquals(
      null,
      objTask.whoid,
      'Task does not get removed from the lead'
    );
    System.AssertEquals(
      idOpp,
      objTask.whatid,
      'Task did not get transferred to opportunity'
    );
  }
}
