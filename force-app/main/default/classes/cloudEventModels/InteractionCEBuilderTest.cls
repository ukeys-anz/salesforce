/**
 * @author       : Advait Yermalkar
 * @since        : 07-10-2024
 * @description  : Test Class for InteractionCEBuilder
 **/
@isTest
private class InteractionCEBuilderTest {
  @isTest
  static void createCoudEventsOnCreateTest() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    ccrmUser.Lan_Id__c = 'TestLanId';

    Id interactionId = Lib_FakeIdGenerator.getMockId(Interaction.SobjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SobjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SobjectType);
    Id finAccountId = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.SobjectType
    );

    Account mockCustomer = new Account(
      Id = accId,
      Name = 'Test Customer',
      Source_System_ID__c = '111111000000',
      Source_System_Name__c = 'CAP-CIS1',
      OCV_ID__c = '2200993355'
    );

    Opportunity mockOpp = (Opportunity) TestUtil.setFields(
      new Opportunity(Id = oppId),
      new Map<String, Object>{ 'Opp_Id__c' => '12345678' }
    );

    FinServ__FinancialAccount__c mockFinAccount = (FinServ__FinancialAccount__c) TestUtil.setFields(
      new FinServ__FinancialAccount__c(
        Id = finAccountId,
        Name = 'DDA-234500817',
        FinServ__FinancialAccountNumber__c = '234500817'
      ),
      new Map<String, Object>{ 'Product_Code_Display__c' => 'DDA' }
    );

    List<Interaction> intListGen = CCRMTestDataFactory.createInteractionDataWithOpportunity(
      1,
      ccrmUser,
      oppId
    );
    intListGen[0] = (Interaction) TestUtil.setFields(
      intListGen[0],
      new Map<String, Object>{
        'Id' => interactionId,
        'Interaction_Auto_Number__c' => 'AIR-00421373',
        'LastModifiedById' => ccrmUser.Id,
        'LastModifiedDate' => '2024-06-28T08:00:27.000+0000',
        'AccountId' => accId
      }
    );

    List<Interaction> intListCap = CCRMTestDataFactory.createCapInteractionData(
      1,
      ccrmUser,
      accId,
      finAccountId
    );
    intListCap[0] = (Interaction) TestUtil.setFields(
      intListCap[0],
      new Map<String, Object>{
        'Id' => interactionId,
        'Interaction_Auto_Number__c' => 'AIR-00421373',
        'LastModifiedById' => ccrmUser.Id,
        'LastModifiedDate' => '2024-06-28T08:00:27.000+0000'
      }
    );

    List<Interaction> intListAll = new List<Interaction>(
      new List<Interaction>{ intListGen[0], intListCap[0] }
    );

    Map<Id, Account> theAccountMap = new Map<Id, Account>{
      mockCustomer.Id => mockCustomer
    };

    Map<Id, User> theUserMap = new Map<Id, User>{ ccrmUser.Id => ccrmUser };

    Map<Id, Opportunity> theOpportunityMap = new Map<Id, Opportunity>{
      mockOpp.Id => mockOpp
    };

    Map<Id, FinServ__FinancialAccount__c> theFinAccountMap = new Map<Id, FinServ__FinancialAccount__c>{
      mockFinAccount.Id => mockFinAccount
    };

    InteractionCEBuilder.InteractionCEWrapper intWrapper = new InteractionCEBuilder.InteractionCEWrapper();
    intWrapper.theAccountMap = theAccountMap;
    intWrapper.theOpportunityMap = theOpportunityMap;
    intWrapper.theUserMap = theUserMap;
    intWrapper.theFinAccountMap = theFinAccountMap;

    Test.startTest();
    List<CloudEventModel> ceModels = InteractionCEBuilder.createCloudEvents(
      intListAll,
      intWrapper,
      CCRMConstants.ACTION_CODE_CREATE
    );
    Test.stopTest();
    Assert.isNotNull(ceModels, 'CeModels should be created successfully');
    Assert.areEqual(
      2,
      ceModels.size(),
      'CeModels should be created successfully'
    );
    Assert.areEqual(
      'com.anzx.salesforce.interaction.v1alpha1.iteraction.ccrm_interaction.create',
      ceModels[0].ce_type,
      'CeModels were not created successfully on create'
    );
    Assert.areEqual(
      'com.anzx.salesforce.interaction.v1alpha1.interaction.cap_diarycomment.create',
      ceModels[1].ce_type,
      'CeModels were not created successfully on create'
    );
  }

  @isTest
  static void createCoudEventsOnUpdateTest() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    ccrmUser.Lan_Id__c = 'TestLanId';

    Id interactionId = Lib_FakeIdGenerator.getMockId(Interaction.SobjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SobjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SobjectType);
    Id finAccountId = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.SobjectType
    );

    Account mockCustomer = new Account(
      Id = accId,
      Name = 'Test Customer',
      Source_System_ID__c = '111111000000',
      Source_System_Name__c = 'CAP-CIS1',
      OCV_ID__c = '2200993355'
    );

    Opportunity mockOpp = (Opportunity) TestUtil.setFields(
      new Opportunity(Id = oppId),
      new Map<String, Object>{ 'Opp_Id__c' => '12345678' }
    );

    FinServ__FinancialAccount__c mockFinAccount = (FinServ__FinancialAccount__c) TestUtil.setFields(
      new FinServ__FinancialAccount__c(
        Id = finAccountId,
        Name = 'DDA-234500817',
        FinServ__FinancialAccountNumber__c = '234500817'
      ),
      new Map<String, Object>{ 'Product_Code_Display__c' => 'DDA' }
    );

    List<Interaction> intListGen = CCRMTestDataFactory.createInteractionDataWithOpportunity(
      1,
      ccrmUser,
      oppId
    );
    intListGen[0] = (Interaction) TestUtil.setFields(
      intListGen[0],
      new Map<String, Object>{
        'Id' => interactionId,
        'Interaction_Auto_Number__c' => 'AIR-00421373',
        'LastModifiedById' => ccrmUser.Id,
        'LastModifiedDate' => '2024-06-28T08:00:27.000+0000',
        'AccountId' => accId
      }
    );

    List<Interaction> intListCap = CCRMTestDataFactory.createCapInteractionData(
      1,
      ccrmUser,
      accId,
      finAccountId
    );
    intListCap[0] = (Interaction) TestUtil.setFields(
      intListCap[0],
      new Map<String, Object>{
        'Id' => interactionId,
        'Interaction_Auto_Number__c' => 'AIR-00421373',
        'LastModifiedById' => ccrmUser.Id,
        'LastModifiedDate' => '2024-06-28T08:00:27.000+0000'
      }
    );

    List<Interaction> intListAll = new List<Interaction>(
      new List<Interaction>{ intListGen[0], intListCap[0] }
    );

    Map<Id, Account> theAccountMap = new Map<Id, Account>{
      mockCustomer.Id => mockCustomer
    };

    Map<Id, User> theUserMap = new Map<Id, User>{ ccrmUser.Id => ccrmUser };

    Map<Id, Opportunity> theOpportunityMap = new Map<Id, Opportunity>{
      mockOpp.Id => mockOpp
    };

    Map<Id, FinServ__FinancialAccount__c> theFinAccountMap = new Map<Id, FinServ__FinancialAccount__c>{
      mockFinAccount.Id => mockFinAccount
    };

    InteractionCEBuilder.InteractionCEWrapper intWrapper = new InteractionCEBuilder.InteractionCEWrapper();
    intWrapper.theAccountMap = theAccountMap;
    intWrapper.theOpportunityMap = theOpportunityMap;
    intWrapper.theUserMap = theUserMap;
    intWrapper.theFinAccountMap = theFinAccountMap;

    Test.startTest();
    List<CloudEventModel> ceModels = InteractionCEBuilder.createCloudEvents(
      intListAll,
      intWrapper,
      CCRMConstants.ACTION_CODE_UPDATE
    );
    Test.stopTest();

    Assert.isNotNull(ceModels, 'CeModels should be created successfully');
    Assert.areEqual(
      1,
      ceModels.size(),
      'CeModels should be created successfully'
    );
    Assert.areEqual(
      'com.anzx.salesforce.interaction.v1alpha1.iteraction.ccrm_interaction.update',
      ceModels[0].ce_type,
      'CeModels Not created successfully on Update'
    );
  }

  @isTest
  static void getRelatedIdsTest() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    Id interactionId = Lib_FakeIdGenerator.getMockId(Interaction.SobjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SobjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SobjectType);

    Account mockCustomer = new Account(
      Id = accId,
      Name = 'Test Customer',
      Source_System_ID__c = '111111000000',
      Source_System_Name__c = 'CAP-CIS1',
      OCV_ID__c = '2200993355'
    );
    Opportunity mockOpp = (Opportunity) TestUtil.setFields(
      new Opportunity(Id = oppId),
      new Map<String, Object>{ 'Opp_Id__c' => '12345678' }
    );

    List<Interaction> intList = CCRMTestDataFactory.createInteractionDataWithOpportunity(
      1,
      ccrmUser,
      oppId
    );

    intList[0] = (Interaction) TestUtil.setFields(
      intList[0],
      new Map<String, Object>{
        'Id' => interactionId,
        'Interaction_Auto_Number__c' => 'AIR-00421373',
        'LastModifiedById' => ccrmUser.Id,
        'LastModifiedDate' => '2024-06-28T08:00:27.000+0000',
        'AccountId' => accId
      }
    );
    Map<Id, Interaction> mapOfInteraction = new Map<Id, Interaction>{
      intList[0].Id => intList[0]
    };

    Test.startTest();
    Map<String, Set<Id>> relatedIdsMap = InteractionCEBuilder.getRelatedIds(
      intList
    );
    Test.stopTest();

    Assert.areEqual(
      new Set<Id>{ accId },
      relatedIdsMap.get('Account'),
      'Related Ids Not Populated correctly - Account'
    );
    Assert.areEqual(
      new Set<Id>(),
      relatedIdsMap.get('FinServ__FinancialAccount__c'),
      'Related Ids Not Populated correctly - FinServ__FinancialAccount__c'
    );
    Assert.areEqual(
      new Set<Id>{ oppId },
      relatedIdsMap.get('Opportunity'),
      'Related Ids Not Populated correctly - Opportunity'
    );
    Assert.areEqual(
      new Set<Id>{ ccrmUser.id },
      relatedIdsMap.get('User'),
      'Related Ids Not Populated correctly - User'
    );
  }
}
