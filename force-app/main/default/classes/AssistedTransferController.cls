/**
 * @author Sanskriti Routray
 * @since 10/2025
 * @description AssistedTransferController is a class used for the Assisted Transfer Actions.
 */
public with sharing class AssistedTransferController extends SelectRecordsWizard {
  private static final AssistedTransferRepository ASSISTED_TRANSFER_REPO = (AssistedTransferRepository) Lib_InstanceProvider.forType(
    AssistedTransferRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Method to retrieve financial Accounts
   * @param params Map<String, Object> to have multiple parameters
   * @return Map<String, Object> A list of financial accounts
   */
  public override Map<String, Object> getRecords(Map<String, Object> params) {
    List<FinServ__FinancialAccount__c> finAccounts = ASSISTED_TRANSFER_REPO.getFinancialAccountByOcvId(
      (String) params.get('ocvId')
    );
    return new Map<String, Object>{ 'data' => finAccounts };
  }

  public override void updateRecords(Map<String, Object> params) {
    try {
      String caseId = (String) params.get('caseRecordId');
      String financialAccountId = (String) params.get('financialAccount');
      Decimal toAccountAmount = Decimal.valueOf(
        String.valueOf(params.get('toAccountAmount'))
      );
      String toAccount = (String) params.get('toAccount');
      String toAccountNumber = (String) params.get('toAccountNumber');
      String toAccountBsb = (String) params.get('toAccountBsb');
      String transferReason = (String) params.get('transferReason');

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
