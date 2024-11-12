/**
 * @author Emma Bindi
 * @since November 2022
 * @description CFaaSController is used to handle calls to CFaaS API to fetch
 * document content and temporarily store as Content Version to support previewing
 */
public with sharing class CFaaSController {
  public static final String FAILED_MESSAGE = 'Failed to retrieve document for previewing. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  public static final Id CURRENT_USER_ID = UserInfo.getUserId();

  /**
   * @description getCFaaSDocument is called to fetch and surface the requested file
   * @param ocvId customer id
   * @param docId document id reference in external system
   * @param cfaasFileId id of related cfaas file record which end user selected in order to view
   * @param securityClassification security classification of the file
   * @return CFassFileResult result of the document information
   */
  @AuraEnabled(cacheable=false)
  public static CFassFileResult getCFaaSDocument(
    String ocvId,
    String docId,
    String cfaasFileId,
    String securityClassification
  ) {
    CFaaS_File__c cfaasFile = new CFaaS_File__c(
      Id = cfaasFileId,
      Document_Id__c = docId,
      Security_Classification__c = securityClassification
    );

    CFassFileResult result = getExistingContentDocument(cfaasFile, ocvId);

    if (result == null) {
      result = getNewContentDocument(ocvId, cfaasFile, '');
    }

    return result;
  }

  /**
   * @description wrapper class for cfaas document information
   */
  public class CFassFileResult {
    @AuraEnabled
    public Id docId;
    @AuraEnabled
    public String result;
    @AuraEnabled
    public String status;
  }

  /**
   * @description getNewContentDocument is called to fetch a file that does not
   * currently exist in SF and inserts a log that user has viewed the file
   * @param ocvId customer id
   * @param cfaasFile a wrapper of cfaas file record which user selected to view
   * @param cvId content version id if applicable
   * @return CFassFileResult result of the new document information
   */
  private static CFassFileResult getNewContentDocument(
    String ocvId,
    CFaaS_File__c cfaasFile,
    String cvId
  ) {
    CFaaSAPIRepository cfaasAPI = new CFaaSAPIRepository();
    CFaaSDocumentModel.CFaaSDownloadUrl downloadUrlModel;

    try {
      downloadUrlModel = cfaasAPI.getDownloadURL(
        ocvId,
        cfaasFile.Document_Id__c,
        cfaasFile.Id,
        cvId
      );

      List<ContentVersion> cvList = [
        SELECT ContentDocumentId, CreatedDate, Document_Flag__c
        FROM ContentVersion
        WHERE Id = :downloadUrlModel.contentVersionId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];

      insertDocViewedLog(cfaasFile);

      if (cvList.isEmpty()) {
        return null;
      }
      CFassFileResult result = new CFassFileResult();
      result.docId = cvList[0].ContentDocumentId;
      result.result = BOHConstants.CFAAS_DOCUMENT_FLAG.CREATING.name();
      if (cvList[0].Document_Flag__c == '4') {
        // final
        result.status = BOHConstants.CFAAS_FILE_STATUS.FINALVERSION.name();
      } else {
        result.status = BOHConstants.CFAAS_FILE_STATUS.DRAFT.name();
      }
      return result;
    } catch (Exception e) {
      throw new AuraHandledException(FAILED_MESSAGE);
    }
  }

  /**
   * @description insert a log recording details of document fetched and viewed from CFaaS
   * @param cfaasFile CFaaS_File__c record and its details
   */
  private static void insertDocViewedLog(CFaaS_File__c cfaasFile) {
    String logMessage =
      Datetime.now() +
      ' UserId ' +
      CURRENT_USER_ID +
      ' viewed CFaaS doc# ' +
      cfaasFile.Document_Id__c +
      ' Security Classification: ' +
      cfaasFile.Security_Classification__c;

    Logger.info(logMessage);
    Logger.saveLog();
  }

  /**
   * @description Insert the Content Version record
   * @param cfaasFile CFaaS_File__c record and its details
   * @param docContent blob content of the document to be inserted
   * @return Id of the content document record that will be inserted
   */
  private static Id insertDocumentContent(
    CFaaS_File__c cfaasFile,
    Blob docContent
  ) {
    if (!PermissionUtils.canCreate('ContentVersion')) {
      CommonUtil.logAndThrowIAE(
        'CFaaSController',
        'insertDocumentContent',
        'Not enough permissions to create records for the required object.'
      );
    }

    Id cfaasFileRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByName()
      .get('CFaaS File')
      .getRecordTypeId();

    try {
      ContentVersion cv = new ContentVersion();
      cv.VersionData = docContent;
      cv.Title =
        cfaasFile.Document_Id__c +
        ' - ' +
        cfaasFile.Security_Classification__c;
      cv.PathOnClient =
        cfaasFile.Document_Id__c +
        '.' +
        cfaasFile.File_Extension__c;
      cv.RecordTypeId = cfaasFileRecordTypeId;
      cv.FirstPublishLocationId = cfaasFile.Id;

      insert cv;

      ContentVersion insertedCV = [
        SELECT Id, ContentDocumentId
        FROM ContentVersion
        WHERE Id = :cv.Id
        LIMIT 1
      ];
      return insertedCV.ContentDocumentId;
    } catch (Exception e) {
      Logger.error(e.getMessage());
      Logger.saveLog();
      throw e;
    }
  }

  /**
   * @description getExistingContentDocument is called to check if the file already exists
   * and was created by the same user re-accessing the file
   * @param cfaasFile CFaaS_File__c record and its details
   * @param ocvId customer id
   * @return CFassFileResult result of the existing document information
   */
  private static CFassFileResult getExistingContentDocument(
    CFaaS_File__c cfaasFile,
    String ocvId
  ) {
    String uid = cfaasFile.Document_Id__c + '-' + CURRENT_USER_ID;
    List<ContentVersion> cvList = [
      SELECT Id, ContentDocumentId, CreatedDate, Document_Flag__c
      FROM ContentVersion
      WHERE UUID__c = :uid AND RecordTypeId = :IDRConstants.CFAAS_FILE_RT_ID
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    if (cvList.isEmpty()) {
      return null;
    }
    CFassFileResult result = new CFassFileResult();
    result.docId = cvList[0].ContentDocumentId;
    result.result = BOHConstants.CFAAS_DOCUMENT_FLAG.EXISTING.name();
    if (cvList[0].Document_Flag__c == '4') {
      // final
      result.status = BOHConstants.CFAAS_FILE_STATUS.FINALVERSION.name();
    } else {
      result.status = BOHConstants.CFAAS_FILE_STATUS.DRAFT.name();
      if (isTimeMoreThanTwoMin(cvList[0].CreatedDate)) {
        getNewContentDocument(ocvId, cfaasFile, cvList[0].Id);
      }
    }
    return result;
  }

  /**
   * @description function to tell whether created time is more than 2 mins from now
   * @param targetTime targe time to compare to
   * @return Boolean result whether it is more than 2 mins or not
   */
  private static Boolean isTimeMoreThanTwoMin(Datetime targetTime) {
    Datetime currentTime = Datetime.Now();
    Decimal timeDifferenceInMin =
      (currentTime.getTime() - targetTime.getTime()) / (60 * 1000);
    return timeDifferenceInMin > 2;
  }
}
