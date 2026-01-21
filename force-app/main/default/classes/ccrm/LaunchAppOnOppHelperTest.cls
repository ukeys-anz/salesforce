/**
 * @author Ayushi Gupta
 * @since  09/2024
 * @description Test class of LaunchAppOnOppHelper
 */
@isTest
private class LaunchAppOnOppHelperTest {
  static Lib_MockProvider launchAppRepoMock;

  static void registerMocks() {
    launchAppRepoMock = Lib_MockProvider.forType(
      LaunchAppOnOppControllerRepository.class
    );
  }

  @isTest
  static void createOppLineItemWrapperTest() {
    //Mock data creation
    OpportunityLineItem oli = new OpportunityLineItem(
      Id = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType),
      Product2Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType),
      UnitPrice = 20,
      Funding_purpose__c = 'Property Purchase or Construction',
      Product2 = new Product2(Name = 'Test')
    );
    Test.startTest();
    List<LaunchAppOnOppController.OppLineItemWrapper> items = LaunchAppOnOppHelper.createOppLineItemWrapper(
      new List<OpportunityLineItem>{ oli },
      new Set<Id>()
    );
    Test.stopTest();
    Assert.isFalse(items.size() == 0, 'No items found');
    Assert.areEqual(
      'Property Purchase or Construction',
      items[0].fundingPurpose,
      'Funding purpose is not set correctly'
    );
    Assert.areEqual(
      'Test',
      items[0].productName,
      'Product Name is not set correctly'
    );
  }

  @isTest
  static void getSelectedOppLineItemIdsTest() {
    //Mock data creation
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    ApplicationFormProduct afp = new ApplicationFormProduct(
      Id = Lib_FakeIdGenerator.getMockId(ApplicationFormProduct.SObjectType),
      Source_System_Id__c = oppId + '' + oliId
    );
    Test.startTest();
    Set<Id> selectedOppLineItemsIds = LaunchAppOnOppHelper.getSelectedOppLineItemIds(
      new List<ApplicationFormProduct>{ afp }
    );
    Test.stopTest();
    Assert.isFalse(selectedOppLineItemsIds.size() == 0, 'No items found');
    Assert.areEqual(
      new Set<Id>{ oliId },
      selectedOppLineItemsIds,
      'Values are not equal'
    );
  }

  @isTest
  static void testCreateAMBITRequestBody() {
    registermocks();

    //GIVEN opportunity and opportunity Line Item record
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    Account accRec = (Account) TestUtil.setFields(
      new Account(
        Name = 'Sample Account',
        Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        Source_System_ID__c = '12345'
      ),
      new Map<String, Object>()
    );
    User ownerRec = (User) TestUtil.setFields(
      new User(
        FirstName = 'Sample',
        LastName = 'User',
        Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Lan_Id__c = 'userlanId1'
      ),
      new Map<String, Object>()
    );
    Contact brokerRec = (Contact) TestUtil.setFields(
      new Contact(
        FirstName = 'Sample',
        LastName = 'Contact',
        Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType),
        Broker_Accreditation_Type__c = 'Asset Finance',
        Asset_Finance_Accreditation_Status__c = 'Active',
        AssetFinanceTPMISAO__c = 'CA-123456'
      ),
      new Map<String, Object>()
    );
    User userRec = (User) TestUtil.setFields(
      new User(
        Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Lan_Id__c = 'userlanId2'
      ),
      new Map<String, Object>()
    );
    Opportunity oppRec = (Opportunity) TestUtil.setFields(
      new Opportunity(
        Id = oppId,
        Name = 'Sample Opportunity',
        StageName = 'Opportunity Identified',
        Account = accRec,
        Owner = ownerRec,
        Broker_Name__r = brokerRec,
        Description = 'Sample Opp'
      ),
      new Map<String, Object>{ 'Opp_Id__c' => '0-0023456' }
    );
    Opportunity oppRecWithTeamMembers = (Opportunity) TestUtil.setFields(
      oppRec,
      new Map<String, List<OpportunityTeamMember>>{
        'OpportunityTeamMembers' => new List<OpportunityTeamMember>{
          new OpportunityTeamMember(
            Id = Lib_FakeIdGenerator.getMockId(
              OpportunityTeamMember.SObjectType
            ),
            TeamMemberRole = 'Asset Finance',
            User = userRec
          )
        }
      }
    );
    List<OpportunityLineItem> oliList = new List<OpportunityLineItem>{
      new OpportunityLineItem(
        Id = oliId,
        OpportunityId = oppId,
        Product2Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType),
        UnitPrice = 20,
        Funding_purpose__c = 'Property Purchase or Construction',
        Product2 = new Product2(Name = 'Test')
      )
    };
    List<Id> oliIdsList = new List<Id>{ oliId };
    launchAppRepoMock.mock('getOpportunityData', oppRecWithTeamMembers);

    //WHEN calling a createAMBITRequestBody
    Test.startTest();
    CommercialAMBITRequestModel ambitModel = LaunchAppOnOppHelper.createAMBITRequestBody(
      oppId,
      oliIdsList[0]
    );
    Test.stopTest();

    //THEN it should successfully assert
    Assert.areEqual(
      'CRM-SF',
      ambitModel.DCOpportunityPackage.Opportunity.Source.XTLookupValue,
      'Source value should be matched'
    );
    Assert.areEqual(
      userRec.Lan_Id__c,
      ambitModel.DCOpportunityPackage.Opportunity.SecondarySalesLeadId.Username,
      'Secondary Sales Lead Id value should be matched'
    );
    Assert.areEqual(
      ownerRec.Lan_Id__c,
      ambitModel.DCOpportunityPackage.Opportunity.SalesLeadId.Username,
      'Sales Lead Id value should be matched'
    );

    Assert.areEqual(
      'ProductRowId',
      ambitModel.DCOpportunityPackage.Opportunity.OpportunityId.ExtSysObjType,
      'Ext Sys Obj Type value should be matched'
    );
    Assert.areEqual(
      oppRecWithTeamMembers.Opp_Id__c,
      ambitModel.DCOpportunityPackage.Opportunity.OpportunityId.ExtSysObjRef,
      'Ext Sys Obj Ref value should be matched'
    );
    Assert.areEqual(
      'CRM-SF',
      ambitModel.DCOpportunityPackage.Opportunity.OpportunityId.ExtSysName,
      'ExtSysName value should be matched'
    );

    Assert.areEqual(
      'CAP',
      ambitModel.DCOpportunityPackage.PartyInformation.CustomFields.DCCustomField.FieldValue,
      'Field Value value should be matched'
    );
    Assert.areEqual(
      'Customer Master',
      ambitModel.DCOpportunityPackage.PartyInformation.CustomFields.DCCustomField.FieldName,
      'Field Name value should be matched'
    );
  }

  @isTest
  static void createProductAmountMapTest() {
    //GIVEN items
    List<OpportunityLineItem> items = new List<OpportunityLineItem>{
      new OpportunityLineItem(
        Id = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType),
        Product2Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType),
        UnitPrice = 10
      )
    };

    //WHEN calling a method
    Test.startTest();
    Map<Id, Decimal> productIdToAmountMap = LaunchAppOnOppHelper.createProductAmountMap(
      items
    );
    Test.stopTest();

    //THEN it shoould successfully create a map
    Assert.areEqual(
      1,
      productIdToAmountMap.size(),
      'should able to form a map'
    );
  }
}
