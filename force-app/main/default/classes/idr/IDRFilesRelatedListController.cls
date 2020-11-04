public class IDRFilesRelatedListController {
    public class filesdata{
       	@AuraEnabled
        public string fileUrl;
        @AuraEnabled
        public string fileName;
        @AuraEnabled
        public string fileType ;
        @AuraEnabled 
        public date  createdDate;
        @AuraEnabled
        public string OwnerName;
        @AuraEnabled
        public string contentData; 
        @AuraEnabled
        public string fileId;
    }
    
    @AuraEnabled
    public static list<filesdata> getCaseRelatedFiles(id caseId){
        string filesDataString = '';
        
        list<contentDocumentLink> docList = new list<contentDocumentLink>();
        docList = [select ContentDocument.title, ContentDocument.CreatedDate,
                   ContentDocument.Owner.Name,ContentDocument.FileExtension,ContentDocumentId
                   from contentDocumentLink where LinkedEntityId = :caseId];
        list<filesdata> tempDatalist = new list<filesdata>();
        string baseUrl = URL.getSalesforceBaseUrl().toExternalForm() ;
        for(contentDocumentLink doc:docList){
           filesdata tempData = new filesdata();
          	tempData.fileUrl = baseUrl + '/' + doc.ContentDocumentId;
            tempData.fileName = doc.ContentDocument.title;
            tempData.fileType = doc.ContentDocument.FileExtension;
            tempData.createdDate = date.valueOf(doc.ContentDocument.CreatedDate);
            tempData.OwnerName = doc.ContentDocument.Owner.Name;
            tempData.fileId = doc.ContentDocumentId;
            tempDatalist.add(tempData);
        }
        //filesDataString = json.serialize(fileslist);
		//system.debug('result:'+filesDataString)
        return tempDatalist;
    }
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