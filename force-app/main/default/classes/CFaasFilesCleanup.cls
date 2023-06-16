/**
 * @author Karen Valeriano
 * @since November 2022
 * @description Used to delete CFaaS Files from ContentDocument, ContentVersion and ContentDocumentLink
 **/
public with sharing class CFaasFilesCleanup {
  private static final Id CFAAS_FILE_RT_ID = IDRConstants.CFAAS_FILE_RT_ID;

  /**
   * @description Method that will be invoked to start cleanup.
   * @param filesElapsedByHour Integer - elapsed time in hour of the files.
   * @param filesElapsedByMinutes Integer - elapsed time in minutes of the files.
   **/
  public static void processCleanup(
    Integer filesElapsedByHour,
    Integer filesElapsedByMinutes
  ) {
    Datetime dateTimeNow = Datetime.now();
    Datetime elapsedDatetime = dateTimeNow.addHours(-filesElapsedByHour)
      .addMinutes(-filesElapsedByMinutes);

    processCleanup(elapsedDatetime);
  }

  /**
   * @description Method that will be invoked to start cleanup.
   * @param filesElapsedByDate Datetime - Elapsed datetime.
   **/
  public static void processCleanup(Datetime filesElapsedByDate) {
    List<ContentDocument> listContentDocument = getDocuments(
      filesElapsedByDate
    );
    DMLUtil.deleteRecords(
      listContentDocument,
      DMLUtil.NOT_ALLOW_PARTIAL_UPDATE,
      DMLUtil.USER_MODE
    );
  }

  /**
   * @description Method that retrieves the ContentDocument records that elapsed.
   * @param elapsedDateTime Datetime - Elapsed datetime value.
   * @return List<ContentDocument>
   **/
  private static List<ContentDocument> getDocuments(Datetime elapsedDateTime) {
    //Skipping Field/Object check because this is a scheduled Admin job
    List<ContentDocument> listContentDocument = [
      SELECT
        Id,
        Title,
        Owner.Name,
        CreatedDate,
        CreatedBy.Name,
        LatestPublishedVersion.FirstPublishLocationId
      FROM ContentDocument
      WHERE
        Id IN (
          SELECT ContentDocumentId
          FROM ContentVersion
          WHERE RecordTypeId = :CFAAS_FILE_RT_ID
        )
        AND CreatedDate < :elapsedDatetime
    ];

    return listContentDocument;
  }

  /**
   * @description Method that deletes the elapsed files retrived
   * @param deleteResults List<Database.DeleteResult>> - The list of deleted results.
   **/
  private static void logResults(List<Database.DeleteResult> deleteResults) {
    List<Database.DeleteResult> deleteSuccess = new List<Database.DeleteResult>();
    List<Database.DeleteResult> deleteError = new List<Database.DeleteResult>();

    for (Database.DeleteResult result : deleteResults) {
      if (result.isSuccess()) {
        deleteSuccess.add(result);
      } else {
        deleteError.add(result);
      }
    }

    if (!deleteSuccess.isEmpty()) {
      Logger.info(
        'Files deleted successfully: ' + deleteSuccess.size(),
        deleteSuccess
      );
    }
    if (!deleteError.isEmpty()) {
      Logger.error('Files deletion failed: ' + deleteError.size(), deleteError);
    }
  }
}
