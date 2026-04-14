/**
 * @author       : Ashish Kumar
 * @since        : Nov 2025
 * @description  : MobileLendingtTaskActions is the action class for Task Trigger which extends Lib_TriggerHandler from the trigger framework used.
 **/
public class MobileLendingtTaskActions {
  private static final String DUE_DATE_BLANK = 'Due date cannot be blank.';
  /**
   * @description This method to validate due date for ml task
   * @name validateActivityDate
   * @param records List of task records
   * @param oldMap old Map of task records
   * @author Ashish Kumar
   * @US CC-17852
   */
  public static void validateActivityDate(
    List<Task> records,
    Map<Id, Task> oldMap
  ) {
    List<Task> filteredRecords = ListUtil.filter(records, oldMap)
      .equals(Task.isRecurrence, false)
      .isNull(Task.ActivityDate)
      .changed(Task.ActivityDate)
      .toList();
    ListUtil.addError(filteredRecords, DUE_DATE_BLANK);
  }
}
