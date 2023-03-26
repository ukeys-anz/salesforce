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
    List<ContentVersion> cVersionList = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE
        RecordTypeID = :IDRConstants.CFAAS_FILE_RT_ID
        AND ContentDocumentId IN :cdList
    ];

    List<Id> idList = new List<Id>();
    for (ContentVersion cv : cVersionList) {
      idList.add(cv.ContentDocumentId);
    }

    for (ContentDocument cd : cdList) {
      if (
        !FeatureManagement.checkPermission('IDR_Level_1') &&
        !idList.contains(cd.Id)
      ) {
        cd.addError(IDRConstants.RESTRICTED_ACTION_MESSAGE);
      }
    }
  }
}
