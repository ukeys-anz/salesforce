/**
 * @author Vidhya Raghavan
 * @since March 2023
 * @description Test class for statement access model
 */

@isTest
public with sharing class StatementAccessModelTest {
  @isTest
  public static void testListStatement() {
    Map<String, String> additionalDetails = new Map<String, String>();
    additionalDetails.put('accountId', 'test1234');
    additionalDetails.put('financialAccountId', 'test1234');
    additionalDetails.put('fromDate', '05042023');
    additionalDetails.put('toDate', '30042023');
    additionalDetails.put('statementType', 'Home Loan');
    additionalDetails.put('sUID', userinfo.getUserId());
    Test.startTest();
    StatementAccessModel st = StatementAPIRepository.createStatementAccessModel(
      additionalDetails
    );
    String result = json.serialize(st);
    Test.stopTest();
    System.assert(
      result != null,
      'logging values should not be equal to null.'
    );
  }
}
