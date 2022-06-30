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
    System.assert(
      obj.statements != null,
      'Object statements should not be empty.'
    );
    System.assert(
      obj.statements.size() == 4,
      'Object statements size should as expected.'
    );
  }
  @isTest
  public static void testStatementUrl() {
    StaticResource sr = [
      SELECT body
      FROM StaticResource
      WHERE Name = 'mock_statementUrl'
    ];
    StatementModel obj = StatementModel.parse(sr.body.toString());
    System.assert(
      obj.statement != null,
      'Object statements should not be empty.'
    );
    System.assert(
      obj.statement.url != null,
      'Object statement url should not be empty.'
    );
  }
}
