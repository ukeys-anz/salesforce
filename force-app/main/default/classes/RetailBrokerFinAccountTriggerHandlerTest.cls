/**
 * @author Nakul
 * @since  01/2025
 * @description  Test class for RetailBrokerFinAccountTriggerHandler
 */

@IsTest
public with sharing class RetailBrokerFinAccountTriggerHandlerTest {
  /**
   * @description creating Financial Account records for testing
   * @param recordTypeId Financial Account record id
   * @return Financial Account Records
   */
  static List<FinServ__FinancialAccount__c> createFinancialAccounts(
    String recordTypeId
  ) {
    String prefix = String.valueOf(Datetime.now().getTime());
    List<FinServ__FinancialAccount__c> financialAccounts = new List<FinServ__FinancialAccount__c>();
    for (Integer counter = 0; counter < 3; counter++) {
      FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c();
      financialAccount.RecordTypeId = recordTypeId;
      if (counter == 0) {
        financialAccount.Marketing_Code__c = 'HLVAR01';
      } else if (counter == 1) {
        financialAccount.Marketing_Code__c = 'HLFXD01';
      } else {
        financialAccount.Marketing_Code__c = 'MCODE007';
      }
      financialAccount.Assisted_Broker_TPMI_SAO__c = 'TPMI' + prefix + counter;
      financialAccounts.add(financialAccount);
    }
    return financialAccounts;
  }

  /**
   * @description test function to test RetailBrokerFinAccountTriggerHandler.isValidRecord
   * Assertion is made against the return value of the function provided with the financial account record as the parameter
   * The test tests both the scenarios, the positive as well as the negative
   */
  @IsTest
  static void testValidContractEventRecords() {
    List<FinServ__FinancialAccount__c> financialAccounts = createFinancialAccounts(
      RTFinancialAccount.bankAccount
    );
    RetailBrokerFinAccountTriggerHandler retailBrokerFinAccountTriggerHandler = new RetailBrokerFinAccountTriggerHandler();
    Assert.areEqual(
      true,
      retailBrokerFinAccountTriggerHandler.isValidRecord(financialAccounts[0]),
      'Should be a valid record!'
    );
    Assert.areEqual(
      true,
      retailBrokerFinAccountTriggerHandler.isValidRecord(financialAccounts[1]),
      'Should be a valid record!'
    );
    Assert.areEqual(
      false,
      retailBrokerFinAccountTriggerHandler.isValidRecord(financialAccounts[2]),
      'Should be an invalid record!'
    );
  }
}
