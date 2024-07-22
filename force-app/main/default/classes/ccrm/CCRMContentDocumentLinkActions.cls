/**
 * @author Naman Garg
 * @since 06/2024
 * @description CCRMContentDocumentLinkActions this is to handle all the CCRM (Commercial CRM) Actions
 */
public with sharing class CCRMContentDocumentLinkActions {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final CCRMContentDocumentLinkRepository CDL_REPOSITORY = (CCRMContentDocumentLinkRepository) Lib_InstanceProvider.forType(
    CCRMContentDocumentLinkRepository.class
  );

  private static final String ATTACHMENT_NOTE_INITIAL = 'Please note that ';
  private static final String ATTACHMENT_NOTE_LATER = ' attachment(s) from the Email have been removed.';
  /**
   * @description Restrict Attachments and show erro when EmailMessae is created from Outlook with attachments.
   * @param cdlList ContentDocumentLink records in current trigger context
   */
  public static void restrictOutlookAttachments(
    List<ContentDocumentLink> cdlList
  ) {
    try {
      //Retrieve the list of profile that is allowed to delete outlook attachments.
      List<String> profileNames = System.Label.DCRM_ProfileAllowToDeleteOutlookAttachments.split(
        ';'
      );

      //Fetch the list of Email Message records from the Content Document Link
      List<Id> emailMessageIdList = new List<Id>(
        CommonUtil.getIds(cdlList, ContentDocumentLink.LinkedEntityId)
      );
      if (emailMessageIdList.isEmpty()) {
        return;
      }

      //Fetch the list of Email Message records created by allowed profile
      Map<Id, EmailMessage> emailMessagesMap = CDL_REPOSITORY.getEmailMessageUsingProfileName(
        emailMessageIdList,
        profileNames
      );

      //Segregare Content document based on Profile
      CdEmailMessageWrapper cdEmWrapper = segregateContentDocument(
        cdlList,
        emailMessagesMap
      );

      //Get Count of attachment to delete
      Map<Id, Integer> emToAttachmentCountMap = getCountOfAttachment(
        cdlList,
        emailMessagesMap
      );

      //Update count field value on Email Message
      List<EmailMessage> emToUpdateList = updateCountOnEmailMessage(
        emToAttachmentCountMap
      );
      DML_REPOSITORY.updateRecords(
        emToUpdateList,
        DmlRepository.ALL_OR_NONE,
        DmlRepository.USER_MODE
      );

      //Delete outlook attachment from Email Message
      deleteContentDocument(cdEmWrapper);
    } catch (Exception err) {
      Logger.error(
        'Error while Restricting Outlook Attachment for DCRM Users :' +
        err.getMessage(),
        err
      );
      Logger.saveLog();
      throw err;
    }
  }

  /**
   * @description This is used to get the segregate the content document Id basede on Profile
   * @param cdlList ContentDocumentLink records
   * @param emailMessagesMap Map of Email Message created by ML and CCRM
   * @return CdEmailMessageWrapper Wrapper containing list of ML and CCRM related Content Document record Ids
   */
  @testVisible
  private static CdEmailMessageWrapper segregateContentDocument(
    List<ContentDocumentLink> cdlList,
    Map<Id, EmailMessage> emailMessagesMap
  ) {
    CdEmailMessageWrapper cdEmWrapper = new CdEmailMessageWrapper();
    if (emailMessagesMap.isEmpty()) {
      return cdEmWrapper;
    }

    for (ContentDocumentLink cdl : cdlList) {
      EmailMessage em = emailMessagesMap.get(cdl.LinkedEntityId);
      if (em == null || !MLCRMCommonUtils.isContentDocumentDeleteAllowed(em)) {
        continue;
      }
      if (em.CreatedBy.Profile.Name == System.Label.MLCRM_Profile_Name) {
        cdEmWrapper.mlContentDocsToDelete.add(cdl.ContentDocumentId);
      }
      if (em.CreatedBy.Profile.Name == System.Label.CCRM_Profile_Name) {
        cdEmWrapper.ccrmContentDocsToDelete.add(cdl.ContentDocumentId);
      }
    }
    return cdEmWrapper;
  }

  /**
   * @description This is used to get the Count of Attachment linked to Email Message
   * @param cdlList ContentDocumentLink records
   * @param emailMessagesMap Map of Email Message created by ML and CCRM
   * @return Map<Id, Integer> Map containing the email Message Id and count of attachment
   */
  @testVisible
  private static Map<Id, Integer> getCountOfAttachment(
    List<ContentDocumentLink> cdlList,
    Map<Id, EmailMessage> emailMessagesMap
  ) {
    Map<Id, Integer> emToAttachmentCountMap = new Map<Id, Integer>();
    Integer count;
    String attachmentNotes = 'Please note that (\\d+) .*';
    Pattern p = Pattern.compile(attachmentNotes);
    if (emailMessagesMap.isEmpty()) {
      return emToAttachmentCountMap;
    }

    for (ContentDocumentLink cdl : cdlList) {
      EmailMessage em = emailMessagesMap.get(cdl.LinkedEntityId);
      count = 0;
      if (em == null || !MLCRMCommonUtils.isContentDocumentDeleteAllowed(em)) {
        continue;
      }
      Matcher m = p.matcher(em.Attachment_Notes__c);
      if (m.matches()) {
        count = Integer.valueOf(m.group(1));
      }
      emToAttachmentCountMap.put(em.Id, ++count);
    }
    return emToAttachmentCountMap;
  }

  /**
   * @description This is used to update count of Attachment on Email Message
   * @param emToAttachmentMap containing Email Message Id and Count of Attachment
   * @return List<EmailMessage> Email Message list which need to be update
   */
  @testVisible
  private static List<EmailMessage> updateCountOnEmailMessage(
    Map<Id, Integer> emToAttachmentMap
  ) {
    List<EmailMessage> emToUpdateList = new List<EmailMessage>();

    for (Id emId : emToAttachmentMap.keySet()) {
      EmailMessage emRecord = new EmailMessage(
        Id = emId,
        Attachment_Notes__c = ATTACHMENT_NOTE_INITIAL +
          emToAttachmentMap.get(emId) +
          ATTACHMENT_NOTE_LATER
      );
      emToUpdateList.add(emRecord);
    }
    return emToUpdateList;
  }

  /**
   * @description This is used to delete the content Document records
   * @param cdEmWrapper Wrapper containing list of ML and CCRM related Content Document record Ids
   */
  @testVisible
  private static void deleteContentDocument(CdEmailMessageWrapper cdEmWrapper) {
    if (!cdEmWrapper.mlContentDocsToDelete.isEmpty()) {
      System.enqueueJob(
        new MLCRMContentDocDeleteQueueable(cdEmWrapper.mlContentDocsToDelete),
        integer.valueof(System.Label.ML_Outlook_Attachment_Delete_Delay)
      );
    }

    if (!cdEmWrapper.ccrmContentDocsToDelete.isEmpty()) {
      System.enqueueJob(
        new MLCRMContentDocDeleteQueueable(cdEmWrapper.ccrmContentDocsToDelete),
        integer.valueof(System.Label.CCRM_Outlook_Attachment_Delete_Delay)
      );
    }
  }

  /**
   * @author Naman Garg
   * @since  06/2024
   * @description CdEmailMessageWrapper wrapper class to hold Content document id for ML & CCRM
   * @name CdEmailMessageWrapper
   */
  public class CdEmailMessageWrapper {
    @testVisible
    List<Id> mlContentDocsToDelete = new List<Id>();
    @testVisible
    List<Id> ccrmContentDocsToDelete = new List<Id>();
  }
}
