/**
 * @author Adnan
 * @since 10/2021
 * @description  Utility class for Case Object
 *
 */
public with sharing class CaseUtil {
  /**
   * @description Updates the case with queue
   * @param newCase The case record
   */
  public static void updateCaseWithQueue(
    Case newCase,
    String type,
    String queueName
  ) {
    Group queue = CommonUtil.getGroupDetails(type, queueName);
    if (
      queue != null &&
      Case.sObjectType.getDescribe().isUpdateable() &&
      Schema.sObjectType.Case.fields.OwnerId.isUpdateable()
    ) {
      newCase.OwnerId = queue.Id;
      try {
        update newCase;
      } catch (Exception err) {
        Lib_SystemLog log = new Lib_SystemLog(
          CaseUtil.class.getName(),
          'updateCaseWithQueue'
        );
        log.error(
          'CaseUtilException',
          'Error in updating case with queue for caseId :' +
          newCase.Id +
          err.getMessage()
        );
        log.publishEvent();
      }
    } else {
      CommonUtil.logAndThrowIAE(
        CaseUtil.class.getName(),
        'updateCaseWithQueue',
        'Case is not updateable for the current user.'
      );
    }
  }
}
