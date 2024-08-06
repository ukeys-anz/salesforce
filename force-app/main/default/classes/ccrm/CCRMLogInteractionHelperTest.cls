/**
 * @author Naman Garg
 * @since 06/2024
 * @description This is Test class for CCRMLogInteractionHelper class
 */
@isTest
public class CCRMLogInteractionHelperTest {
  static Lib_MockProvider liRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    liRepoMock = Lib_MockProvider.forType(CCRMLogInteractionRepository.class);
  }

  @isTest
  static void testFormCommentTypeMap() {
    //GIVEN CCRM_Log_Interaction_Comment__mdt List
    List<CCRM_Log_Interaction_Comment__mdt> logIntCommentList = new List<CCRM_Log_Interaction_Comment__mdt>{
      new CCRM_Log_Interaction_Comment__mdt(
        Comment_Type__c = 'Other',
        Default_Text__c = 'Other',
        Active_Flag__c = true,
        Label = 'Comment Type Other',
        DeveloperName = 'Comment_Type_Other'
      ),
      new CCRM_Log_Interaction_Comment__mdt(
        Comment_Type__c = 'No ATM cards',
        Default_Text__c = 'Customer has requested no cards to be ordered on the account',
        Active_Flag__c = false,
        Label = 'No ATM cards',
        DeveloperName = 'No_ATM_cards'
      )
    };

    //WHEN user fetches the Comment Type mapping
    Test.startTest();
    Map<String, String> commentTypeMap = CCRMLogInteractionHelper.formCommentTypeMap(
      logIntCommentList
    );
    Test.stopTest();

    //THEN user should able to fetch the Comment Type mapping from metadata
    Assert.areEqual(
      1,
      commentTypeMap.size(),
      'Not able to form Comment Type Map'
    );
  }

  @isTest
  static void testPopulateLookupSearchWrapper() {
    Id accId = Lib_FakeIdGenerator.getMockId(Account.getSobjectType());

    //GIVEN Primary account, search key and mock FinServ__FinancialAccountRole__c record list
    Account primaryAccRecord = new Account(
      Id = accId,
      Name = 'Primary Account',
      OCV_ID__c = '012313',
      ANZx_Customer__c = false
    );
    List<FinServ__FinancialAccountRole__c> financialAccountRoleList = new List<FinServ__FinancialAccountRole__c>{
      new FinServ__FinancialAccountRole__c(
        Id = Lib_FakeIdGenerator.getMockId(
          FinServ__FinancialAccountRole__c.getSobjectType()
        ),
        FinServ__RelatedAccount__c = accId,
        FinServ__Active__c = true,
        FinServ__FinancialAccount__c = Lib_FakeIdGenerator.getMockId(
          FinServ__FinancialAccount__c.getSobjectType()
        ),
        Role_Type__c = 'BCC'
      )
    };

    //WHEN calling a populateLookupSearchWrapper method
    Test.startTest();
    List<CCRMLogInteractionController.LookupSearchWrapper> lookupSearchWrapList = CCRMLogInteractionHelper.populateLookupSearchWrapper(
      financialAccountRoleList,
      CCRMConstants.FINANCIAL_ACCOUNT_OBJECT_NAME
    );
    Test.stopTest();

    //THEN able to populate Lookup Search Wrapper
    Assert.areEqual(
      1,
      lookupSearchWrapList.size(),
      'Not able to populate Lookup Search Wrapper.'
    );
  }
}
