/**
 * @description       :
 * @author            : Anuj Jain
 * @group             :
 * @last modified on  : 04-16-2025
 **/
public with sharing class TrustMeDocumentDetailsHelper {
  private static final String AUDIT_LOG_MSG = '{0} | UserId {1} viewed DAON documents on {2} for Customer {3}/{4} Security Classification: CONFIDENTIAL';
  private static final TrustMeDocumentQueryRepository QUERY = (TrustMeDocumentQueryRepository) Lib_InstanceProvider.forType(
    TrustMeDocumentQueryRepository.class
  );
  /**
   * @description building An Map of fileType and UUID
   * @param response (An instance of TrustMeDocumentRequestModel model class)
   * @return  Map<String,String> (Map of file type and UUID)
   */
  public static Map<String, String> buildUUIDByType(
    TrustMeDocumentRequestModel response
  ) {
    Map<String, String> uuidByType = new Map<String, String>();
    for (
      TrustMeDocumentRequestModel.Attachments attachmentObj : response.attachments
    ) {
      List<String> keys = new List<String>{
        UserInfo.getUserId(),
        attachmentObj.fileType,
        attachmentObj.documentId,
        response.evaluationId
      };
      String uuid = String.join(keys, '-');
      uuidByType.put(attachmentObj.fileType, uuid);
    }
    return uuidByType;
  }

  /**
   * @description fetching content version records by UUID
   * @param uuidByType (Map of file type and UUID)
   * @return  Map<String,String> (Map of file type and contentVersion record)
   */
  public static Map<String, ContentVersion> queryCvByType(
    Map<String, String> uuidByType
  ) {
    List<ContentVersion> contentVersions = QUERY.contentVersionsByUUIDs(
      uuidByType.values()
    );
    Map<String, ContentVersion> cvByUUID = (Map<String, ContentVersion>) ListUtil.mapBy(
      contentVersions,
      ContentVersion.UUID__c
    );
    return buildCvByType(cvByUUID, uuidByType);
  }

  /**
   * @description fetching content version records by UUID
   * @param cvByUUID (Map of UUID and ContentVersion)
   * @param uuidByType (Map of file type and UUID)
   * @return  Map<String,String> (Map of file type and contentVersion record)
   */
  public static Map<String, ContentVersion> buildCvByType(
    Map<String, ContentVersion> cvByUUID,
    Map<String, String> uuidByType
  ) {
    Map<String, ContentVersion> cvByType = new Map<String, ContentVersion>();
    for (String fileType : uuidByType.keySet()) {
      String uuid = uuidByType.get(fileType);
      cvByType.put(fileType, cvByUUID.get(uuid));
    }
    return cvByType;
  }

  /**
   * @description to check if content version record is in final stage
   * @param cvByType (Map of fileType and ContentVersion)
   * @return  Map<String,String> (Map of file type and contentVersion record)
   */
  public static Map<String, ContentVersion> filterIncomplete(
    Map<String, ContentVersion> cvByType
  ) {
    Map<String, ContentVersion> output = new Map<String, ContentVersion>();
    for (String fileType : cvByType.keySet()) {
      ContentVersion cv = cvByType.get(fileType);
      if (isReady(cv) == false) {
        output.put(fileType, cv);
      }
    }
    return output;
  }

  /**
   * @description building url of documents against documentType
   * @param cvByType (Map of fileType and ContentVersion)
   * @return  Map<String,String> (Map of file type and contentVersion URL)
   */
  public static Map<String, String> buildUrlByType(
    Map<String, ContentVersion> cvByType
  ) {
    Map<String, String> urlByType = new Map<String, String>();
    for (String fileType : cvByType.keySet()) {
      ContentVersion cv = cvByType.get(fileType);
      urlByType.put(
        fileType,
        isReady(cv) ? (Label.DAONImagePreviewURL + cv.Id) : null
      );
    }
    return urlByType;
  }

  /**
   * @description checing if content version record is in final state
   * @param cv cv
   * @return Boolean
   */
  public static Boolean isReady(ContentVersion cv) {
    return cv?.Document_Flag__c == '4';
  }

  /**
   * @description loggin if any error occured
   * @param requestModel requestModel
   * @param urlByType urlByType
   * @param caseNumber caseNumber
   */
  public static void logAudit(
    TrustMeDocumentRequestModel requestModel,
    Map<String, String> urlByType,
    String caseNumber
  ) {
    for (String fileType : urlByType.keySet()) {
      String url = urlByType.get(fileType);
      if (url == null) {
        continue;
      }
      String logMessage =
        Datetime.now() +
        ' UserId ' +
        UserInfo.getUserId() +
        ' viewed DAON documents on ' +
        requestModel.relatedId +
        ' Record - ' +
        caseNumber +
        ' Security Classification: CONFIDENTIAL';
      Logger.info(logMessage);
      Logger.saveLog();
      break;
    }
  }

  /**
   * @description Retrieve Evaluation Metadata Mapping Records
   * @return sectionFieldValues (An Map of evaluation Section Name and List of Section records)
   */
  public static Map<String, List<TrustMe_Docs_Tab_Section_Detail__mdt>> evaluationSections() {
    Map<String, List<TrustMe_Docs_Tab_Section_Detail__mdt>> sectionFieldValues = new Map<String, List<TrustMe_Docs_Tab_Section_Detail__mdt>>();
    Set<String> sectionNames = QueryTrustMeDocsTabSections.getDocTabSectionDeveloperNames();
    for (String sectionName : sectionNames) {
      List<TrustMe_Docs_Tab_Section_Detail__mdt> sectionDetailList = QueryTrustMeDocsTabSections.getByDocTabSectionDeveloperName(
        sectionName
      );
      sectionFieldValues.put(sectionName, sectionDetailList);
    }
    return sectionFieldValues;
  }
}
