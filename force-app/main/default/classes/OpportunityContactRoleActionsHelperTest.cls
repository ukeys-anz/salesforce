/**
 * @author MLCRM Developer
 * @since 08/2025
 * @description OpportunityContactRoleActionsHelperTest is the test class for OpportunityContactRoleActionsHelper Class functionality.
 */
@isTest
public class OpportunityContactRoleActionsHelperTest {
  static Lib_MockProvider ocrRepoMock;
  static Lib_MockProvider oppRepoMock;
  static Lib_MockProvider dmlMockProvider;
  static void registerMocks() {
    ocrRepoMock = Lib_MockProvider.forType(
      OpportunityContactRoleActionsRepository.class
    );
    oppRepoMock = Lib_MockProvider.forType(OpportunityActionsRepository.class);
    dmlMockProvider = Lib_MockProvider.forType(DmlRepository.class);
  }

  /**
   * @description test method for insertCustomerRelationships
   */
  @isTest
  static void testInsertCustomerRelationships() {
    registerMocks();
    Id newConId = Lib_FakeIdGenerator.getMockId(
      Schema.Contact.getSObjectType()
    );
    Id newOppId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity.getSObjectType()
    );
    Id newOCRId = Lib_FakeIdGenerator.getMockId(
      Schema.OpportunityContactRole.getSObjectType()
    );
    Id territoryId = Lib_FakeIdGenerator.getMockId(
      Schema.Territory__c.getSObjectType()
    );
    OpportunityContactRole ocrNew = (OpportunityContactRole) TestUtil.setFields(
      new OpportunityContactRole(
        Id = newOCRId,
        OpportunityId = newOppId,
        ContactId = newConId,
        Role = 'Guarantor'
      ),
      new Map<String, Object>{
        'Opportunity' => (Opportunity) TestUtil.setFields(
          new Opportunity(
            AccountId = Lib_FakeIdGenerator.getMockId(
              Schema.Account.getSObjectType()
            ),
            Id = newOppId,
            RecordTypeId = RTOpportunity.mlOpportunity,
            Lead_Converted__c = false
          ),
          new Map<String, Object>{
            'Territory__r' => new Territory__c(
              Id = territoryId,
              Primary_Franchise_Owner__c = UserInfo.getUserId()
            )
          }
        )
      }
    );
    Test.startTest();
    List<Customer_Relationship__c> crrList = OpportunityContactRoleActionsHelper.insertCustomerRelationships(
      new List<OpportunityContactRole>{ ocrNew },
      new Map<String, Customer_Relationship__c>()
    );
    Test.stopTest();
    Assert.areEqual(1, crrList.size(), '1 CRR record should be inserted!');
    Assert.areEqual(
      'Primary',
      crrList[0].Relationship_to_Franchise__c,
      'Relationship to franchise should be Primary'
    );
    Assert.areEqual(
      System.today(),
      crrList[0].Date_Relationship_Commenced__c,
      'Relationship start date should be today'
    );
  }

  /**
   * @description test method for insertCustomerRelationships
   */
  @isTest
  static void testCRwithNullPrimaryFranchise() {
    registerMocks();
    Id newOppId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity.getSObjectType()
    );
    Id newOCRId = Lib_FakeIdGenerator.getMockId(
      Schema.OpportunityContactRole.getSObjectType()
    );
    Id territoryId = Lib_FakeIdGenerator.getMockId(
      Schema.Territory__c.getSObjectType()
    );
    OpportunityContactRole ocrNew = (OpportunityContactRole) TestUtil.setFields(
      new OpportunityContactRole(
        Id = newOCRId,
        OpportunityId = newOppId,
        Role = 'Guarantor'
      ),
      new Map<String, Object>{
        'Opportunity' => (Opportunity) TestUtil.setFields(
          new Opportunity(
            AccountId = Lib_FakeIdGenerator.getMockId(
              Schema.Account.getSObjectType()
            ),
            Id = newOppId,
            RecordTypeId = RTOpportunity.mlOpportunity,
            Lead_Converted__c = false
          ),
          new Map<String, Object>{
            'Territory__r' => new Territory__c(
              Id = territoryId,
              Primary_Franchise_Owner__c = null
            )
          }
        )
      }
    );
    Test.startTest();
    List<Customer_Relationship__c> crrList = OpportunityContactRoleActionsHelper.insertCustomerRelationships(
      new List<OpportunityContactRole>{ ocrNew },
      new Map<String, Customer_Relationship__c>()
    );
    Test.stopTest();
    Assert.isTrue(crrList.isEmpty(), 'No CRR record should be inserted!');
  }

  @isTest
  static void testCreateCRRInstance() {
    registerMocks();
    Id newConId = Lib_FakeIdGenerator.getMockId(
      Schema.Contact.getSObjectType()
    );
    Id accountId = Lib_FakeIdGenerator.getMockId(
      Schema.Account.getSObjectType()
    );
    Id newOppId = Lib_FakeIdGenerator.getMockId(
      Schema.Opportunity.getSObjectType()
    );
    Id newOCRId = Lib_FakeIdGenerator.getMockId(
      Schema.OpportunityContactRole.getSObjectType()
    );
    Id territoryId = Lib_FakeIdGenerator.getMockId(
      Schema.Territory__c.getSObjectType()
    );
    OpportunityContactRole ocrNew = (OpportunityContactRole) TestUtil.setFields(
      new OpportunityContactRole(
        Id = newOCRId,
        OpportunityId = newOppId,
        ContactId = newConId,
        Role = 'Guarantor'
      ),
      new Map<String, Object>{
        'Opportunity' => (Opportunity) TestUtil.setFields(
          new Opportunity(
            AccountId = Lib_FakeIdGenerator.getMockId(
              Schema.Account.getSObjectType()
            ),
            Id = newOppId,
            RecordTypeId = RTOpportunity.mlOpportunity,
            Lead_Converted__c = false,
            Territory__c = territoryId
          ),
          new Map<String, Object>{
            'Territory__r' => new Territory__c(
              Id = territoryId,
              Primary_Franchise_Owner__c = UserInfo.getUserId()
            )
          }
        ),
        'Contact' => new Contact(Id = newConId, AccountId = accountId)
      }
    );
    Test.startTest();
    Customer_Relationship__c crr = OpportunityContactRoleActionsHelper.createCRRInstance(
      ocrNew
    );
    Test.stopTest();
    Assert.areEqual(
      crr.Territory__c,
      territoryId,
      'territory should match with opportunity territory'
    );
    Assert.areEqual(
      crr.Customer__c,
      accountId,
      'accountId should match with ocr accountId'
    );
  }

  /*test method to test getCustomerIds */
  @isTest
  static void testGetCustomerIds() {
    registerMocks();
    Id newConId = Lib_FakeIdGenerator.getMockId(
      Schema.Contact.getSObjectType()
    );
    Id accountId = Lib_FakeIdGenerator.getMockId(
      Schema.Account.getSObjectType()
    );
    OpportunityContactRole ocrNew = (OpportunityContactRole) TestUtil.setFields(
      new OpportunityContactRole(ContactId = newConId, Role = 'Guarantor'),
      new Map<String, Object>{
        'Contact' => new Contact(Id = newConId, AccountId = accountId)
      }
    );
    Test.startTest();
    Set<Id> customerIds = OpportunityContactRoleActionsHelper.getCustomerIds(
      new List<OpportunityContactRole>{ ocrNew }
    );
    Test.stopTest();
    Assert.isTrue(!customerIds.isEmpty(), 'No Contact Customer Record found!');
    Assert.isTrue(
      customerIds.contains(accountId),
      'account Id should be present in customerIds'
    );
  }
}
