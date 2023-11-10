/**
 * @author Peter Charalambous
 * @since Wed Nov 01 2023
 * @description test class for settlement trigger handler
 */
@isTest
public with sharing class SettlementTriggerHandlerTest {
  @TestSetup
  static void setup() {
    Faker faker = new Faker('AU');

    Account customer = TestDataFactory.createAccount(
      Faker.person.firstName(),
      true
    );
    ResidentialLoanApplication[] newRLA = new List<ResidentialLoanApplication>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      ResidentialLoanApplication rla = TestDataFactory.createTestResidentialLoanApplication(
        String.valueOf(i)
      );
      rla.AccountId = customer.Id;

      newRLA.add(rla);
    }
    insert newRLA;
    Settlement__c[] settlementList = new List<Settlement__c>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      Settlement__c settlement = TestDataFactory.createSettlement(newRLA[i].Id);
      settlementList.add(settlement);
    }

    insert settlementList;
  }

  @isTest
  static void testDefaultOwnerAssignment() {
    List<Settlement__c> settlementList = [
      SELECT Id, Owner_Name__c
      FROM Settlement__c
    ];
    for (Settlement__c settlement : settlementList) {
      Assert.areEqual(
        'Settlements Queue',
        settlement.Owner_Name__c,
        'Owner should be Settlements Queue'
      );
    }
  }
}
