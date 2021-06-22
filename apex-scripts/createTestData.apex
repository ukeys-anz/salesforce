/**
 *
 * @author Shermal Warnakula
 * @since 06/2021
 * @description Script to pre-load sample data while creating scratch orgs
 */
Id presonAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
  .get('PersonAccount')
  .getRecordTypeId();
Id generalEnquiryRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
  .get('General_Inquiry')
  .getRecordTypeId();
Id savingsRTId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName()
  .get('SavingsAccount')
  .getRecordTypeId();
Id checkingRTId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName()
  .get('CheckingAccount')
  .getRecordTypeId();

// Insert Person Accounts
List<Account> personAccounts = new List<Account>();
Account acc1 = new Account(
  FirstName = 'Sean',
  LastName = 'Fry',
  OCV_ID__c = '1987654OCV',
  ANZx_Customer__c = true,
  RecordTypeId = presonAccountRTId,
  External_Id__c = 'CAPSYS1987654OCV'
);
personAccounts.add(acc1);

Account acc2 = new Account(
  FirstName = 'Cameron',
  LastName = 'V',
  OCV_ID__c = '2987654OCV',
  ANZx_Customer__c = true,
  RecordTypeId = presonAccountRTId,
  External_Id__c = 'CAPSYS2987654OCV'
);
personAccounts.add(acc2);

Account acc3 = new Account(
  FirstName = 'Mcgowan',
  LastName = 'C',
  OCV_ID__c = '3987654OCV',
  ANZx_Customer__c = true,
  RecordTypeId = presonAccountRTId,
  External_Id__c = 'CAPSYS3987654OCV'
);
personAccounts.add(acc3);

insert personAccounts;

// Inserting General Enquiry Cases and Financial Accounts per Person Account
List<Case> caseList = new List<Case>();
List<FinServ__FinancialAccount__c> finAccList = new List<FinServ__FinancialAccount__c>();
for (Account acc : personAccounts) {
  // Create General Enquiry Cases
  Case geCase = new Case(
    AccountId = acc.Id,
    Type = 'Cards',
    Origin = 'Email',
    Status = 'Open',
    RecordTypeId = generalEnquiryRTId
  );
  caseList.add(geCase);

  // Create Savings Fin Accounts
  FinServ__FinancialAccount__c fin_acc_savings = new FinServ__FinancialAccount__c(
    Name = acc.FirstName + ' ' + acc.LastName,
    FinServ__FinancialAccountType__c = 'Savings',
    FinServ__PrimaryOwner__c = acc.Id,
    FinServ__FinancialAccountNumber__c = '111111111',
    FinServ__Status__c = 'Active',
    FinServ__Stage__c = 'Active',
    Primary_Owner_Start_Date__c = system.today(),
    Account_Key__c = acc.OCV_ID__c + 'SAVINGSKEY',
    FinServ__Balance__c = 598.99,
    FinServ__CurrentPostedBalance__c = 598.99,
    RecordTypeId = savingsRTId
  );
  finAccList.add(fin_acc_savings);

  // Create Checking/Transaction Fin Accounts
  FinServ__FinancialAccount__c fin_acc_checking = new FinServ__FinancialAccount__c(
    Name = acc.FirstName + ' ' + acc.LastName,
    FinServ__FinancialAccountType__c = 'Checking',
    FinServ__PrimaryOwner__c = acc.Id,
    FinServ__FinancialAccountNumber__c = '000000000',
    FinServ__Status__c = 'Active',
    FinServ__Stage__c = 'Active',
    Primary_Owner_Start_Date__c = system.today(),
    Account_Key__c = acc.OCV_ID__c + 'CHECKINGKEY',
    FinServ__Balance__c = 259.00,
    FinServ__CurrentPostedBalance__c = 259.00,
    RecordTypeId = checkingRTId
  );
  finAccList.add(fin_acc_checking);
}

insert caseList;
insert finAccList;
