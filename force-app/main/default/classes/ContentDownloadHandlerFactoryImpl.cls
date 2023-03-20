/**
 * @author Emma Bindi
 * @since November 2022
 * @description ContentDownloadHandlerFactoryImpl this interface provides a class factory
 * which is called to create instances of the custom ContentDownloadHandler
 * can provide custom handling of ContentVersion download activity
 */
public with sharing class ContentDownloadHandlerFactoryImpl implements Sfc.ContentDownloadHandlerFactory {
  /**
   * @description getContentDownloadHandler defines a custom download handler that controls how content is downloaded
   * @param ids list of content IDs representing Salesforce Files
   * @param context a `Sfc.ContentDownloadContext` enum representing the download context
   * @return `Sfc.ContentDownloadHandler` for a given list of content IDs and a download context
   */
  public Sfc.ContentDownloadHandler getContentDownloadHandler(
    List<ID> ids,
    Sfc.ContentDownloadContext context
  ) {
    Sfc.ContentDownloadHandler contentDownloadHandler = new Sfc.ContentDownloadHandler();

    // S1 context represents downloads from Lightning Experience
    if (context == Sfc.ContentDownloadContext.S1) {
      logCFaaSFileDownloads(ids);
    }

    contentDownloadHandler.isDownloadAllowed = true;
    return contentDownloadHandler;
  }

  /**
   * @description logCFaaSFileDownloads filters and inserts custom log for any download activity
   * of ContentVersion records of CFaaS File type
   * @param ids list of content IDs being downloaded from Lightning Experience context
   */
  private static void logCFaaSFileDownloads(List<Id> ids) {
    Id currentUserId = UserInfo.getUserId();

    // Filter for CFaaS File types only
    List<ContentVersion> contentVersionList = [
      SELECT Id, Title, FileType
      FROM ContentVersion
      WHERE Id IN :ids AND RecordType.DeveloperName = 'CFaaS_File'
    ];

    if (contentVersionList.isEmpty()) {
      return;
    }

    for (ContentVersion content : contentVersionList) {
      String docId = content.Title.substringBefore('-');
      String securityClassification = content.Title.substringAfter('-');

      String logMessage =
        Datetime.now() +
        ' UserId ' +
        currentUserId +
        ' downloaded CFaaS doc# ' +
        docId +
        ' Security Classification: ' +
        securityClassification;

      Logger.info(logMessage);
    }
    Logger.saveLog();
  }
}
