/**
 * @author Afreen Khan
 * @since 11/2020
 * @description  ContentDocumentTriggerHandler is the handler class for Content Document Trigger which extends Lib_TriggerHandler the trigger framework used.
 */
public class ContentDocumentTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description onBeforeDelete
   */
  public override void onBeforeDelete() {
    restrictFileDeleteAction((List<ContentDocument>) records);
  }

  /**
   * @description Restrict the file owners to delete a file. For other users, visibility of the file is set to ready only, managed by the file setting and content document Link records
   * @param cdList list of  ContentDocument in the current trigger context
   */
  public static void restrictFileDeleteAction(List<ContentDocument> cdList) {
    for (ContentDocument cv : cdList) {
      cv.addError(IDRConstants.RESTRICTED_ACTION_MESSAGE);
    }
  }
}
