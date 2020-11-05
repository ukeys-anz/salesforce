/**
 * @author Himabindu Nekkanti
 * @since  11/2020
 * @description data class used to return data to LWC
 * 
 */
public class IDRFilesRelatedListData {
        @AuraEnabled
        public string fileUrl;
        @AuraEnabled
        public string fileName;
        @AuraEnabled
        public string fileType ;
        @AuraEnabled 
        public date  createdDate;
        @AuraEnabled
        public string ownerName;
        @AuraEnabled
        public string contentData; 
        @AuraEnabled
        public string fileId;
}