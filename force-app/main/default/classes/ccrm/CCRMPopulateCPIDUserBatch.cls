/**
 * @author Naman Garg
 * @since  12/2023
 * @group CCRM (Commercial CRM)
 * @description CCRMPopulateCPIDUserBatch is batch class to populate CPID User lookup on Controlling Post based on CPID Lan Id.
 */

public class CCRMPopulateCPIDUserBatch implements Database.Batchable<sobject> {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final CCRMControllingPostRepository CP_REPOSITORY = (CCRMControllingPostRepository) Lib_InstanceProvider.forType(
    CCRMControllingPostRepository.class
  );

  /**
   * @description Get all the Controlling Post records where CPID Lan Id field is not null and CPID User field is null.
   * @name start
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator scope
   */
  public static Database.queryLocator start(Database.BatchableContext bc) {
    String query =
      'SELECT Id, CPID_LanID__c, CPID_User__c, CPID_CancelFag__c ' +
      'FROM Controlling_Post__c ' +
      'WHERE CPID_LanID__c != null ' +
      'AND CPID_User__c = \'\' ' +
      'AND CPID_CancelFag__c = false';
    return Database.getQueryLocator(query);
  }

  /**
   * @description method to process data when batch is executed.
   * @name execute
   * @param bc Database.BatchableContext
   * @param cpList from start method
   */
  public static void execute(
    Database.BatchableContext bc,
    List<Controlling_Post__c> cpList
  ) {
    try {
      Set<String> lanIdsSet = CCRMControllingPostHelper.getLanIds(cpList);
      List<User> userList = CP_REPOSITORY.getActiveLanIdUser(lanIdsSet);
      Map<String, User> mapOfLanIdToUser = CCRMControllingPostHelper.formLanIdToUserMap(
        userList
      );
      List<Controlling_Post__c> cpRecordToUpdateList = CCRMControllingPostHelper.setUserLookup(
        cpList,
        mapOfLanIdToUser
      );
      DML_REPOSITORY.updateRecords(
        cpRecordToUpdateList,
        DmlRepository.ALLOW_PARTIAL,
        DmlRepository.SYSTEM_MODE
      );
    } catch (Exception e) {
      Logger.error('Error while updating the records ' + e.getMessage());
      Logger.saveLog();
    }
  }

  /**
   * @description To execute any post processing steps
   * @name finish
   * @param bc Database.BatchableContext
   */
  public static void finish(Database.BatchableContext bc) {
  }
}
