/**
 * @author Shermal Warnakula
 * @since Jan 2021
 * @description Helper class providing common methods for APEX unit test classes
 */
@isTest
public with sharing class TestHelper {
  /**
   * @description Adding both Azure and Forge test tokens to Cache
   * @param ocvId Customer OCV ID
   */
  public static void addTokensForApiCallout(String ocvId) {
    addAzureTokenToCache();
    addForgeTokenToCache(ocvId);
  }

  /**
   * @description Adding test Azure token to Cache
   */
  public static void addAzureTokenToCache() {
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      AuthServiceTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
  }

  /**
   * @description Adding test Forge token to Cache
   * @param ocvId Customer OCV ID
   */
  public static void addForgeTokenToCache(String ocvId) {
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );
  }

  /**
   * @description Create Case record with fields relevant to PayTo_Dispute
   * @return Case
   */
  public static Case createPayToDispute() {
    Case theCase = new Case();
    theCase.Description = 'PayTo Dispute Case Description Test_Text_32k';
    theCase.Intended_Account_BSB__c = '012345';
    theCase.Intended_Account_Name__c = 'Intended Account Name Test_Text_255';
    theCase.Intended_Account_Number__c = '0123456789';
    theCase.Intended_Amount__c = 1000.00;
    theCase.Intended_Pay_Id_Type__c = 'ABN';
    theCase.Intended_Pay_Id_Value__c = 'Intended Pay Id Value Test_Text_255';
    theCase.Status = 'Open';
    theCase.Payment_ID__c = 'MPS123123DFS';
    theCase.Submitted__c = false;
    theCase.Dispute_Reason__c = 'Wrong Amount';
    theCase.Transaction_Id__c = 'Transaction Id Test_NPP_Text_255';
    theCase.Transaction_UUID__c = 'Transaction UUID Test_NPP_Text_255';
    return theCase;
  }
}
