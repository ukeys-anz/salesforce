/**
 * @author Hrushikesh Pathak
 * @since 09/2025
 * @description SigningAuthorityUpdateController is a class used for the Signing Authority Actions.
 */
public with sharing class SigningAuthorityUpdateController extends SelectRecordsWizard {
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
   * @param params Map<String, Object> to have multiple parameters
   * @return Map<String, Object> A list of financial accounts
   */
  public override Map<String, Object> getRecords(Map<String, Object> params) {
    List<FinServ__FinancialAccount__c> finAccounts = UPDATE_SIGN_AUTH_REPO.getFinancialAccountByOcvId(
      (String) params.get('ocvId'),
      (String) NUMBER_OF_SIGNATURES_MAP.get((String) params.get('issueType'))
    );
    return new Map<String, Object>{ 'data' => finAccounts };
  }

  public override void updateRecords(Map<String, Object> params) {
    try {
      String caseId = (String) params.get('caseRecordId');
      String financialAccountId = (String) params.get('financialAccount');

      Case signAuthCase = new Case();
      signAuthCase.Id = caseId;
      signAuthCase.FinServ__FinancialAccount__c = financialAccountId;

      DML_REPOSITORY.doUpdate(signAuthCase);
    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }
}
