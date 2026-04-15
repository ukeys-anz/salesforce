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
    additionalDetails.put('fromDate', '2025-09-15');
    additionalDetails.put('toDate', '2025-09-30');
    additionalDetails.put('statementType', 'Home Loan');
    additionalDetails.put('contextType', 'Statements');
    additionalDetails.put('documentType', 'ANZ Test Product');
    additionalDetails.put('issueDate', '2025-09-15');
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
