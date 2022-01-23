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

Faker faker = new Faker('AU');
Integer personAccount_count = 3;

// Insert Person Accounts
List<Account> personAccounts = new List<Account>();
for (Integer i = 0; i < personAccount_count; i++) {
  Account acc = new Account(
    FirstName = faker.person.firstName(),
    LastName = faker.person.lastName(),
    OCV_ID__c = faker.randomString(10) + String.valueOf(i),
    ANZx_Customer__c = true,
    RecordTypeId = presonAccountRTId,
    External_Id__c = faker.randomString(15) + String.valueOf(i),
    PPID__C = 'CHc6ad9b34eb3e4788a12eb1caa07aefd5'
  );
  personAccounts.add(acc);
}
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
    Account_Key__c = acc.OCV_ID__c + faker.randomString(5),
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
    Account_Key__c = acc.OCV_ID__c + faker.randomString(6),
    FinServ__Balance__c = 259.00,
    FinServ__CurrentPostedBalance__c = 259.00,
    RecordTypeId = checkingRTId
  );
  finAccList.add(fin_acc_checking);
}

insert caseList;
insert finAccList;
