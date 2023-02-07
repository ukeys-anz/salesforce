/**
 * @author Adnan
 * @since 10/2021
 * @description  Utility class for File / ContentVersion objects
 *
 */
public with sharing class FileUtil {
  /**
   * @description Checks the extension of attachments
   * @param mimeType Mime type of attachments
   * @param fileName Name of file for extension check
   * @return Boolean return true/false if the extension is valid
   */
  public static Boolean checkExtension(String mimeType, String fileName) {
    List<String> extensions = getExtensions(mimeType);
    if (
      extensions != null && extensions.contains(fileName.substringAfter('.'))
    ) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * @description Gets the extension of attachments
   * @param mimeType Mime type of attachments
   * @return List<String> List of extension type
   */
  public static List<String> getExtensions(String mimeType) {
    if (mimeTypeToFileExtensionsMap.containsKey(mimeType)) {
      return mimeTypeToFileExtensionsMap.get(mimeType).split(',');
    }
    return null;
  }

  private static Map<String, String> mimeTypeToFileExtensionsMap = new Map<String, String>{
    'text/plain' => 'txt,text,conf,def,list,log,in',
    'application/rtf' => 'rtf',
    'text/rtf' => 'rtf',
    'application/pdf' => 'pdf',
    'application/msword' => 'doc',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => 'docx',
    'image/tiff' => 'tiff,tif',
    'image/jpeg' => 'jpeg,jpg',
    'image/gif' => 'gif',
    'image/bmp' => 'bmp',
    'image/png' => 'png',
    'application/vnd.ms-excel' => 'xls',
    'application/octet-stream' => 'xls',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => 'xlsx',
    'application/vnd.ms-excel.sheet.binary.macroenabled.12' => 'xlsb',
    'application/vnd.ms-powerpoint' => 'ppt',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' => 'pptx',
    'message/rfc822' => 'eml',
    'application/vnd.ms-outlook' => 'msg',
    'text/csv' => 'csv',
    'application/zip' => 'zip',
    'application/x-zip-compressed' => 'zip'
  };

  /**
   * @description method to link attachment with case records
   * @param contentVerIds Content Version Ids
   * @param recordId The case Id that needs to be related to
   * @param shareType The permission granted to the user of the shared file in a library
   */
  public static void linkContentWithRecord(
    List<Id> contentVerIds,
    Id recordId,
    String shareType
  ) {
    List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();
    List<ContentVersion> contentVersionList;
    if (ContentVersion.sObjectType.getDescribe().isQueryable()) {
      contentVersionList = [
        SELECT Id, Title, ContentDocumentId
        FROM ContentVersion
        WHERE Id IN :contentVerIds
      ];
    }
    if (contentVersionList.size() > 0) {
      for (ContentVersion cv : contentVersionList) {
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = recordId;
        contentLink.ContentDocumentId = cv.ContentDocumentId;
        contentLink.ShareType = shareType;
        contentDocLinkList.add(contentLink);
      }
    }

    if (contentDocLinkList.size() > 0) {
      AccessCheckUtil.AccessCheckWrapper acw = AccessCheckUtil.checkAccess(
        'ContentDocumentLink',
        AccessType.CREATABLE,
        contentDocLinkList
      );
      if (acw.inAccessibleFields != null) {
        CommonUtil.logAndThrowIAE(
          FileUtil.class.getName(),
          'linkContentWithRecord',
          'User does not have create access to fields of ContentDocumentLink --' +
          acw.inAccessibleFields
        );
      } else {
        List<Database.SaveResult> results = Database.insert(
          contentDocLinkList,
          false
        );
        Logger.error('', results);
        Logger.saveLog();
      }
    }
  }
}
