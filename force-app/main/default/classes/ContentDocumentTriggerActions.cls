/**
 * @author Aman Gupta
 * @since 07/2025
 * @description This class provide actions for ContentDocumentTrigger.
 */

public with sharing class ContentDocumentTriggerActions {
  private static final ContentDocumentLinkRepository CDL_REPOSITORY = (ContentDocumentLinkRepository) Lib_InstanceProvider.forType(
    ContentDocumentLinkRepository.class
  );
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  public static final List<String> CONTENT_VERSION_RT = new List<String>{
    RTContentVersion.cfaasFile,
    RTContentVersion.daonFile,
    RTContentVersion.daonTrustXFile
  };
  public static final String RESTRICTED_ACTION_MESSAGE = 'You are not authorised to perform this action.';

  /**
   * @description Delete ContentDocuments CreatedBy Ml Users having incoming as true and linked with EmailMessage
   * @param cdList list of  ContentDocument in the current trigger context
   */
  public static void restrictFileDeleteAction(List<ContentDocument> cdList) {
    if (USER_INFO.checkCustomPermission('IDR_Level_1')) {
      return;
    }
    Set<Id> cdNoRT = new Set<Id>();
    List<ContentVersion> cVersionList = CDL_REPOSITORY.getCVList(
      cdList,
      CONTENT_VERSION_RT
    );

    List<Id> idList = new List<Id>();
    for (ContentVersion cv : cVersionList) {
      if (cv.RecordTypeId != null) {
        idList.add(cv.ContentDocumentId);
        continue;
      }
      cdNoRT.add(cv.ContentDocumentId);
    }

    for (ContentDocument cd : cdList) {
      if (!idList.contains(cd.Id) && !cdNoRT.contains(cd.Id)) {
        cd.addError(RESTRICTED_ACTION_MESSAGE);
      }
    }
  }
}
