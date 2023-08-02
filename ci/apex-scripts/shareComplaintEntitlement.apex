Entitlement complaintEntitlement = [
  SELECT Id, AccountId
  FROM Entitlement
  WHERE
    SlaProcess.Name = 'complaints'
    AND Account.Name = 'Complaint Entitlement Account'
];
Group anzRoleAndSubordinates = [
  SELECT Id
  FROM Group
  WHERE DeveloperName = 'ANZ' AND Type = 'RoleAndSubordinates'
];
AccountShare share = new AccountShare();
share.AccountId = complaintEntitlement.AccountId;
share.UserOrGroupId = anzRoleAndSubordinates.Id;
share.AccountAccessLevel = 'Read';
share.OpportunityAccessLevel = 'None';
share.ContactAccessLevel = 'None';
share.CaseAccessLevel = 'None';
insert share;
