/**
 *
 * @author Mairaj Haider
 * @since 11/2022
 * @description Delete InActive Financial Account Role
 * This is WITHOUT sharing class because inactive financial role record is created by FSC package when
 * Primary Owner is reset if IsPrimary_Owner = false. This inactive record should always be deleted irrelevant of user permissions.
 */
public without sharing class ManageInactiveFinancialAccountRole {
  /**
   * @description This method delete inactive financial role recod
   * @param financialAccountIds Set of financial account ids
   */
  @future
  public static void deleteInActiveFinancialAccountRole(
    Set<Id> financialAccountIds
  ) {
    try {
      //Get FAR records
      if (!Schema.sObjectType.FinServ__FinancialAccountRole__c.isQueryable()) {
        return;
      }
      List<FinServ__FinancialAccountRole__c> farRecords = [
        SELECT Id
        FROM FinServ__FinancialAccountRole__c
        WHERE
          FinServ__FinancialAccount__c = :financialAccountIds
          AND FinServ__Active__c = FALSE
      ];
      if (
        FinServ__FinancialAccountRole__c.sObjectType.getDescribe().isDeletable()
      ) {
        delete farRecords;
      }
    } catch (Exception e) {
      Logger.error(
        'Error occured while deleting inactive financial account role records. ' +
        'More details: ' +
        e.getMessage()
      );
      Logger.saveLog();
    }
  }
}
