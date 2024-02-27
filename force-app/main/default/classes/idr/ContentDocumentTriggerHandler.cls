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
    restrictFileDeleteAction((List<ContentDocument>) records);
  }

  /**
   * @description Delete ContentDocuments CreatedBy Ml Users having incoming as true and linked with EmailMessage
   * @param cdList list of  ContentDocument in the current trigger context
   */
  public static void restrictFileDeleteAction(List<ContentDocument> cdList) {
    String mlProifleName = MLCRMConstants.ML_PROFILE_NAME;
    Map<Id, EmailMessage> emailMessageMap = new Map<Id, EmailMessage>();
    Map<Id, Id> cdIdToCdlIdMap = new Map<Id, Id>();
    Map<Id, Id> cdlIdToEmIdMap = new Map<Id, Id>();

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
    List<Id> contentDocIdList = new List<Id>();
    for (ContentDocument cd : cdList) {
      contentDocIdList.add(cd.Id);
    }
    List<ContentDocumentLink> cdlList = [
      SELECT Id, LinkedEntityId, ContentDocumentId
      FROM ContentDocumentLink
      WHERE ContentDocumentId IN :contentDocIdList
    ];

    for (ContentDocumentLink cdl : cdlList) {
      if (cdl.LinkedEntityId.getSObjectType() == EmailMessage.sObjectType) {
        cdlIdToEmIdMap.put(cdl.Id, cdl.LinkedEntityId);
        cdIdToCdlIdMap.put(cdl.ContentDocumentId, cdl.Id);
      }
    }
    if (!cdlIdToEmIdMap.isEmpty()) {
      emailMessageMap = MLCRMCommonUtils.getEmailMessageUsingProfileName(
        cdlIdToEmIdMap.values(),
        mlProifleName
      );
    }
    for (ContentDocument cd : cdList) {
      if (
        !FeatureManagement.checkPermission('IDR_Level_1') &&
        !idList.contains(cd.Id)
      ) {
        // If CotentDocument is created by ML user with Incoming as true and LinkedToEmailMessage then do not restrict to delete
        if (
          cdIdToCdlIdMap.containsKey(cd.Id) &&
          cdlIdToEmIdMap.containsKey(cdIdToCdlIdMap.get(cd.id)) &&
          emailMessageMap.containsKey(
            cdlIdToEmIdMap.get(cdIdToCdlIdMap.get(cd.id))
          )
        ) {
          EmailMessage em = emailMessageMap.get(
            cdlIdToEmIdMap.get(cdIdToCdlIdMap.get(cd.id))
          );
          if (MLCRMCommonUtils.isContentDocumentDeleteAllowed(em)) {
            continue;
          }
        }
        cd.addError(IDRConstants.RESTRICTED_ACTION_MESSAGE);
      }
    }
  }
}
