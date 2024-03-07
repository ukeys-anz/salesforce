List<FinServ__ReciprocalRole__c> newRoles = new List<FinServ__ReciprocalRole__c>{
  new FinServ__ReciprocalRole__c(
    Name = 'Managing Director',
    OCV_Role__c = 'Managing Director',
    FinServ__InverseRole__c = 'Managing Director',
    Role_Description__c = 'CAP Rel Code - MAN',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'Unknown',
    OCV_Role__c = 'Unknown',
    FinServ__InverseRole__c = 'Unknown',
    Role_Description__c = 'When source value cannot be mapped to any other value in this table',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'CLG Contact Business',
    OCV_Role__c = 'CLG Contact Business',
    FinServ__InverseRole__c = 'CLG Contact Business',
    Role_Description__c = 'CAP Rel Code - KCB',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'Manager',
    OCV_Role__c = 'Manager',
    FinServ__InverseRole__c = 'Manager',
    Role_Description__c = 'CAP Rel Code - MGR',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'Authorised User',
    OCV_Role__c = 'Authorised User',
    FinServ__InverseRole__c = 'Authorised User',
    Role_Description__c = 'Party is an authorised user of systems on behalf of another Party',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'CLG Contact Consumer',
    OCV_Role__c = 'CLG Contact Consumer',
    FinServ__InverseRole__c = 'CLG Contact Consumer',
    Role_Description__c = 'CAP Rel Code - KCC',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'Partner',
    OCV_Role__c = 'Partner',
    FinServ__InverseRole__c = 'Partner',
    Role_Description__c = 'CAP Rel Code - PTR',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'SUB AGGREGATOR TO',
    OCV_Role__c = 'SUB AGGREGATOR TO',
    FinServ__InverseRole__c = 'AGGREGATOR',
    Role_Description__c = 'Relationship between an Originator and a Sub-Originator in the context of brokers',
    FinServ__CreateInverseRole__c = true,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'Also Known As',
    OCV_Role__c = 'Also Known As',
    FinServ__InverseRole__c = 'Also Known As',
    Role_Description__c = 'CAP Rel Code - AKA',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'Spouse',
    OCV_Role__c = 'Spouse',
    FinServ__InverseRole__c = 'Spouse',
    Role_Description__c = 'CAP Rel Code - SPS',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'Customer Group',
    OCV_Role__c = 'Customer Group',
    FinServ__InverseRole__c = 'Customer Group',
    Role_Description__c = 'CAP Rel Code - CGP',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'Trading As',
    OCV_Role__c = 'Trading As',
    FinServ__InverseRole__c = 'Trading As',
    Role_Description__c = 'CAP Rel Code - T/A',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'Treasurer',
    OCV_Role__c = 'Treasurer',
    FinServ__InverseRole__c = 'Treasurer',
    Role_Description__c = 'CAP Rel Code - TSR',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'Business Card Billing Group',
    OCV_Role__c = 'Business Card Billing Group',
    FinServ__InverseRole__c = 'Business Card Billing Group',
    Role_Description__c = 'CAP REL CODE - BCG',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'Director',
    OCV_Role__c = 'Director',
    FinServ__InverseRole__c = 'Director',
    Role_Description__c = 'CAP Rel Code - DIR',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'Related Customer',
    OCV_Role__c = 'Related Customer',
    FinServ__InverseRole__c = 'Related Customer',
    Role_Description__c = 'CAP Rel Code - REL',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'CLG Contact All',
    OCV_Role__c = 'CLG Contact All',
    FinServ__InverseRole__c = 'CLG Contact All',
    Role_Description__c = 'CAP Rel Code - KCA',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'Subsidiary Organisation',
    OCV_Role__c = 'Subsidiary Organisation',
    FinServ__InverseRole__c = 'Subsidiary Organisation Owner',
    Role_Description__c = 'CAP Rel Code - SBI-SBO',
    FinServ__CreateInverseRole__c = true,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'Chairman',
    OCV_Role__c = 'Chairman',
    FinServ__InverseRole__c = 'Chairman',
    Role_Description__c = 'CAP Rel Code - CHR',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'Customer Lending Group',
    OCV_Role__c = 'Customer Lending Group',
    FinServ__InverseRole__c = 'Customer Lending Group',
    Role_Description__c = 'CAP Rel Code - CLG',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'Secretary',
    OCV_Role__c = 'Secretary',
    FinServ__InverseRole__c = 'Secretary',
    Role_Description__c = 'CAP Rel Code - SEC',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  )
};
insert newRoles;

//update auto-generated inverse role
List<FinServ__ReciprocalRole__c> records = [
  SELECT Name
  FROM FinServ__ReciprocalRole__c
  WHERE FinServ__InverseRelationship__c IN :newRoles
];
for (FinServ__ReciprocalRole__c record : records) {
  record.OCV_Role__c = record.Name;
}
update records;
