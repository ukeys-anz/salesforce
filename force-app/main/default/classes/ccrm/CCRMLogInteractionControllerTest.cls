/**
 * @author Naman Garg
 * @since 06/2024
 * @description This is Test class for CCRMLogInteractionController
 */

@isTest
public with sharing class CCRMLogInteractionControllerTest {
  static Lib_MockProvider liRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    liRepoMock = Lib_MockProvider.forType(CCRMLogInteractionRepository.class);
  }

  @isTest
  static void testGetCommentTypeMapping() {
    registerMocks();

    //GIVEN CCRM_Log_Interaction_Comment__mdt List
    List<CCRM_Log_Interaction_Comment__mdt> logIntCommentList = new List<CCRM_Log_Interaction_Comment__mdt>{
      new CCRM_Log_Interaction_Comment__mdt(
        Comment_Type__c = 'Other',
        Default_Text__c = 'Other',
        Active_Flag__c = true,
        Label = 'Comment Type Other',
        DeveloperName = 'Comment_Type_Other'
      )
    };
    liRepoMock.mock('queryCommentType', logIntCommentList);

    //WHEN user fetches the Comment Type mapping
    Test.startTest();
    CCRMLogInteractionController.CCRMInteractionCommentsWrapper commentWrap = CCRMLogInteractionController.getCommentTypeMapping();
    Test.stopTest();

    //THEN user should able to fetch the Comment Type mapping from metadata
    Assert.isNotNull(commentWrap.commentType, 'Unable to fetch Comment type');
  }

  @isTest
  static void testGetCommentTypeException() {
    registerMocks();

    //GIVEN mock exception
    liRepoMock.mockException(
      'queryCommentType',
      new AuraHandledException('Failed to fetch Comment Type records')
    );

    //WHEN calling a method
    try {
      Test.startTest();
      CCRMLogInteractionController.CCRMInteractionCommentsWrapper commentWrap = CCRMLogInteractionController.getCommentTypeMapping();
      Test.stopTest();
    } catch (Exception ex) {
      //THEN error should thrown on UI
      Assert.isTrue(
        ex instanceof AuraHandledException,
        'AuraHandledException should have been thrown for get Comment Type'
      );
    }
  }

  @isTest
  static void testGetSearchResult() {
    registerMocks();

    Id accId = Lib_FakeIdGenerator.getMockId(Account.getSobjectType());

    //GIVEN Primary account, search key and mock FinServ__FinancialAccountRole__c record list
    Account primaryAccRecord = new Account(
      Id = accId,
      Name = 'Primary Account',
      OCV_ID__c = '012313',
      ANZx_Customer__c = false
    );
    String searchKey = '011';
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
    liRepoMock.mock('getFinancialAccountRole', financialAccountRoleList);

    //WHEN calling a getSearchResult method
    Test.startTest();
    List<CCRMLogInteractionController.LookupSearchWrapper> resultList = CCRMLogInteractionController.getSearchResult(
      primaryAccRecord.Id,
      searchKey
    );
    Test.stopTest();

    //THEN user should able to get the FinServ__FinancialAccountRole__c record.
    Assert.areEqual(
      1,
      resultList.size(),
      'Not able to fetch the records for Financial Account Role based on search key.'
    );
  }

  @isTest
  static void testGetSearchResultException() {
    registerMocks();
    String accId = (String) Lib_FakeIdGenerator.getMockId(
      Account.getSobjectType()
    );
    String searchKey = '011';

    //GIVEN Mock exception
    liRepoMock.mock(
      'getFinancialAccountRole',
      new AuraHandledException('Failed to fetch Financial Account records')
    );

    //WHEN calling a method
    try {
      Test.startTest();
      List<CCRMLogInteractionController.LookupSearchWrapper> lookupSearchWrapList = CCRMLogInteractionController.getSearchResult(
        accId,
        searchKey
      );
      Test.stopTest();
    } catch (Exception ex) {
      //THEN error should thrown on UI
      Assert.isTrue(
        ex instanceof AuraHandledException,
        'AuraHandledException should have been thrown for lookup Search'
      );
    }
  }
}
