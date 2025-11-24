/**
 * @author Hrushikesh Pathak
 * @since 09/2025
 * @description SigningAuthorityUpdateController is a class used for the Signing Authority Actions.
 */
public with sharing class SigningAuthorityUpdateController implements IGenericClass, IGenericModify {
  private static final SigningAuthorityUpdateRepository UPDATE_SIGN_AUTH_REPO = (SigningAuthorityUpdateRepository) Lib_InstanceProvider.forType(
    SigningAuthorityUpdateRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final Map<String, String> NUMBER_OF_SIGNATURES_MAP = new Map<String, String>{
    'Change to Any to Sign' => '2',
    'Change to All to Sign' => '1'
  };

  /**
   * @description Method to retrieve financial Accounts
   * @param params String to have multiple parameters
   * @return Object A list of financial accounts
   */
  public Object getData(String params) {
    Map<String, Object> param = (Map<String, Object>) JSON.deserializeUntyped(
      params
    );
    List<FinServ__FinancialAccount__c> finAccounts = UPDATE_SIGN_AUTH_REPO.getFinancialAccountByOcvId(
      (String) param.get('ocvId'),
      (String) NUMBER_OF_SIGNATURES_MAP.get((String) param.get('issueType'))
    );
    return finAccounts;
  }

  /**
   * @description Method to udpate Case records
   * @param params String to have multiple parameters
   */
  public void updateData(String params) {
    try {
      Map<String, Object> param = (Map<String, Object>) JSON.deserializeUntyped(
        params
      );
      String caseId = (String) param.get('caseRecordId');
      String financialAccountId = (String) param.get('financialAccount');

      Case signAuthCase = new Case();
      signAuthCase.Id = caseId;
      signAuthCase.FinServ__FinancialAccount__c = financialAccountId;

      DML_REPOSITORY.doUpdate(signAuthCase);
    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }
}
