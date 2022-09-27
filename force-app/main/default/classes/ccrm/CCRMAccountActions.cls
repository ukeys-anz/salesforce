/**
 * @author Emmanuel Yap
 * @since  05/2022
 * @group CCRM (Commercial CRM)
 * @description CCRMAccountActions is class to handle all the CCRM Account Actions
 */
public with sharing class CCRMAccountActions {
  /**
   * @description This method will update Controlling Post field depending on the CPID provided in Account.
   * @name setControllingPost
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in afterUpdate.
   */
  public static void setControllingPost(
    List<Account> records,
    Map<Id, Account> oldMap
  ) {
    Map<String, List<Account>> mappedAccounts = mapAccountsToCPID(
      records,
      oldMap
    );

    Set<String> cpids = mappedAccounts.keySet();

    try {
      List<Controlling_Post__c> cps = [
        SELECT Id, CPID__c
        FROM Controlling_Post__c
        WHERE CPID__c IN :cpids
        WITH SECURITY_ENFORCED
      ];

      for (Controlling_Post__c cp : cps) {
        if (cp.CPID__c != null) {
          List<Account> accounts = mappedAccounts.get(cp.CPID__c);
          for (Account account : accounts) {
            account.Controlling_Post__c = cp.id;
          }
        }
      }
    } catch (System.QueryException qe) {
      lib_systemLog log = new lib_systemLog(
        CCRMAccountActions.class.getName(),
        'setControllingPost'
      );
      log.error(
        'InsufficientAccessException',
        qe.getMessage(),
        qe.getTypeName()
      );
      log.publishEvent();
    }
  }

  /**
   * @description Returns a map of Accounts with CPID as key
   * @name mapAccountsToCPID
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in afterUpdate.
   * @return `Map<String, List<Account>>` Return map of Accounts with CPID as key
   */
  private static Map<String, List<Account>> mapAccountsToCPID(
    List<Account> records,
    Map<Id, Account> oldMap
  ) {
    Map<String, List<Account>> mappedAccounts = new Map<String, List<Account>>();
    for (Account record : records) {
      Account oldRec = oldMap != null ? oldMap.get(record.id) : null;
      if (oldMap == null || isCPIDChanged(record, oldRec)) {
        if (record.CPID__c == null) {
          record.Controlling_Post__c = null;
          continue;
        }
        if (mappedAccounts.containsKey(record.CPID__c)) {
          mappedAccounts.get(record.CPID__c).add(record);
        } else {
          mappedAccounts.put(record.CPID__c, new List<Account>{ record });
        }
      }
    }
    return mappedAccounts;
  }

  /**
   * @description Returns true if this Account record CPID was changed, returns false otherwise
   * @name isCPIDChanged
   * @param record Account record
   * @param oldRec old Account record from trigger
   * @return `Boolean` True if the CPID is updated otherwise false.
   */
  private static Boolean isCPIDChanged(Account record, Account oldRec) {
    if (oldRec != null && record.CPID__c != oldRec.CPID__c) {
      return true;
    }
    return false;
  }
}
