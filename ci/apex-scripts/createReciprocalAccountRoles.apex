// List of new Roles instances
List<FinServ__ReciprocalRole__c> newRolesList = new List<FinServ__ReciprocalRole__c>{
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
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Signatory',
    OCV_Role__c = 'KYC-Signatory',
    FinServ__InverseRole__c = 'KYC-Signatory',
    Role_Description__c = 'Siebel Relation Role - Signatory',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Senior Managing Official',
    OCV_Role__c = 'KYC-Senior Managing Official',
    FinServ__InverseRole__c = 'KYC-Senior Managing Official',
    Role_Description__c = 'Siebel Relation Role - Senior Managing Official',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Intermediate BO',
    OCV_Role__c = 'KYC-Intermediate BO',
    FinServ__InverseRole__c = 'KYC-Intermediate BO',
    Role_Description__c = 'Siebel Relation Role - Intermediate BO',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Partner',
    OCV_Role__c = 'KYC-Partner',
    FinServ__InverseRole__c = 'KYC-Partner',
    Role_Description__c = 'Siebel Relation Role - Partner',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Local Representative',
    OCV_Role__c = 'KYC-Local Representative',
    FinServ__InverseRole__c = 'KYC-Local Representative',
    Role_Description__c = 'Siebel Relation Role - Local Representative',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Beneficiary',
    OCV_Role__c = 'KYC-Beneficiary',
    FinServ__InverseRole__c = 'KYC-Beneficiary',
    Role_Description__c = 'Siebel Relation Role - Beneficiary',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Third Party Signatory',
    OCV_Role__c = 'KYC-Third Party Signatory',
    FinServ__InverseRole__c = 'KYC-Third Party Signatory',
    Role_Description__c = 'Siebel Relation Role - Third Party Signatory',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Power of Attorney',
    OCV_Role__c = 'KYC-Power of Attorney',
    FinServ__InverseRole__c = 'KYC-Power of Attorney',
    Role_Description__c = 'Siebel Relation Role - Power of Attorney',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Controlling Person - Other',
    OCV_Role__c = 'KYC-Controlling Person - Other',
    FinServ__InverseRole__c = 'KYC-Controlling Person - Other',
    Role_Description__c = 'Siebel Relation Role - Controlling Person - Other',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Settlor',
    OCV_Role__c = 'KYC-Settlor',
    FinServ__InverseRole__c = 'KYC-Settlor',
    Role_Description__c = 'Siebel Relation Role - Settlor',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Trading Name',
    OCV_Role__c = 'KYC-Trading Name',
    FinServ__InverseRole__c = 'KYC-Trading Name',
    Role_Description__c = ' Siebel Relation Role - Trading Name',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Trustee',
    OCV_Role__c = 'KYC-Trustee',
    FinServ__InverseRole__c = 'KYC-Trustee',
    Role_Description__c = 'Siebel Relation Role - Trustee',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-President or Equivalent',
    OCV_Role__c = 'KYC-President or Equivalent',
    FinServ__InverseRole__c = 'KYC-President or Equivalent',
    Role_Description__c = 'Siebel Relation Role - President or Equivalent',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Treasurer or Equivalent',
    OCV_Role__c = 'KYC-Treasurer or Equivalent',
    FinServ__InverseRole__c = 'KYC-Treasurer or Equivalent',
    Role_Description__c = 'Siebel Relation Role - Treasurer or Equivalent',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Director',
    OCV_Role__c = 'KYC-Director',
    FinServ__InverseRole__c = 'KYC-Director',
    Role_Description__c = 'Siebel Relation Role - Director',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Chairman or Equivalent',
    OCV_Role__c = 'KYC-Chairman or Equivalent',
    FinServ__InverseRole__c = 'KYC-Chairman or Equivalent',
    Role_Description__c = 'Siebel Relation Role - Chairman or Equivalent',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Fund Manager',
    OCV_Role__c = 'KYC-Fund Manager',
    FinServ__InverseRole__c = 'KYC-Fund Manager',
    Role_Description__c = 'Siebel Relation Role - Fund Manager',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Verifying Officer',
    OCV_Role__c = 'KYC-Verifying Officer',
    FinServ__InverseRole__c = 'KYC-Verifying Officer',
    Role_Description__c = 'Siebel Relation Role - Verifying Officer',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Beneficial Owner',
    OCV_Role__c = 'KYC-Beneficial Owner',
    FinServ__InverseRole__c = 'KYC-Beneficial Owner',
    Role_Description__c = 'Siebel Relation Role - Beneficial Owner',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Secretary or Equivalent',
    OCV_Role__c = 'KYC-Secretary or Equivalent',
    FinServ__InverseRole__c = 'KYC-Secretary or Equivalent',
    Role_Description__c = 'Siebel Relation Role - Secretary or Equivalent',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Member - Account Holder',
    OCV_Role__c = 'KYC-Member - Account Holder',
    FinServ__InverseRole__c = 'KYC-Member - Account Holder',
    Role_Description__c = 'Siebel Relation Role - Member - Account Holder',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-VO Signatory',
    OCV_Role__c = 'KYC-VO Signatory',
    FinServ__InverseRole__c = 'KYC-VO Signatory',
    Role_Description__c = 'Siebel Relation Role - VO Signatory',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  ),
  new FinServ__ReciprocalRole__c(
    Name = 'KYC-Managing Agent',
    OCV_Role__c = 'KYC-Managing Agent',
    FinServ__InverseRole__c = 'KYC-Managing Agent',
    Role_Description__c = 'Siebel Relation Role - Managing Agent',
    FinServ__CreateInverseRole__c = false,
    RecordTypeId = CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
  )
};
// Set of New Role Names
Set<String> newRolesNameSet = new Set<String>();
for (FinServ__ReciprocalRole__c newRole : newRolesList) {
  newRolesNameSet.add(newRole.Name);
}

// Get Existing Roles From Org
List<FinServ__ReciprocalRole__c> Existingrecords = [
  SELECT
    Name,
    OCV_Role__c,
    FinServ__InverseRole__c,
    Role_Description__c,
    FinServ__CreateInverseRole__c,
    RecordTypeId
  FROM FinServ__ReciprocalRole__c
  WHERE
    name IN :newRolesNameSet
    AND RecordTypeId = :CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
];

// Set of Existing Role Names
Set<String> exstRoleNameSet = new Set<String>();
for (FinServ__ReciprocalRole__c currRole : Existingrecords) {
  exstRoleNameSet.add(currRole.name);
}

// Ignore Existing Roles and Create List of New Roles to Be Inserted
List<FinServ__ReciprocalRole__c> lstOfRolesToBeInserted = new List<FinServ__ReciprocalRole__c>();
for (FinServ__ReciprocalRole__c newRole : newRolesList) {
  if (!exstRoleNameSet.contains(newRole.name)) {
    lstOfRolesToBeInserted.add(newRole);
  }
}
// Insert New Roles
insert lstOfRolesToBeInserted;

//update auto-generated inverse role
List<FinServ__ReciprocalRole__c> records = [
  SELECT Name
  FROM FinServ__ReciprocalRole__c
  WHERE
    FinServ__InverseRelationship__c IN :lstOfRolesToBeInserted
    AND RecordTypeId = :CCRMConstants.RECIPROCAL_ACCOUNT_ROLE_RT_ID
];
for (FinServ__ReciprocalRole__c record : records) {
  record.OCV_Role__c = record.Name;
}
update records;
