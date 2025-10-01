/**
 * @author Afreen Khan
 * @since 11/2020
 * @description  ContentDocumentTriggerHandler is the handler class for Content Document Trigger which extends Lib_TriggerHandler the trigger framework used.
 without sharing: for running as a system mode on BeforeDelete trigger because we cant provide users with access to have them taking action manually.
 */
public without sharing class ContentDocumentTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description onBeforeDelete
   */
  public override void onBeforeDelete() {
    ContentDocumentTriggerActions.restrictFileDeleteAction(
      (List<ContentDocument>) records
    );
  }
}
