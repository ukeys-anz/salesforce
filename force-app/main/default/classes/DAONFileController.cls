/**
 * @author Tan Phan
 * @since 01/2025
 * @description Controller class for daonFileDownload lwc
 */
public with sharing class DAONFileController {
  private static final DAONFileRepository QUERY = (DAONFileRepository) Lib_InstanceProvider.forType(
    DAONFileRepository.class
  );
  private static final DAONFileAPIRepository SERVICE = (DAONFileAPIRepository) Lib_InstanceProvider.forType(
    DAONFileAPIRepository.class
  );

  /**
   * @description Retrieves documents based on the provided file types.
   * @param builder The DAONFileRequestBuilder instance.
   * @param fileTypes List of file types to retrieve.
   * @return A map of file type names to their corresponding URLs.
   */
  @AuraEnabled
  public static Map<String, String> getDocuments(
    DAONFileRequestBuilder builder,
    List<String> fileTypes
  ) {
    try {
      Map<DAONFileType, String> uuidByType = builder.buildUUIDByType(fileTypes);
      Map<DAONFileType, ContentVersion> cvByType = queryCvByType(uuidByType);
      Map<DAONFileType, ContentVersion> incompleteTypes = filterIncomplete(
        cvByType
      );
      if (incompleteTypes.isEmpty()) {
        return buildUrlByType(cvByType);
      }
      DAONFileRequestModel request = builder.buildRequest(incompleteTypes);
      SERVICE.downloadFiles(
        request,
        builder.customerId,
        builder.customerIdType
      );
      cvByType = queryCvByType(uuidByType);
      return buildUrlByType(cvByType);
    } catch (Exception e) {
      throw CommonUtil.logException(e);
    }
  }

  @TestVisible
  private static Map<DAONFileType, ContentVersion> queryCvByType(
    Map<DAONFileType, String> uuidByType
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

  @TestVisible
  private static Map<DAONFileType, ContentVersion> filterIncomplete(
    Map<DAONFileType, ContentVersion> cvByType
  ) {
    Map<DAONFileType, ContentVersion> output = new Map<DAONFileType, ContentVersion>();
    for (DAONFileType fileType : cvByType.keySet()) {
      ContentVersion cv = cvByType.get(fileType);
      if (isReady(cv) == false) {
        output.put(fileType, cv);
      }
    }
    return output;
  }

  @TestVisible
  private static Map<DAONFileType, ContentVersion> buildCvByType(
    Map<String, ContentVersion> cvByUUID,
    Map<DAONFileType, String> uuidByType
  ) {
    Map<DAONFileType, ContentVersion> cvByType = new Map<DAONFileType, ContentVersion>();
    for (DAONFileType fileType : uuidByType.keySet()) {
      String uuid = uuidByType.get(fileType);
      cvByType.put(fileType, cvByUUID.get(uuid));
    }
    return cvByType;
  }

  @TestVisible
  private static Boolean isReady(ContentVersion cv) {
    return cv?.Document_Flag__c == '4';
  }

  @TestVisible
  private static Map<String, String> buildUrlByType(
    Map<DAONFileType, ContentVersion> cvByType
  ) {
    Map<String, String> urlByType = new Map<String, String>();
    for (DAONFileType fileType : cvByType.keySet()) {
      ContentVersion cv = cvByType.get(fileType);
      urlByType.put(
        fileType.name(),
        isReady(cv) ? (Label.DAONImagePreviewURL + cv.Id) : null
      );
    }
    return urlByType;
  }
}
