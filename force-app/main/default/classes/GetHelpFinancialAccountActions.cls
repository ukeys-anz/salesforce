/**
 * @author Arpit Pittie
 * @since 01/02/2024
 * @description To handle all Get Help Financial Account Actions
 */
public class GetHelpFinancialAccountActions {
  public static final String CUSTOMER_ACTION_STATUS_PEDING = 'STATE_PENDING';
  public static final String CUSTOMER_ACTION_ERROR = 'Error';
  public static final String CUSTOMER_ACTION_STATUS_COMPLETED = 'Completed';
  public static final String SIGNATORY_UPDATE_ERROR_MESSAGE = 'No pending request for update exist.';

  /**
   * @description To perform all the validations before update
   * @param records FinServ__FinancialAccount__c new updated records
   * @param oldMap FinServ__FinancialAccount__c map of old records
   */
  public static void onBeforeUpdateValidations(
    List<FinServ__FinancialAccount__c> records,
    Map<Id, FinServ__FinancialAccount__c> oldMap
  ) {
    try {
      Map<Id, Customer_Action__c> finAccIdToCustActionMap = getPendingCustomerAction(
        oldMap.keySet()
      );
      checkPendingCustomerActionExist(records, oldMap, finAccIdToCustActionMap);
    } catch (Exception exp) {
      Logger.error(exp.getMessage(), exp);
      Logger.saveLog();
    }
  }

  /**
   * @description To check if pending customer Action should be there
   * @param records FinServ__FinancialAccount__c new updated records
   * @param oldMap FinServ__FinancialAccount__c map of old records
   * @param finAccIdToCustActionMap Financial Account Id to Customer Action Map
   */
  @TestVisible
  private static void checkPendingCustomerActionExist(
    List<FinServ__FinancialAccount__c> records,
    Map<Id, FinServ__FinancialAccount__c> oldMap,
    Map<Id, Customer_Action__c> finAccIdToCustActionMap
  ) {
    for (FinServ__FinancialAccount__c finAcc : records) {
      FinServ__FinancialAccount__c oldFinAcc = oldMap.get(finAcc.Id);
      if (
        oldFinAcc.Number_Of_Signatures__c != finAcc.Number_Of_Signatures__c &&
        finAccIdToCustActionMap.get(finAcc.Id) == null
      ) {
        finAcc.addError(SIGNATORY_UPDATE_ERROR_MESSAGE);
      }
    }
  }

  /**
   * @description To update the Cutomer_Action__c record
   * @param records FinServ__FinancialAccount__c new updated records
   * @param oldMap FinServ__FinancialAccount__c map of old records
   */
  public static void updateCustomerActionRecord(
    List<FinServ__FinancialAccount__c> records,
    Map<Id, FinServ__FinancialAccount__c> oldMap
  ) {
    try {
      Map<Id, Customer_Action__c> finAccIdToCustActionMap = getPendingCustomerAction(
        oldMap.keySet()
      );
      List<Customer_Action__c> customerActionToUpdateList = updateCustomerActionToComplete(
        records,
        oldMap,
        finAccIdToCustActionMap
      );
      DMLUtil.updateRecords(
        customerActionToUpdateList,
        DMLUtil.NOT_ALLOW_PARTIAL_UPDATE,
        DMLUtil.USER_MODE
      );
    } catch (Exception exp) {
      Logger.error(exp.getMessage(), exp);
      Logger.saveLog();
    }
  }

  /**
   * @description To check if pending customer Action should be there
   * @param records FinServ__FinancialAccount__c new updated records
   * @param oldMap FinServ__FinancialAccount__c map of old records
   * @param finAccIdToCustActionMap Financial Account Id to Customer Action Map
   * @return List<Customer_Action__c> updated list of Customer_Action__c
   */
  @TestVisible
  private static List<Customer_Action__c> updateCustomerActionToComplete(
    List<FinServ__FinancialAccount__c> records,
    Map<Id, FinServ__FinancialAccount__c> oldMap,
    Map<Id, Customer_Action__c> finAccIdToCustActionMap
  ) {
    List<Customer_Action__c> customerActionToUpdateList = new List<Customer_Action__c>();
    for (FinServ__FinancialAccount__c finAcc : records) {
      FinServ__FinancialAccount__c oldFinAcc = oldMap.get(finAcc.Id);
      if (oldFinAcc.Number_Of_Signatures__c != finAcc.Number_Of_Signatures__c) {
        Customer_Action__c ca = finAccIdToCustActionMap.get(finAcc.Id);
        ca.Status__c = CUSTOMER_ACTION_STATUS_COMPLETED;
        customerActionToUpdateList.add(ca);
      }
    }
    return customerActionToUpdateList;
  }

  /**
   * @description To get the Customer_Action__c records based on Financial Account Ids
   * @param financialAccountIdSet Set of Financial Account Ids
   * @return Map of Financial Account Id to Pending Customer Action record
   */
  private static Map<Id, Customer_Action__c> getPendingCustomerAction(
    Set<Id> financialAccountIdSet
  ) {
    Map<Id, Customer_Action__c> finAccIdToCustActionMap = new Map<Id, Customer_Action__c>();
    List<Customer_Action__c> custActionList = [
      SELECT Id, Status__c, Financial_Account__c
      FROM Customer_Action__c
      WHERE
        RecordTypeId = :GetHelpConstants.CUSTOMER_ACTION_FIN_ACCOUNT_UPDATE_RT_ID
        AND Financial_Account__c IN :financialAccountIdSet
        AND Status__c = :CUSTOMER_ACTION_STATUS_PEDING
      WITH SECURITY_ENFORCED
    ];
    for (Customer_Action__c ca : custActionList) {
      finAccIdToCustActionMap.put(ca.Financial_Account__c, ca);
    }
    return finAccIdToCustActionMap;
  }
}
