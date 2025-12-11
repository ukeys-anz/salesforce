/**
 * @author Arpit Pittie
 * @since 01/02/2024
 * @description To handle all Get Help Financial Account Actions
 */
public class FinancialAccountActions {
  private static final FinancialAccountRepository FINANCIAL_ACCOUNT_REPOSITORY = (FinancialAccountRepository) Lib_InstanceProvider.forType(
    FinancialAccountRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description To update the related Sign Auth Case record
   * @param records FinServ__FinancialAccount__c new updated records
   * @param oldMap FinServ__FinancialAccount__c map of old records
   */
  public static void updateSigningAuthorityCases(
    List<FinServ__FinancialAccount__c> records,
    Map<Id, FinServ__FinancialAccount__c> oldMap
  ) {
    try {
      List<Case> signAuthCasesToUpdate = new List<Case>();
      List<FinServ__FinancialAccount__c> filteredFinancialAccounts = ListUtil.filter(
          records,
          oldmap
        )
        .changed(FinServ__FinancialAccount__c.Number_Of_Signatures__c)
        .isNotNull(FinServ__FinancialAccount__c.Number_Of_Signatures__c)
        .toList();

      Map<Id, Case> signAuthCaseByFinAccount = (Map<Id, Case>) ListUtil.mapBy(
        FINANCIAL_ACCOUNT_REPOSITORY.getOpenSignAuthCasesByFinacialAccount(
          filteredFinancialAccounts
        ),
        Case.FinServ__FinancialAccount__c
      );

      List<FinServ__FinancialAccount__c> filteredFinancialAccountsToUpdate = ListUtil.filter(
          filteredFinancialAccounts
        )
        .equals(
          FinServ__FinancialAccount__c.Id,
          signAuthCaseByFinAccount.keySet()
        )
        .toList();

      for (
        FinServ__FinancialAccount__c finAccount : filteredFinancialAccountsToUpdate
      ) {
        Case caseRecord = signAuthCaseByFinAccount.get(finAccount.Id);
        caseRecord.Status = SigningAuthorityUpdateActions.CASE_STATUS_CLOSED;
        caseRecord.Sub_Status__c = SigningAuthorityUpdateActions.CASE_SUB_STATUS_SUCCESS;
        signAuthCasesToUpdate.add(caseRecord);
      }

      DML_REPOSITORY.doUpdate(signAuthCasesToUpdate);
    } catch (Exception exp) {
      Logger.error('updateSigningAuthorityCases ' + exp.getMessage(), exp);
      Logger.saveLog();
    }
  }

  /**
   * @description Set Financial Account product name field
   * @name populateProduct
   * @param records FinServ__FinancialAccount__c new updated records
   * @param oldMap FinServ__FinancialAccount__c map of old records
   */
  public static void populateProductOnFinancialAccount(
    List<FinServ__FinancialAccount__c> records,
    Map<Id, FinServ__FinancialAccount__c> oldMap
  ) {
    for (FinServ__FinancialAccount__c record : records) {
      String newMarketingCode = record.Marketing_Code__c;

      String oldMarketingCode = oldMap?.get(record.Id).Marketing_Code__c ??
        null;

      if (String.isBlank(newMarketingCode)) {
        continue;
      }
      if (
        oldMarketingCode == null || !newMarketingCode.equals(oldMarketingCode)
      ) {
        if (QueryProducts.productsByProductCode.containsKey(newMarketingCode)) {
          record.FinServ__ProductName__c = QueryProducts.productsByProductCode.get(
              newMarketingCode
            )
            ?.Id;
        }
      }
    }
  }
}
