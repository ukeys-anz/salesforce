Financial_Account_Settings__c faSettings = Financial_Account_Settings__c.getOrgDefaults();
List<Account> acclist = [
  SELECT Id
  FROM ACCOUNT
  WHERE Name = 'System Customer'
  LIMIT 1
];
if (
  String.isBlank(faSettings.System_Customer_Id__c) ||
  acclist.isEmpty() ||
  acclist[0].Id != faSettings.System_Customer_Id__c
) {
  Faker faker = new Faker('AU');
  Account acc = new Account(
    Name = 'System Customer',
    OCV_ID__c = 'system-customer-' + faker.randomString(10),
    ANZx_Customer__c = true,
    RecordTypeId = CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID
  );
  insert acc;

  faSettings.System_Customer_Id__c = acc.Id;
  upsert faSettings;
}
