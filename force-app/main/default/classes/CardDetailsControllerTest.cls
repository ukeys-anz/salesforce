@isTest
public with sharing class CardDetailsControllerTest {
  @isTest
  public static void testCardRetrieval() {
    Faker faker = new Faker('AU');

    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.OCV_ID__c = faker.randomString(10);
    accnt.ANZx_Customer__c = true;
    accnt.External_Id__c = '82jfsa80534';
    insert accnt;

    FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c();
    finAccount.Name = 'Test Account';
    finAccount.FinServ__Balance__c = faker.randomIntegerBetween(1, 400);
    finAccount.FinServ__CurrentPostedBalance__c = faker.randomIntegerBetween(
      1,
      400
    );
    finAccount.FinServ__Status__c = 'Open';
    finAccount.FinServ__FinancialAccountType__c = 'Checking';
    finAccount.FinServ__PrimaryOwner__c = accnt.Id;
    finAccount.Account_Key__c = '342490981';
    finAccount.Primary_Owner_Start_Date__c = Date.valueOf('2021-02-11');
    insert finAccount;

    FinServ__Card__c card = new FinServ__Card__c();
    card.Name = 'Test Card';
    card.FinServ__AccountHolder__c = accnt.Id;
    card.FinServ__FinancialAccount__c = finAccount.Id;
    insert card;

    Test.startTest();

    List<FinServ__Card__c> cardList = CardDetailsController.getCardDetails(
      card.Id
    );

    System.assertEquals(
      1,
      cardList.size(),
      'Card list size should be as expected.'
    );

    Test.stopTest();
  }
}
