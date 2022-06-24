/**
 * @author Peter Charalambous
 * @since 2020
 * @description Forge Token Handler.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class ForgeTokenHandler {
  /**
   * @description Retrieve the Forge JWT token from cache or make request for new token
   * @param ocvId ocvID
   * @return Map<String, Object>
   * @exception CalloutException
   */
  public static IdentityModel getForgeJWTToken(String ocvId) {
    String idToken = '';
    try {
      idToken = AuthTokenCacheUtil.getSessionIdToken();
    } catch (Exception e) {
      lib_systemLog log = new lib_systemLog(
        'ForgeTokenHandler',
        'getForgeJWTToken'
      );
      log.addMessage(
        e.getTypeName(),
        e.getMessage(),
        Lib_SystemLog.Severity.ERROR
      );
      log.insertLogAsync();

      AuraHandledException ahe = new AuraHandledException(e.getMessage());
      ahe.setMessage(e.getMessage());
      throw ahe;
    }

    Forgerock_Auth__mdt forgeAuth;
    if (Forgerock_Auth__mdt.sObjectType.getDescribe().isQueryable()) {
      forgeAuth = [
        SELECT
          Id,
          Encrypted_Forge_Client_Id__c,
          Encrypted_Forge_Client_Secret__c
        FROM Forgerock_Auth__mdt
        WHERE DeveloperName = 'Forgerock'
        LIMIT 1
      ];
    }
    AuthRepository authRepo = new AuthRepository();
    IdentityModel responseModel = authRepo.getForgeStaffToken(
      ocvId,
      idToken,
      forgeAuth
    );

    return responseModel;
  }
}
