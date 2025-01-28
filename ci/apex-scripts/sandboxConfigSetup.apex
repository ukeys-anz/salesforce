//------- This is to create a document for omnistudio

// Find the VlocityDocumentUploads folder
// Find the VlocityLogoDocumentUploads ContentAsset
Folder f = [
  SELECT Id
  FROM Folder
  WHERE DeveloperName = 'VlocityDocumentUploads'
];
ContentAsset ca = [
  SELECT Id
  FROM ContentAsset
  WHERE DeveloperName = 'VlocityLogoDocumentUploads'
];

// Create a new Document in VlocityDocumentUploads folder using VlocityLogoDocumentUploads ContentAsset url.
Document d = new Document();
d.Name = 'VlocityLogoDocumentUploads';
d.FolderId = f.Id;
d.url =
  'https://test.salesforce.com/lightning/setup/ContentAssets/page?address=%2F' +
  ca.Id;

insert d;

//---- This is to update Aegis Custom Setting URL

String nonProdAegisURL = 'https://aegis-early-access.identity-services-sit-int-gw.apps-int.x.gcpnp.anz';

// Find the Aegis custom setting
List<Aegis_Env_Setting__c> aegisSetting = [
  SELECT Id, Name, Aegis_URL__c
  FROM Aegis_Env_Setting__c
  WHERE Name = 'AegisURL'
];
// If there is one, update the Aegis_URL__c
if (aegisSetting.size() > 0) {
  aegisSetting[0].Aegis_URL__c = nonProdAegisURL;
  aegisSetting[0].Env_Name__c = 'SIT';
  update aegisSetting[0];
  // Otherwise create a new one.
} else {
  Aegis_Env_Setting__c aegis = new Aegis_Env_Setting__c();
  aegis.Name = 'AegisURL';
  aegis.Aegis_URL__c = nonProdAegisURL;
  aegis.Env_Name__c = 'SIT';
  insert aegis;
}

//--- Add non-prod approvers to PAM Approvers Queue

// Find the sandbox name:
System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
String sandboxName = d.getSandboxName();

List<GroupMember> gms = new List<GroupMember>();
Group pamApproversQueue = [
  SELECT Id, Name
  FROM Group
  WHERE Name = 'PAM Approvers' AND type = 'Queue'
  LIMIT 1
];

// Add users to PAM approver Queue
List<String> npApproversUserNames = new List<String>{
  'victor.wang@anzx.com.' +
  sandboxName, // Qing Wang ( Victor )
  'mani.murugesan@anzx.com.' +
  sandboxName, // Manivasaga Vengatesh Murugesan
  'ngockieutrang.nguyen@anzx.com.' +
  sandboxName // Jasmine Nguyen
};
List<User> usrs = [
  SELECT Id, Username
  FROM User
  WHERE Username IN :npApproversUserNames
];

for (User u : usrs) {
  gms.add(
    new GroupMember(GroupId = pamApproversQueue.id, UserOrGroupId = u.id)
  );
}

insert gms;
System.debug(gms);
