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
   * @return Id of the related content document which provides preview to end user
   */
  @AuraEnabled(cacheable=false)
  public static Id getCFaaSDocument(
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

    Id contentDocumentId = getExistingContentDocument(cfaasFile);

    if (contentDocumentId == null) {
      contentDocumentId = getNewContentDocument(ocvId, cfaasFile);
    }

    return contentDocumentId;
  }

  /**
   * @description getNewContentDocument is called to fetch a file that does not
   * currently exist in SF and inserts a log that user has viewed the file
   * @param ocvId customer id
   * @param cfaasFile a wrapper of cfaas file record which user selected to view
   * @return Id of the newly inserted content document
   */
  private static Id getNewContentDocument(
    String ocvId,
    CFaaS_File__c cfaasFile
  ) {
    CFaaSAPIRepository cfaasAPI = new CFaaSAPIRepository();
    CFaaSDocumentModel.CFaaSDownloadUrl downloadUrlModel;
    Blob documentBody;

    try {
      downloadUrlModel = cfaasAPI.getDownloadURL(
        ocvId,
        cfaasFile.Document_Id__c
      );

      documentBody = cfaasAPI.fetchDocumentContent(
        downloadUrlModel.url,
        downloadUrlModel.otp,
        downloadUrlModel.contentType
      );
      cfaasFile.File_Extension__c = downloadUrlModel.extension;

      insertDocViewedLog(cfaasFile);

      return insertDocumentContent(cfaasFile, documentBody);
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
   * @return Id of the existing content document
   */
  private static Id getExistingContentDocument(CFaaS_File__c cfaasFile) {
    List<ContentVersion> cvList = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE
        FirstPublishLocationId = :cfaasFile.Id
        AND CreatedById = :CURRENT_USER_ID
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    if (!cvList.isEmpty()) {
      return cvList[0].ContentDocumentId;
    } else {
      return null;
    }
  }
}
