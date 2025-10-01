/**
 * @author Aman Gupta
 * @since 07/2025
 * @description This class provide actions for ContentDocumentTrigger.
 */

public with sharing class ContentDocumentTriggerActions {
  private static final CCRMContentDocumentLinkRepository CDL_REPOSITORY = (CCRMContentDocumentLinkRepository) Lib_InstanceProvider.forType(
    CCRMContentDocumentLinkRepository.class
  );
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  public static final List<String> CONTENT_VERSION_RT = new List<String>{
    RTContentVersion.cfaasFile,
    RTContentVersion.daonFile,
    RTContentVersion.daonTrustXFile
  };

  /**
   * @description Delete ContentDocuments CreatedBy Ml Users having incoming as true and linked with EmailMessage
   * @param cdList list of  ContentDocument in the current trigger context
   */
  public static void restrictFileDeleteAction(List<ContentDocument> cdList) {
    if (USER_INFO.checkCustomPermission('IDR_Level_1')) {
      return;
    }
    Set<Id> cdNoRT = new Set<Id>();
    List<String> profileNames = System.Label.DCRM_ProfileAllowToDeleteOutlookAttachments.split(
      ';'
    );
    Map<Id, EmailMessage> emailMessageMap = new Map<Id, EmailMessage>();
    Map<Id, Id> cdIdToCdlIdMap = new Map<Id, Id>();
    Map<Id, Id> cdlIdToEmIdMap = new Map<Id, Id>();

    List<ContentVersion> cVersionList = CDL_REPOSITORY.getCVList(cdList);

    List<Id> idList = new List<Id>();
    for (ContentVersion cv : cVersionList) {
      if (cv.RecordTypeId != null) {
        idList.add(cv.ContentDocumentId);
        continue;
      }
      cdNoRT.add(cv.ContentDocumentId);
    }
    Set<Id> contentDocIdSet = ListUtil.getIds(cdList, ContentDocument.Id);

    List<ContentDocumentLink> cdlList = CDL_REPOSITORY.getCDL(contentDocIdSet);

    for (ContentDocumentLink cdl : cdlList) {
      if (cdl.LinkedEntityId.getSObjectType() == EmailMessage.sObjectType) {
        cdlIdToEmIdMap.put(cdl.Id, cdl.LinkedEntityId);
        cdIdToCdlIdMap.put(cdl.ContentDocumentId, cdl.Id);
      }
    }

    emailMessageMap = CDL_REPOSITORY.getEmailMessageUsingProfileName(
      cdlIdToEmIdMap.values(),
      profileNames
    );
    for (ContentDocument cd : cdList) {
      if (idList.contains(cd.Id) || cdNoRT.contains(cd.Id)) {
        continue;
      }
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
