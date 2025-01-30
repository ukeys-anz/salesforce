/**
 * @author Ankit Garg
 * @since 20/July/2023
 * @description OpportunityActionsTest is the test class for OpportunityActions Class functionality.
 */
@isTest
public class OpportunityActionsTest {
  static Lib_MockProvider oppActoinRepoMock;
  static Lib_MockProvider dmlRepoMock;
  public static User ocvUser;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    oppActoinRepoMock = Lib_MockProvider.forType(
      OpportunityActionsRepository.class
    );
  }
  private static final String STAGE_CLOSED = 'Closed';
  private static final String STATUS_NEW = 'New';

  /**
   * @description test method for ValidateMLCRMOpportunity
   */
  @isTest
  static void testValidateMLCRMOpportunity() {
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.getSobjectType());
    String exceptionMsg = '';
    Opportunity updatedOpp = MLCRMTestDataFactory.createOpportunityRecords(
      1,
      new User(),
      accId,
      false
    )[0];
    updatedOpp.StageName = STAGE_CLOSED;
    updatedOpp.Id = Lib_FakeIdGenerator.getMockId(Opportunity.getSobjectType());
    Opportunity oldOpportunity = MLCRMTestDataFactory.createOpportunityRecords(
      1,
      new User(),
      accId,
      false
    )[0];
    oldOpportunity.StageName = STATUS_NEW;
    oldOpportunity.Id = updatedOpp.Id;
    oldMap.put(oldOpportunity.Id, oldOpportunity);

    Test.startTest();
    try {
      OpportunityActions.validateMLCRMOpportunity(
        new List<Opportunity>{ updatedOpp },
        oldMap
      );
    } catch (Exception ex) {
      exceptionMsg = ex.getMessage();
    }
    Test.stopTest();
    system.assertEquals(
      '',
      exceptionMsg,
      'validateMLCRMOpportunity is not returning correct output for ML Lead'
    );
  }

  /**
   * @description test method for CreateOppContactRoleForCustomer
   */
  @isTest
  static void testCreateOppContactRoleForCustomer() {
    registerMocks();
    Account acc = new Account();
    acc.id = Lib_FakeIdGenerator.getMockId(Account.getSobjectType());
    oppActoinRepoMock.mock('getAccount', acc);
    String oppId = Lib_FakeIdGenerator.getMockId(Opportunity.getSobjectType());
    String strRole = 'TesRole';
    Test.startTest();
    OpportunityActions.createOppContactRoleForCustomer(acc.Id, oppId, strRole);
    Test.stopTest();
    system.assertEquals(
      false,
      dmlRepoMock.getHistories('doInsert').isEmpty(),
      'CreateOppContactRoleForCustomer is not working properly'
    );
  }

  /**
   * @description test method for GetOpportunity
   */
  @isTest
  static void testGetOpportunity() {
    registerMocks();
    Opportunity opp = new Opportunity();
    opp.Id = Lib_FakeIdGenerator.getMockId(Opportunity.getSobjectType());
    oppActoinRepoMock.mock('getOpportunity', new List<Opportunity>{ opp });
    Test.startTest();
    List<Opportunity> oppList = OpportunityActions.getOpportunity(
      new Set<Id>{ opp.Id }
    );
    Test.stopTest();
    system.assertEquals(
      1,
      oppList.size(),
      'getOpportunity is not working properly'
    );
  }

  /**
   * @description test method for SetRemainingRequestValues
   */
  @isTest
  static void testSetRemainingRequestValues() {
    OCVRequestPayloadWrapper record = new OCVRequestPayloadWrapper();
    record.strCity = 'Melbourne';
    Test.startTest();
    OCVRequestPayloadWrapper result = OpportunityActions.setRemainingRequestValues(
      record
    );
    Test.stopTest();
    system.assertEquals(
      '',
      result.strCity,
      'setRemainingRequestValues is not assigning values correctly'
    );
    system.assertEquals(
      '',
      result.strCountry,
      'setRemainingRequestValues is not assigning values correctly'
    );
  }

  /**
   * @description test method for prepareOpportunityContactRoles
   */
  @isTest
  static void testPrepareOpportunityContactRoles() {
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Map<Id, Account> mapOfAcc = new Map<Id, Account>();
    Opportunity oppRecord = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Opportunity.getSObjectType()),
      RecordTypeId = RTOpportunity.mlOpportunity,
      accountid = accountId
    );
    List<Opportunity> newOppList = new List<Opportunity>{ oppRecord };

    Account objAcc = new Account();
    objAcc.put('OwnerId', idOwner);
    objAcc.put('Disclosure_Indicator__c', null);
    objAcc.put('Id', accountId);
    objAcc.put(
      'RecordTypeId',
      QueryRT.of(Account.SObjectType).getId('PersonAccount')
    );
    mapOfAcc.put(accountId, objAcc);

    OpportunityContactRole objOppRole = new OpportunityContactRole();
    objOppRole.put('Role', 'Guarantor');
    objOppRole.put('OpportunityId', oppRecord.Id);
    mapOfAcc.put(accountId, objAcc);
    Test.startTest();
    List<OpportunityContactRole> lstOfOppRole = OpportunityActions.prepareOpportunityContactRoles(
      newOppList,
      mapOfAcc,
      null
    );
    Test.stopTest();
    System.assertEquals(
      1,
      lstOfOppRole.size(),
      'Failed to create opportunity contact role'
    );
  }

  /**
   * @description test method for UpdateRoleForExistingOCR
   */
  @isTest
  static void testUpdateRoleForExistingOCR() {
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Map<String, OpportunityContactRole> mapOfOppContactRole = new Map<String, OpportunityContactRole>();
    Opportunity oppRecord = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Opportunity.getSObjectType()),
      RecordTypeId = RTOpportunity.mlOpportunity,
      accountid = accountId
    );
    List<Opportunity> newOppList = new List<Opportunity>{ oppRecord };

    Account objAcc = new Account();
    objAcc.put('OwnerId', idOwner);
    objAcc.put('Disclosure_Indicator__c', null);
    objAcc.put('Id', accountId);
    objAcc.put(
      'RecordTypeId',
      QueryRT.of(Account.SObjectType).getId('PersonAccount')
    );

    OpportunityContactRole objOppRole = new OpportunityContactRole();
    objOppRole.put('Role', 'Guarantor');
    objOppRole.put('OpportunityId', oppRecord.Id);
    mapOfOppContactRole.put(
      String.valueOf(oppRecord.Id) + String.valueOf(accountId),
      objOppRole
    );
    Test.startTest();
    List<OpportunityContactRole> lstOfOppRole = OpportunityActions.updateRoleForExistingOCR(
      newOppList,
      mapOfOppContactRole
    );
    Test.stopTest();
    System.assertEquals(
      'Applicant',
      lstOfOppRole[0].Role,
      'Failed to update opportunity contact role'
    );
  }

  /**
   * @description test method for prepareMapOfContactRoleByAccountId
   */
  @isTest
  static void testPrepareMapOfContactRoleByAccountId() {
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id contactId = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    Opportunity oppRecord = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Opportunity.getSObjectType()),
      RecordTypeId = RTOpportunity.mlOpportunity,
      accountid = accountId
    );

    Account objAcc = new Account();
    objAcc.put('OwnerId', idOwner);
    objAcc.put('Disclosure_Indicator__c', null);
    objAcc.put('Id', accountId);
    objAcc.put(
      'RecordTypeId',
      QueryRT.of(Account.SObjectType).getId('PersonAccount')
    );

    Contact contactRecord = new Contact(
      Id = contactId,
      LastName = 'Test',
      Email = 'testemailcontact@mail.com',
      MobilePhone = '99999999',
      AccountId = objAcc.Id
    );

    OpportunityContactRole objOppRole = (OpportunityContactRole) TestUtil.setFields(
      new OpportunityContactRole(
        Role = 'Guarantor',
        OpportunityId = oppRecord.Id
      ),
      new Map<String, Object>{ 'Contact' => contactRecord }
    );
    List<OpportunityContactRole> newOppContactRoleList = new List<OpportunityContactRole>{
      objOppRole
    };
    Test.startTest();
    Map<String, OpportunityContactRole> mapOfOppContactRole = OpportunityActions.prepareMapOfContactRoleByAccountId(
      newOppContactRoleList
    );
    Test.stopTest();
    System.assertEquals(
      'Guarantor',
      mapOfOppContactRole.get(
          String.valueOf(oppRecord.Id) + String.valueOf(objAcc.Id)
        )
        .Role,
      'Failed to form map of opportunity contact role'
    );
  }
}
