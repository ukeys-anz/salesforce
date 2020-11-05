/**
 * @author Himabindu Nekkanti
 * @since  11/2020
 * @description IDRFilesRelatedListController provides the backend functionality with sosl search for IDRFilesRelatedList lwc
 * 
 */

   /**
   * @description getCaseRelatedFiles returns all the files related to a case.
   * @param caseId the ID of the case for which files need to be returned
   * @return list<filesdata>  , file details are retunred as a list of data class
   */  
    @AuraEnabled
    public static list<IDRFilesRelatedListdata> getCaseRelatedFiles(id caseId){
        string filesDataString = '';
        
        list<contentDocumentLink> docList = new list<contentDocumentLink>();
        if (ContentDocument.sObjectType.getDescribe().isQueryable()) {
        docList = [select ContentDocument.title, ContentDocument.CreatedDate,
                   ContentDocument.Owner.Name,ContentDocument.FileExtension,ContentDocumentId
                   from contentDocumentLink where LinkedEntityId = :caseId];
        }
        list<IDRFilesRelatedListdata> tempDatalist = new list<IDRFilesRelatedListdata>();
        string baseUrl = URL.getSalesforceBaseUrl().toExternalForm() ;
        for(contentDocumentLink doc:docList){
            IDRFilesRelatedListdata tempData = new IDRFilesRelatedListdata();
          	tempData.fileUrl = baseUrl + '/' + doc.ContentDocumentId;
            tempData.fileName = doc.ContentDocument.title;
            tempData.fileType = doc.ContentDocument.FileExtension;
            tempData.createdDate = date.valueOf(doc.ContentDocument.CreatedDate);
            tempData.ownerName = doc.ContentDocument.Owner.Name;
            tempData.fileId = doc.ContentDocumentId;
            tempDatalist.add(tempData);
        }
        //filesDataString = json.serialize(fileslist);
		//system.debug('result:'+filesDataString)
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
    public static list<string> searchFilesContent(list<string> searchArray,List<Id> validDocIdList){
        //cant pass set to auraenabled methods.
        string searchString = '';
        boolean keyWordSearch = false;
        for(string key : searchArray){
            if(searchString.length() == 0){
                searchString = Key;
            }else{
             keyWordSearch = true;
             searchString += ' AND '+ '"'+ key + '"';        
            }       
        }
        
        if (!keyWordSearch){
            searchString = '\''+ searchString + '*'+ '\'';
        }else{
            searchString = '{' + searchString + '}';
        }

        string searchQuery = 'FIND '+  searchString + ' IN All FIELDS RETURNING ContentDocument(id where Id in :validDocIdList)';
        List<List<SObject>>searchList=search.query(searchquery);
        list<string> returnValidDocList = new list<string>();
        for(List<SObject> sl :searchList){
            list<ContentDocument> cdList = new list<ContentDocument>();
            cdList = (list<ContentDocument>)sl;
            for (ContentDocument cd : cdList){
                returnValidDocList.add(cd.Id);
            }               
         } 
        return returnValidDocList;	 
    }
   
}