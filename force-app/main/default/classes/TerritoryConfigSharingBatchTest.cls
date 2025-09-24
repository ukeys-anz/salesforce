/**
 * @author Ashish Kumar
 * @since 07/2023
 * @description Test class for user territory update batch sharing.
 */
@isTest
public class TerritoryConfigSharingBatchTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider userTerritoryMockProvider;
  static Lib_MockProvider territoryMockProvider;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    userTerritoryMockProvider = Lib_MockProvider.forType(
      UserTerritoryActionsRepository.class
    );
    territoryMockProvider = Lib_MockProvider.forType(
      TerritoryActionsRepository.class
    );
  }

  /**
   * @description test method for testing Recalculation
   */
  @isTest
  static void testRecalculationWhenScopeIsTerritory() {
    registerMocks();
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idOwner2 = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idLead = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    List<Lead> lstOfSobject = new List<Lead>{
      new Lead(Id = idLead, OwnerId = idOwner, Territory__c = idTerritory)
    };
    Territory_Based_Sharing_Config__mdt objMtd = getTerritorySharingConfig();
    objMtd.Row_Cause__c = 'Manual';
    objMtd.Sharing_Scope__c = 'Territory';
    objMtd.Sharing_Object__c = 'LeadShare';
    objMtd.Territory_Field__c = 'Territory__c';

    userTerritoryMockProvider.mock(
      'getUserTerritories',
      new List<User_Territory__c>{
        new User_Territory__c(
          ML_Role__c = 'Loan Writer',
          User__c = idOwner,
          Territory__c = idTerritory,
          Territory__r = new Territory__c(Access_Scope__c = 'Unrestricted')
        ),
        new User_Territory__c(
          ML_Role__c = 'Loan Writer',
          User__c = idOwner2,
          Territory__c = idTerritory,
          Territory__r = new Territory__c(Access_Scope__c = 'Unrestricted')
        )
      }
    );
    territoryMockProvider.mock(
      'getShareRecords',
      new List<LeadShare>{
        new LeadShare(
          Id = Lib_FakeIdGenerator.getMockId(LeadShare.SObjectType),
          UserOrGroupId = idOwner,
          LeadId = idLead
        )
      }
    );
    Test.startTest();
    TerritoryConfigSharingBatch objBatch = new TerritoryConfigSharingBatch(
      objMtd,
      new Set<Id>{ idTerritory }
    );
    Database.executeBatch(objBatch);
    objBatch.execute(null, lstOfSobject);
    Test.stopTest();

    List<LeadShare> createdLeadShare = (List<LeadShare>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');

    List<LeadShare> deletedLeadShare = (List<LeadShare>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      idOwner2,
      createdLeadShare[0].UserOrGroupId,
      'Share Record for other user in territory not created'
    );
    Assert.areEqual(
      idOwner,
      deletedLeadShare[0].UserOrGroupId,
      'Share Record for curent owner is not deleted'
    );
  }

  // Test Method to validate look up field to be populated in the query build
  @isTest
  static void validateComposeLookupFields() {
    Territory_Based_Sharing_Config__mdt objMtd = getTerritorySharingConfig();
    objMtd.Lookup_Fields__c = 'Lead__c;Opportunity__c;Customer_Relationship__c';
    TerritoryConfigSharingBatch objBatch = new TerritoryConfigSharingBatch();
    Test.startTest();
    String strLookupFields = objBatch.composeLookupFields(objMtd);
    Test.stopTest();
    Assert.areEqual(
      'Lead__c,Opportunity__c,Customer_Relationship__c,',
      strLookupFields,
      'Look up fields did not populated correctly'
    );
  }

  // Test Method to validate compose of query
  @isTest
  static void validateComposeQuery() {
    Territory_Based_Sharing_Config__mdt objMtd = getTerritorySharingConfig();
    objMtd.Territory_Field__c = 'Territory__c';
    objMtd.Lookup_Fields__c = 'Lead__c;Opportunity__c;Customer_Relationship__c';
    String strWhereClause = 'WHERE CreatedDate >=:objDateTime AND CreatedById IN: setOfExcludedUsers';
    Test.startTest();
    TerritoryConfigSharingBatch objBatch = new TerritoryConfigSharingBatch();
    String composedQuery = objBatch.composeQuery(
      objMtd.Lookup_Fields__c,
      strWhereClause,
      objMtd
    );
    Test.stopTest();
    Assert.isTrue(
      composedQuery.contains(strWhereClause),
      'query did not formed correctly'
    );
  }

  //Method to validate set of eligible recordtype ids
  @isTest
  static void validateGetEligibleRT() {
    Territory_Based_Sharing_Config__mdt objMtd = getTerritorySharingConfig();
    objMtd.Territory_Field__c = 'Territory__c';
    objMtd.Excluded_Users__c = 'Adobe.Integration@anzx.com';
    Test.startTest();
    TerritoryConfigSharingBatch objBatch = new TerritoryConfigSharingBatch();
    Set<Id> setOfEligibleRT = objBatch.getEligibleRT(objMtd);
    Test.stopTest();
    Assert.areEqual(
      1,
      setOfEligibleRT.size(),
      'Eligible recordtype id did not fetched correctly'
    );
  }
  /**
   * @description test method for createShareRecordsForParentObj
   */
  @isTest
  static void testRecalculationWhenScopeIsParentObject() {
    registerMocks();
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idOwner2 = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    List<Interaction> lstOfSobject = new List<Interaction>{
      new Interaction(
        Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
        OwnerId = idOwner,
        Territory__c = idTerritory,
        RecordTypeId = QueryRT.of(Interaction.SObjectType)
          .getId('ML_Interaction'),
        RecordType = new RecordType(DeveloperName = 'ML_Interaction'),
        Lead__c = leadId,
        Lead__r = new Lead(Id = leadId, OwnerId = idOwner)
      )
    };
    Territory_Based_Sharing_Config__mdt objMtd = new Territory_Based_Sharing_Config__mdt(
      Active__c = true,
      Row_Cause__c = 'Manual',
      Sharing_Scope__c = 'Parent Object',
      Sharing_Object__c = 'InteractionShare',
      Object_Name__c = 'Interaction',
      Lookup_Fields__c = 'Lead__c',
      Eligible_Record_Types__c = 'ML_Interaction',
      IsParentIdField__c = true
    );
    Territory_Based_Sharing_Config__mdt leadObjMtd = new Territory_Based_Sharing_Config__mdt(
      Active__c = true,
      Row_Cause__c = 'Manual',
      Sharing_Scope__c = 'Territory',
      Sharing_Object__c = 'LeadShare',
      Object_Name__c = 'Lead',
      Eligible_Record_Types__c = 'MLCRM_Lead',
      IsParentIdField__c = false,
      Recalculation_Timeframe__c = 24
    );
    territoryMockProvider.mock(
      'getTerritorySharingMetadata',
      new List<Territory_Based_Sharing_Config__mdt>{ objMtd, leadObjMtd }
    );
    userTerritoryMockProvider.mock(
      'getUserTerritories',
      new List<User_Territory__c>{
        new User_Territory__c(
          ML_Role__c = 'Loan Writer',
          User__c = idOwner,
          Territory__c = idTerritory,
          Territory__r = new Territory__c(Access_Scope__c = 'Unrestricted')
        ),
        new User_Territory__c(
          ML_Role__c = 'Loan Writer',
          User__c = idOwner2,
          Territory__c = idTerritory,
          Territory__r = new Territory__c(Access_Scope__c = 'Unrestricted')
        )
      }
    );
    territoryMockProvider.mock(
      'getShareRecords',
      new List<InteractionShare>{
        new InteractionShare(
          UserOrGroupId = idOwner,
          ParentId = lstOfSobject[0].Id
        )
      }
    );
    Test.startTest();
    TerritoryConfigSharingBatch objBatch = new TerritoryConfigSharingBatch(
      objMtd,
      new Set<Id>{ idTerritory }
    );
    objBatch.execute(null, lstOfSobject);
    Test.stopTest();

    List<InteractionShare> createdInteractionShare = (List<InteractionShare>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    List<InteractionShare> deletedInteractionShare = (List<InteractionShare>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      idOwner2,
      createdInteractionShare[0].UserOrGroupId,
      'Interaction is not shared with second user in territory of Parent Object Lead'
    );
    Assert.areEqual(
      idOwner,
      deletedInteractionShare[0].UserOrGroupId,
      'Share Record of previous Owner not deleted'
    );
  }

  //Method to validate list excluded user ids
  @isTest
  static void validateGetExpiredWhereClause() {
    Territory_Based_Sharing_Config__mdt objMtd = getTerritorySharingConfig();
    TerritoryConfigSharingBatch objBatch = new TerritoryConfigSharingBatch();
    String strExpiredWhereClause = objBatch.getExpiredWhereClause(objMtd);
    Assert.areEqual(
      true,
      strExpiredWhereClause.contains('Expired'),
      'getExpiredWhereClause is not returning correct result'
    );
  }

  private static Territory_Based_Sharing_Config__mdt getTerritorySharingConfig() {
    return new Territory_Based_Sharing_Config__mdt(
      Active__c = true,
      Object_Name__c = 'Lead',
      Eligible_Record_Types__c = 'MLCRM_Lead',
      Recalculation_Timeframe__c = 24
    );
  }
}
