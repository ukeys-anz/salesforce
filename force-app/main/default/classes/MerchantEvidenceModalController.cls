/**
 * @description       :
 * @author            : Anuj Jain
 * @group             :
 * @last modified on  : 11-05-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class MerchantEvidenceModalController {
  private static final IDOpsQueryRepository QUERY = (IDOpsQueryRepository) Lib_InstanceProvider.forType(
    IDOpsQueryRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  public static final Set<String> TASK_STATUSES = new Set<String>{
    'Not Started',
    'Pending'
  };

  /**
   * @description retrieving task records
   * @param caseId caseId
   * @return Task Task
   */
  @AuraEnabled
  public static Task getTaskRecord(String caseId) {
    try {
      List<Task> taskRecords = QUERY.getTaskAssociatedToCase(
        new Set<Id>{ caseId }
      );

      return taskRecords[0];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description updating task records
   * @param taskObj taskObj
   */
  @AuraEnabled
  public static void updateTaskStatus(Task taskObj) {
    try {
      DML_REPOSITORY.doUpdate(new List<Task>{ taskObj });
    } catch (Exception ex) {
      throw new AuraHandledException('Exception');
    }
  }
}
