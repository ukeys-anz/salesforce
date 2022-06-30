/**
 * @author Himabindu Nekkanti
 * @since  11/2020
 * @description IDRFilesRelatedListController provides the backend functionality with sosl search for IDRFilesRelatedList lwc
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class IDRFilesRelatedListController {
  /**
   * @description getCaseRelatedFiles returns all the files related to a case.
   * @param caseId the ID of the case for which files need to be returned
   * @return list<IDRFilesRelatedListdata>  , file details are retunred as a list of data class
   */
  @AuraEnabled
  public static list<IDRFilesRelatedListData> getCaseRelatedFiles(id caseId) {

    //if there are emails associated with this case. we need to get any documents
    //that are sent as attachment on the email.
    List<emailmessage> caseEmails = new List<emailmessage>();

    if (emailmessage.sObjectType.getDescribe().isQueryable()) {
      caseEmails = [SELECT Id FROM emailmessage WHERE ParentId = :caseId];
    }

    set<Id> linkedEntityIdList = new Set<Id>();
    linkedEntityIdList.add(caseId);

    for (emailmessage msg : caseEmails) {
      linkedEntityIdList.add(msg.Id);
    }

    list<contentDocumentLink> docList = new List<contentDocumentLink>();
    if (contentDocumentLink.sObjectType.getDescribe().isQueryable()) {
      docList = [
        SELECT
          ContentDocument.LatestPublishedVersion.Document_Flag__c,
          ContentDocument.title,
          ContentDocument.CreatedDate,
          ContentDocument.Owner.Name,
          ContentDocument.FileExtension,
          ContentDocument.LatestPublishedVersion.Date_of_Document__c,
          ContentDocument.LatestPublishedVersion.Party_who_sent_created_file__c,
          ContentDocument.LatestPublishedVersion.Document_Category__c,
          ContentDocumentId
        FROM contentDocumentLink
        WHERE LinkedEntityId IN :linkedEntityIdList
        ORDER BY
          ContentDocument.CreatedDate DESC,
          ContentDocument.title ASC,
          ContentDocument.FileExtension ASC
      ];
    }
    list<IDRFilesRelatedListData> tempDatalist = new List<IDRFilesRelatedListData>();
    string baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
    for (contentDocumentLink doc : docList) {
      IDRFilesRelatedListData tempData = new IDRFilesRelatedListData();
      tempData.fileUrl = baseUrl + '/' + doc.ContentDocumentId;
      tempData.fileName = doc.ContentDocument.title;
      tempData.fileType = doc.ContentDocument.FileExtension;
      tempData.createdDate = date.parse(
        doc.ContentDocument.CreatedDate.format('dd/MM/yyyy')
      );
      tempData.ownerName = doc.ContentDocument.Owner.Name;
      tempData.fileId = doc.ContentDocumentId;
      tempData.dateOfDocument = date.valueOf(
        doc.ContentDocument.LatestPublishedVersion.Date_of_Document__c
      );
      tempData.partyWhoSent = doc.ContentDocument.LatestPublishedVersion.Party_who_sent_created_file__c;
      tempData.documentType = doc.ContentDocument.LatestPublishedVersion.Document_Category__c;
      string flagString;
      if (
        !string.isBlank(
          doc.ContentDocument.LatestPublishedVersion.Document_Flag__c
        )
      ) {
        string[] flagList = doc.ContentDocument.LatestPublishedVersion.Document_Flag__c.split(
          '\\;'
        );
        for (string s : flagList) {
          if (string.isBlank(flagString)) {
            flagString = IDRFilesRelatedListController.getPicklistLabel(
              ContentVersion.Document_Flag__c,
              s
            );
          } else {
            flagString +=
              ';' +
              IDRFilesRelatedListController.getPicklistLabel(
                ContentVersion.Document_Flag__c,
                s
              );
          }
        }
      }
      tempData.flag = flagString;
      tempDatalist.add(tempData);
    }
    return tempDatalist;
  }
  /**
   * @description searchFilesContent performs an SOSL search with key words or phrase in the required list of documents
   * @param searchArray list of strings contains the search strings
   * @param validDocIdList list id's of contentdocuments with in which search needs to be performed
   * @return list<string>  , list of id's of documents that contain the search terms.
   * Note : Set cannot be passed to aura enabled methods hence list is used
   * also it is not possible to do search on document body alone hence search will be performed on all fields.
   */

  @AuraEnabled
  public static list<string> searchFilesContent(
    list<string> searchArray,
    List<Id> validDocIdList
  ) {
    //cant pass set to auraenabled methods.
    string searchString = '';
    boolean keyWordSearch = false;
    for (string key : searchArray) {
      key = String.escapeSingleQuotes(key);
      if (searchString.length() == 0) {
        searchString = Key;
      } else {
        keyWordSearch = true;
        searchString += ' AND ' + '"' + key + '"';
      }
    }

    if (!keyWordSearch) {
      searchString = '\'' + searchString + '*' + '\'';
    } else {
      searchString = '{' + searchString + '}';
    }

    string searchQuery =
      'FIND ' +
      searchString +
      ' IN All FIELDS RETURNING ContentDocument(id where Id in :validDocIdList)';
    List<List<SObject>> searchList = search.query(searchquery);
    list<string> returnValidDocList = new List<string>();
    for (List<SObject> sl : searchList) {
      list<ContentDocument> cdList = new List<ContentDocument>();
      cdList = (list<ContentDocument>) sl;
      for (ContentDocument cd : cdList) {
        returnValidDocList.add(cd.Id);
      }
    }
    return returnValidDocList;
  }
  /**
   * @description Get a picklist label from it's value (API_Key).
   * @param field The picklist field, for example Case.IDR_NC_State__c
   * @param picklistValue The picklist value, for example '2'
   * @return the picklist label, for example 'VIC'
   */
  @TestVisible
  private static String getPicklistLabel(
    Schema.SobjectField field,
    String picklistValue
  ) {
    Schema.DescribeFieldResult fieldPicklist = field.getDescribe();
    for (Schema.PicklistEntry f : fieldPicklist.getPicklistValues()) {
      if (f.getValue() == picklistValue) {
        return f.getLabel();
      }
    }
    return '';
  }
}
