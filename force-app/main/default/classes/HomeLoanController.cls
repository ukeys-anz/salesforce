/**
 *
 * @author Vidhya Raghavan
 * @since 2022
 * @description HomeLoanController retrieves account details for the PersonAccount and H1 account details LWC
 */

public with sharing class HomeLoanController {
  private static final FinancialAccountRepository FAR_REPOSITORY = (FinancialAccountRepository) Lib_InstanceProvider.forType(
    FinancialAccountRepository.class
  );

  /**
   * @description The Person Account Home Loan component uses this to fetch the records to display.
   * This makes the callout to mule to fetch home loan data
   * @param ocvId Ocv id
   * @param accountNumbers param to filter by account numbers
   * @return
   */
  @AuraEnabled
  public static HomeLoanModel getHomeLoanAccount(
    String ocvId,
    List<String> accountNumbers
  ) {
    try {
      HomeLoanAPIRepository hloanapi = (HomeLoanAPIRepository) Lib_InstanceProvider.forType(
        HomeLoanAPIRepository.class
      );
      return hloanapi.getHomeLoanAccounts(ocvId, accountNumbers);
    } catch (Exception exp) {
      throw new AuraHandledException(exp.getMessage());
    }
  }

  /**
   * @description return the id(s) of the financial account owners
   * @param financialAccountId financial account record id
   * @return  `Id` home loan account id
   */
  @AuraEnabled
  public static List<FinServ__FinancialAccountRole__c> getAccountOwnerIds(
    Id financialAccountId
  ) {
    try {
      return FAR_REPOSITORY.getAccountOwnerDetails(financialAccountId);
    } catch (Exception exp) {
      throw new AuraHandledException(exp.getMessage());
    }
  }

  /**
   * @description To get the offset linked with account
   * This makes the callout to mule to fetch the offset account data using lex api
   * @param ocvId ocv id
   * @param loanAccNumber param to get the offset linked with financial account
   * @param recordId record ID
   * @return OffsetAccountModel
   */
  @AuraEnabled
  public static OffsetAccountModel getListOffset(
    String ocvId,
    String loanAccNumber,
    String recordId
  ) {
    try {
      HomeLoanAPIRepository offsetapi = (HomeLoanAPIRepository) Lib_InstanceProvider.forType(
        HomeLoanAPIRepository.class
      );
      OffsetAccountModel result = offsetapi.getOffsetAccounts(
        ocvId,
        loanAccNumber,
        recordId
      );
      if (result?.loanOffsets?.isEmpty() ?? true) {
        return null;
      }

      List<String> finAccNumbers = OffsetAccountHelper.getFinAccNumberList(
        result.loanOffsets
      );
      List<FinServ__FinancialAccount__c> finAccList = FAR_REPOSITORY.getFinAccountList(
        finAccNumbers
      );

      Map<String, FinServ__FinancialAccount__c> accNumberToFinAccountMap = (Map<String, FinServ__FinancialAccount__c>) ListUtil.mapBy(
        finAccList,
        FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c
      );

      result.loanOffsets = OffsetAccountHelper.transformDataForUI(
        result.loanOffsets,
        accNumberToFinAccountMap
      );
      return result;
    } catch (Exception ex) {
      OffsetAccountModel offsetError = new OffsetAccountModel();
      offsetError.hasError = true;
      Logger.error(ex.getMessage(), ex);
      Logger.saveLog();
      return offsetError;
    }
  }

  /**
   * @description return list of linked home loan financial accounts
   * @param customerId customer id
   * @return  `List<FinServ__FinancialAccountRole__c>` list of linked financial accounts
   */
  @AuraEnabled
  public static List<FinServ__FinancialAccountRole__c> getLinkedHomeLoanFinancialAccountRole(
    Id customerId
  ) {
    try {
      return FAR_REPOSITORY.getHomeLoanAccountByCustomerId(customerId);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
