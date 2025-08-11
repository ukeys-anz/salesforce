/**
 * @description       : class contains method that is used in IP/OS to invoke Assisted User functionality
 * @author            : Hinduja Upadhyay
 * @group             : TFM
 * @last modified on  : 06-17-2025
 **/
global with sharing class AUFController {
  private static final IDOpsQueryRepository QUERY = (IDOpsQueryRepository) Lib_InstanceProvider.forType(
    IDOpsQueryRepository.class
  );
  private static final AUFAPIRepository AUFREPO = (AUFAPIRepository) Lib_InstanceProvider.forType(
    AUFAPIRepository.class
  );

  /**
   * @description update pin for AUF
   * @param recordId recordId
   * @param action action
   */
  @AuraEnabled
  public static void updatePinStatus(Id recordId, String action) {
    try {
      PersonDigitalIdentity__x personDigitalRec = QUERY.getPersonDigitalIdentityRec(
        recordId
      );
      AUFREPO.updatePinStatus(
        personDigitalRec.UUID__c,
        personDigitalRec.pinRefId__c,
        action
      );
    } catch (Exception e) {
      handleCommonException(e);
    }
  }

  /**
   * @description update status for AUF
   * @param recordId recordId
   * @param action action
   */
  @AuraEnabled
  public static void updateStatus(Id recordId, String action) {
    try {
      PersonDigitalIdentity__x personDigitalRec = QUERY.getPersonDigitalIdentityRec(
        recordId
      );
      AUFREPO.updateStatus(personDigitalRec.UUID__c, action);
    } catch (Exception e) {
      handleCommonException(e);
    }
  }

  /**
   * @description reset pin for AUF
   * @param recordId recordId
   * @param pin pin
   */
  @AuraEnabled
  public static void resetPin(Id recordId, String pin) {
    try {
      PersonDigitalIdentity__x personDigitalRec = QUERY.getPersonDigitalIdentityRec(
        recordId
      );
      AUFREPO.resetPin(personDigitalRec.UUID__c, pin);
    } catch (AUFAPIRepository.ResetPinBadException e) {
      throw new AuraHandledException('Pin history check failed.');
    } catch (Exception e) {
      handleCommonException(e);
    }
  }

  /**
   * @description update mobile number for AUF
   * @param recordId recordId
   * @param mobileNumber mobileNumber
   */
  @AuraEnabled
  public static void updateMobileNumber(Id recordId, String mobileNumber) {
    try {
      PersonDigitalIdentity__x personDigitalRec = QUERY.getPersonDigitalIdentityRec(
        recordId
      );
      AUFREPO.updateMobileNumber(personDigitalRec.UUID__c, mobileNumber);
    } catch (AUFAPIRepository.DuplicateMobileNumberException e) {
      throw new AuraHandledException(
        'The number you are trying to update to is already associated to another customer.'
      );
    } catch (Exception e) {
      handleCommonException(e);
    }
  }

  /**
   * @description update ocvId for AUF
   * @param recordId recordId
   * @param ocvId ocvId
   */
  @AuraEnabled
  public static void updateOcvid(Id recordId, String ocvId) {
    try {
      PersonDigitalIdentity__x personDigitalRec = QUERY.getPersonDigitalIdentityRec(
        recordId
      );
      AUFREPO.updateOcvid(personDigitalRec.UUID__c, ocvId);
    } catch (Exception e) {
      handleCommonException(e);
    }
  }

  /**
   * @description check if all account is open or not
   * @param recordId recordId
   * @return Boolean accounts opened or closed
   */
  @AuraEnabled
  public static Boolean checkAccountsOpen(Id recordId) {
    try {
      PersonDigitalIdentity__x personDigitalRec = QUERY.getPersonDigitalIdentityRec(
        recordId
      );
      if (personDigitalRec.IAL_Identity_Assurance_Level__c != 4) {
        return false;
      }
      List<String> accountNumbers = new List<String>();
      List<UnifiedFinancialAccountModel.AccountList> financialAccList = FinancialAccountController.getFinancialAccountsFromFabric(
        personDigitalRec.OCV_ID__c,
        accountNumbers
      );

      List<UnifiedFinancialAccountModel.AccountList> filteredPlusAccounts = (List<UnifiedFinancialAccountModel.AccountList>) ListUtil.filter(financialAccList)
      .equals('origin', 'PRODUCT_ORIGIN_ANZX')
      .toList();

      return isAnyAccountOpen(filteredPlusAccounts);
    } catch (FinancialAccountAPIRepository.PermissionException e) {
      throw new AuraHandledException(
        'You don\'t have access to ANZx Accounts and Goals permission'
      );
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error occurred while performing operation'
      );
    }
  }

  /**
   * @description checking if any account is not closed
   * @param financialAccList financialAccList
   * @return Boolean
   */
  private static Boolean isAnyAccountOpen(
    List<UnifiedFinancialAccountModel.AccountList> financialAccList
  ) {
    for (
      UnifiedFinancialAccountModel.AccountList finAccObj : financialAccList
    ) {
      if (!finAccObj.finserv_status.equalsIgnoreCase('Closed')) {
        return true;
      }
    }
    return false;
  }

  /**
   * @description update ocvId for AUF
   * @param recordId recordId
   * @param action action
   */
  @AuraEnabled
  public static void archiveUser(Id recordId, String action) {
    try {
      PersonDigitalIdentity__x personDigitalRec = QUERY.getPersonDigitalIdentityRec(
        recordId
      );
      AUFREPO.archiveUser(personDigitalRec.UUID__c, action);
    } catch (AUFAPIRepository.ArchiveFailException e) {
      throw new AuraHandledException(
        'Unexpected error encountered - Open Banking data sharing arrangements could not be successfully archived. Please retry'
      );
    } catch (Exception e) {
      handleCommonException(e);
    }
  }

  /**
   * @description catch Exceptions
   * @param e Exception
   */
  public static void handleCommonException(Exception e) {
    if (e instanceof AUFAPIRepository.InsufficientAccessException) {
      throw new AuraHandledException(
        'You don’t have the required permission to perform this action'
      );
    } else if (e instanceof AUFAPIRepository.ServerErrorException) {
      throw new AuraHandledException(
        'The server encountered an unexpected condition that prevented it from fulfilling the request. Please retry after some time.'
      );
    } else {
      throw new AuraHandledException(
        'Error occurred while performing the action.'
      );
    }
  }
}