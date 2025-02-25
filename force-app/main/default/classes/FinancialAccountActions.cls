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

  public static final String CUSTOMER_ACTION_STATUS_PENDING = 'STATE_PENDING';
  public static final String CUSTOMER_ACTION_ERROR = 'Error';
  public static final String CUSTOMER_ACTION_STATUS_COMPLETED = 'Completed';

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
      List<Customer_Action__c> pendingCustomerActions = FINANCIAL_ACCOUNT_REPOSITORY.getPendingCustomerActionForFinancialAccounts(
        oldMap.keySet()
      );

      Map<Id, Customer_Action__c> finAccIdToCustActionMap = (Map<Id, Customer_Action__c>) ListUtil.mapBy(
        pendingCustomerActions,
        Customer_Action__c.Financial_Account__c
      );

      if (finAccIdToCustActionMap.isEmpty()) {
        return;
      }

      List<Customer_Action__c> customerActionToUpdateList = updateCustomerActionToComplete(
        records,
        oldMap,
        finAccIdToCustActionMap
      );

      DML_REPOSITORY.doUpdate(customerActionToUpdateList);
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
      if (
        oldFinAcc.Number_Of_Signatures__c != finAcc.Number_Of_Signatures__c &&
        finAccIdToCustActionMap.get(finAcc.Id) != null
      ) {
        Customer_Action__c ca = finAccIdToCustActionMap.get(finAcc.Id);
        ca.Status__c = CUSTOMER_ACTION_STATUS_COMPLETED;
        customerActionToUpdateList.add(ca);
      }
    }
    return customerActionToUpdateList;
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
        record.FinServ__ProductName__c = null;
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
          continue;
        }
        record.FinServ__ProductName__c = null;
      }
    }
  }
}
