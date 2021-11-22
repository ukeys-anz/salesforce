/**
 * @author Chiranjeeb Dhar
 * @since October 2021
 * @description Test class for statement model
 */
@isTest
public with sharing class StatementModelTest {
  @isTest
  public static void testListStatement() {
    StaticResource sr = [
      SELECT body
      FROM StaticResource
      WHERE Name = 'mock_statement'
    ];
    StatementModel obj = StatementModel.parse(sr.body.toString());
    System.assert(obj.statements != null);
    System.assert(obj.statements.size() == 4);
  }
  @isTest
  public static void testStatementUrl() {
    StaticResource sr = [
      SELECT body
      FROM StaticResource
      WHERE Name = 'mock_statementUrl'
    ];
    StatementModel obj = StatementModel.parse(sr.body.toString());
    System.assert(obj.statement != null);
    System.assert(obj.statement.url != null);
  }
}
