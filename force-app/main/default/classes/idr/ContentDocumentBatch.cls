/**
 * @author Greg Shaw (shawg2)
 * @since 06/2022
 * @description  ContentDocumentBatch is designed to summarise all ContentDocument records added to a Case after Case closure.
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class ContentDocumentBatch implements Database.Batchable<sObject>, Database.Stateful {
  public List<String> lstOutputLines = new List<String>{
    '"Case ID",' +
    '"Case Status",' +
    '"Date Closed",' +
    '"File Name",' +
    '"Created Date",' +
    '"Party who sent/created file",' +
    '"Document Flag",' +
    '"Document Category",' +
    '"Owner",' +
    '"File Type"'
  };

  /**
   * @description Return a QueryLocator for All Closed Cases
   * @param param1 BatchableContext ignored
   *
   * @return All Closed Cases
   */
  public Database.QueryLocator start(Database.BatchableContext param1) {
    return Database.getQueryLocator(
      'SELECT Id, CaseNumber, CreatedBy.Name, IsClosed, Status, ClosedDate' +
      ' FROM Case' +
      ' WHERE IsClosed = true'
    );
  }

  /**
   * @description Process a batch of Cases. Find all ContentDocumentLink records created after the Case was closed.
   * @param param1 BatchableContext ignored
   * @param lstCases List of Cases for scope
   */
  public void execute(Database.BatchableContext param1, List<Case> lstCases) {
    Map<Id, Datetime> mpCaseId2ClosedDate = new Map<Id, Datetime>();
    Map<Id, List<ContentDocumentLink>> mpCaseId2Documents = new Map<Id, List<ContentDocumentLink>>();

    for (Case oCase : lstCases) {
      mpCaseId2ClosedDate.put(oCase.Id, oCase.ClosedDate);
    }
    if (mpCaseId2ClosedDate.size() > 0) {
      List<ContentDocumentLink> lstContentDocuments;
      for (ContentDocumentLink cdlObject : [
        SELECT
          Id,
          LinkedEntityId,
          ContentDocumentId,
          SystemModstamp,
          ContentDocument.Title,
          ContentDocument.CreatedDate,
          ContentDocument.CreatedBy.Name,
          ContentDocument.Owner.Name,
          ContentDocument.FileType
        FROM ContentDocumentLink
        WHERE LinkedEntityId IN :mpCaseId2ClosedDate.keyset()
      ]) {
        if (
          cdlObject.SystemModstamp >
          mpCaseId2ClosedDate.get(cdlObject.LinkedEntityId)
        ) {
          if (
            (lstContentDocuments = mpCaseId2Documents.get(
              cdlObject.LinkedEntityId
            )) == null
          ) {
            lstContentDocuments = new List<ContentDocumentLink>();
            mpCaseId2Documents.put(
              cdlObject.LinkedEntityId,
              lstContentDocuments
            );
          }
          lstContentDocuments.add(cdlObject);
        }
      }
      buildCSV(lstCases, mpCaseId2Documents);
    }
  }

  /**
   * @description Take documents and add CSV lines
   * @param lstCases original scope List of Cases
   * @param mpCaseId2Documents ContentDocumentLink records arranged by CaseId
   */
  private void buildCSV(List<Case> lstCases, Map<Id, List<ContentDocumentLink>> mpCaseId2Documents) {
    Map<Id, Case> mpCaseId2Case = new Map<Id, Case>();
    for (Case oCase : lstCases) {
      if (mpCaseId2Documents.containsKey(oCase.Id)) {
        mpCaseId2Case.put(oCase.Id, oCase);
      }
    }
    Case oCase2;
    List<ContentDocumentLink> lstContentDocuments;
    for (Id idCase : mpCaseId2Documents.keySet()) {
      oCase2 = mpCaseId2Case.get(idCase);
      lstContentDocuments = mpCaseId2Documents.get(idCase);
      for (ContentDocumentLink oLink : lstContentDocuments) {
        lstOutputLines.add(
                oCase2.CaseNumber +
                        ',' +
                        oCase2.Status +
                        ',"' +
                        oCase2.ClosedDate +
                        '","' +
                        oLink.ContentDocument.Title +
                        '"' +
                        ',"' +
                        oLink.ContentDocument.CreatedDate +
                        '","' +
                        oLink.ContentDocument.CreatedBy.Name +
                        '"' +
                        ',,,"' +
                        oLink.ContentDocument.Owner.Name +
                        '","' +
                        oLink.ContentDocument.FileType +
                        '"'
        );
      }
    }
  }
  /**
   * @description Output the csv lines accumulated from all batches.
   * @param param1 BatchableContext ignored
   */
  public void finish(Database.BatchableContext param1) {
    System.debug(LoggingLevel.INFO, String.join(lstOutputLines, '\n'));
  }
}
