//this script update OCV_Role__c for FinServ__ReciprocalRole__c records that have corresponding inverse role record
List<FinServ__ReciprocalRole__c> records = [
  SELECT Name
  FROM FinServ__ReciprocalRole__c
  WHERE
    OCV_Role__c = NULL
    OR RecordTypeId != :CCRMConstants.RECIPROCAL_CONTACT_ROLE_RT_ID
];
for (FinServ__ReciprocalRole__c record : records) {
  record.OCV_Role__c = record.Name;
  record.RecordTypeId = CCRMConstants.RECIPROCAL_CONTACT_ROLE_RT_ID;
}
update records;
