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

List<Account> personAccounts = new List<Account>();

// Insert Random Person Accounts
for (Integer i = 0; i < personAccount_count; i++) {
  Account acc = new Account(
    FirstName = faker.person.firstName(),
    LastName = faker.person.lastName(),
    OCV_ID__c = faker.randomString(10) + String.valueOf(i),
    ANZx_Customer__c = true,
    RecordTypeId = presonAccountRTId,
    External_Id__c = faker.randomString(15) + String.valueOf(i),
    PPID__C = faker.randomString(34)
  );
  personAccounts.add(acc);
}

// Update/Overwrite a Person Account to match Mock Data
personAccounts[0].FirstName = 'GRIMES';
personAccounts[0].LastName = 'MITCH';

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
  Integer savingAccBalance = Integer.valueOf(faker.randomDecimal(5, 2));

  FinServ__FinancialAccount__c fin_acc_savings = new FinServ__FinancialAccount__c(
    Name = acc.FirstName + ' ' + acc.LastName,
    FinServ__FinancialAccountType__c = 'Savings',
    FinServ__PrimaryOwner__c = acc.Id,
    FinServ__FinancialAccountNumber__c = String.valueOf(faker.randomInteger(9)),
    FinServ__Status__c = 'Active',
    FinServ__Stage__c = 'Active',
    Primary_Owner_Start_Date__c = System.today(),
    Account_Key__c = acc.OCV_ID__c + faker.randomString(5),
    FinServ__Balance__c = savingAccBalance,
    FinServ__CurrentPostedBalance__c = savingAccBalance,
    RecordTypeId = savingsRTId
  );
  finAccList.add(fin_acc_savings);

  // Create Checking/Transaction Fin Accounts
  Integer bankBalance = Integer.valueOf(faker.randomDecimal(3, 2));

  FinServ__FinancialAccount__c fin_acc_checking = new FinServ__FinancialAccount__c(
    Name = acc.FirstName + ' ' + acc.LastName,
    FinServ__FinancialAccountType__c = 'Checking',
    FinServ__PrimaryOwner__c = acc.Id,
    FinServ__FinancialAccountNumber__c = String.valueOf(faker.randomInteger(9)),
    FinServ__Status__c = 'Active',
    FinServ__Stage__c = 'Active',
    Primary_Owner_Start_Date__c = System.today(),
    Account_Key__c = acc.OCV_ID__c + faker.randomString(6),
    FinServ__Balance__c = bankBalance,
    FinServ__CurrentPostedBalance__c = bankBalance,
    RecordTypeId = checkingRTId
  );
  finAccList.add(fin_acc_checking);
}

insert caseList;

// Update/Overwrite accounts to match Mock Data so acc & BSB match
// Savings Account
finAccList[0].FinServ__FinancialAccountNumber__c = '111111111';
finAccList[0].BSB__c = '014111';
finAccList[0].FinServ__Balance__c = 89.00;
finAccList[0].FinServ__CurrentPostedBalance__c = 89.00;

// Tx Account
finAccList[1].FinServ__FinancialAccountNumber__c = '000000000';
finAccList[1].BSB__c = '014111';
finAccList[1].FinServ__Balance__c = 18.00;
finAccList[1].FinServ__CurrentPostedBalance__c = 18.00;

insert finAccList;
