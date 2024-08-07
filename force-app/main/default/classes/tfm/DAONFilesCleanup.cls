/**
 * @description       : Schedular class to delete DAON Record Type Files from Content Document/ Version
 * @author            : Anuj Jain - JOIN Squad
 * @group             :
 * @last modified on  : 07-15-2024
 * @last modified by  : Anuj Jain - JOIN Squad
 **/
public without sharing class DAONFilesCleanup {
  private static final IDOpsQueryRepository QUERY_REPOSITORY = (IDOpsQueryRepository) Lib_InstanceProvider.forType(
    IDOpsQueryRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Method that will be invoked to start cleanup.
   * @param filesElapsedByHour Integer - elapsed time in hour of the files.
   * @param filesElapsedByMinutes Integer - elapsed time in minutes of the files.
   **/
  public static void processCleanup(
    Integer filesElapsedByHour,
    Integer filesElapsedByMinutes
  ) {
    if(!QUERY_REPOSITORY.checkCustomPermission('DAONFileCleanup')) {
      Logger.info('User does not have permission to delete DAON Files');
      Logger.saveLog();
      return;
    }
    Datetime dateTimeNow = Datetime.now();
    Datetime elapsedDatetime = dateTimeNow.addHours(-filesElapsedByHour)
      .addMinutes(-filesElapsedByMinutes);

    processCleanup(elapsedDatetime);
  }

  /**
   * @description Method that will be invoked to start cleanup.
   * @param filesElapsedByDate Datetime - Elapsed datetime.
   **/
  @TestVisible
  private static void processCleanup(Datetime filesElapsedByDate) {
    List<ContentDocument> listContentDocument = QUERY_REPOSITORY.getContentDocumentsRecord(
      filesElapsedByDate
    );

    List<Database.DeleteResult> results = DML_REPOSITORY.deleteRecords(
      listContentDocument,
      DmlRepository.ALLOW_PARTIAL,
      DMLUtil.SYSTEM_MODE
    );
    Logger.error(
      'Error occured while updating deleting files.',
      results,
      Logger.Severity.HIGH
    );
    Logger.saveLog();
  }
}