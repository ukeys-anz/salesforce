/**
 * @author Sanskriti Routray
 * @since 10/2025
 * @description AssistedTransferController is a class used for the Assisted Transfer Actions.
 */
public with sharing class AssistedTransferController implements IGenericClass, IGenericModify {
  private static final AssistedTransferRepository ASSISTED_TRANSFER_REPO = (AssistedTransferRepository) Lib_InstanceProvider.forType(
    AssistedTransferRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Method to retrieve financial Accounts
   * @param params String to have multiple parameters
   * @return Object A list of financial accounts
   */
  public Object getData(String params) {
    Map<String, Object> param = (Map<String, Object>) JSON.deserializeUntyped(
      params
    );
    List<FinServ__FinancialAccount__c> finAccounts = ASSISTED_TRANSFER_REPO.getFinancialAccountByOcvId(
      (String) param.get('ocvId')
    );
    return finAccounts;
  }

  /**
   * @description Method to update Case records
   * @param params String to have multiple parameters
   */
  public void updateData(String params) {
    try {
      Map<String, Object> param = (Map<String, Object>) JSON.deserializeUntyped(
        params
      );
      String caseId = (String) param.get('caseRecordId');
      String financialAccountId = (String) param.get('financialAccount');
      Decimal toAccountAmount = Decimal.valueOf(
        String.valueOf(param.get('toAccountAmount'))
      );
      String toAccount = (String) param.get('toAccount');
      String toAccountNumber = (String) param.get('toAccountNumber');
      String toAccountBsb = (String) param.get('toAccountBsb');
      String transferReason = (String) param.get('transferReason');

      Case assistedTransferCase = new Case();
      assistedTransferCase.Id = caseId;
      assistedTransferCase.FinServ__FinancialAccount__c = financialAccountId;
      assistedTransferCase.Transaction_Amount__c = toAccountAmount;
      assistedTransferCase.Crediting_Amount__c = toAccountAmount;
      assistedTransferCase.Crediting_Account_Name__c = toAccount;
      assistedTransferCase.Crediting_Account_Number__c = toAccountNumber;
      assistedTransferCase.Crediting_Account_BSB__c = toAccountBsb;
      assistedTransferCase.Transfer_Reason__c = transferReason;

      DML_REPOSITORY.doUpdate(assistedTransferCase);
    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }
}
