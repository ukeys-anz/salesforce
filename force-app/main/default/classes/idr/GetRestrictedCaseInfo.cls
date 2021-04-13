public without sharing class GetRestrictedCaseInfo {
  @AuraEnabled(cacheable=true)
  public static List<Case> getRestrictedCaseData(
    String searchKey,
    String sortBy,
    String sortDirection
  ) {
    String query = 'SELECT Id, CaseNumber, Status, IDR_Customer_Number__c, IDR_Complainant_Type__c, IDR_NC_First_Name__c, IDR_NC_Last_Name__c, OwnerId, Owner.Name  FROM Case';
    system.debug('query---' + query);
    if (String.isNotBlank(searchKey)) {
      String key = '%' + searchKey + '%';
      String status = 'Escalated';
      List<String> restrictList = new List<String>{
        'Highly Sensitive',
        'CRP Managed'
      };
      query += ' WHERE IDR_Restriction_Level__C IN: restrictList AND (CaseNumber LIKE :key OR Status LIKE :key OR IDR_Customer_Number__c LIKE :key OR IDR_Complainant_Type__c LIKE :key OR IDR_NC_First_Name__c LIKE :key OR IDR_NC_Last_Name__c LIKE :key) ORDER BY LastModifiedDate Desc';
    }
    if (sortBy != null && sortDirection != null) {
      query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
    }
    return Database.query(query);
  }
}