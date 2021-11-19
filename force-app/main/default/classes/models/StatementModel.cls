/**
 * Suppressing PMD naming convention warnings as some fields return in snake case formatting from the API.
 */
@SuppressWarnings('PMD.FieldNamingConventions')
/**
 * @author Chiranjeeb Dhar
 * @since October 2021
 * @description Model for statements API
 */
public with sharing class StatementModel extends CalloutModel {
  @AuraEnabled
  public List<Statements> statements;
  @AuraEnabled
  public StatementUrl statement;
  /**
   * @description statement information
   */
  public class Statements {
    @AuraEnabled
    public String statement_id;
    @AuraEnabled
    public String account_number;
    @AuraEnabled
    public StatementFrom statement_from;
    @AuraEnabled
    public StatementTo statement_to;
    /**
     * @description validates the response for expected values by the UI
     */
    @AuraEnabled
    public Boolean isValid {
      get {
        return (String.isNotBlank(this.account_number) &&
        (this.statement_from?.year?.value != null &&
        this.statement_from?.month?.value != null &&
        this.statement_from?.day?.value != null) &&
        (this.statement_to?.year?.value != null &&
        this.statement_to?.month?.value != null &&
        this.statement_to?.day?.value != null));
      }
      set;
    }
  }
  /**
   * @description statement From date information
   */
  public class StatementFrom {
    @AuraEnabled
    public Year year;
    @AuraEnabled
    public Month month;
    @AuraEnabled
    public Day day;
  }
  /**
   * @description statement To date information
   */
  public class StatementTo {
    @AuraEnabled
    public Year year;
    @AuraEnabled
    public Month month;
    @AuraEnabled
    public Day day;
  }
  /**
   * @description year value information
   */
  public class Year {
    @AuraEnabled
    public Integer value;
  }
  /**
   * @description statement month value information
   */
  public class Month {
    @AuraEnabled
    public Integer value;
  }
  /**
   * @description statement day value information
   */
  public class Day {
    @AuraEnabled
    public Integer value;
  }
  /**
   * @description statementUrl information
   */
  public class StatementUrl {
    @AuraEnabled
    public String statement_id;
    @AuraEnabled
    public String url;
  }
  /**
   * @param json input string to deserialize
   * @return `StatementModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static StatementModel parse(String json) {
    StatementModel statementModel;

    try {
      statementModel = (StatementModel) deserialize(json, StatementModel.class);

      if (statementModel.statements != null) {
        validateStatements(statementModel.statements);
      }
    } catch (Exception e) {
      throw new InvalidInformationException(e.getMessage());
    }

    return statementModel;
  }

  /**
   * @param statements a list of statements returned from API
   * @description validate server returned data, thorw InvalidInformationException if data is invalid
   */
  public static void validateStatements(List<Statements> statements) {
    for (Statements statement : statements) {
      if (!statement.isValid) {
        String errorMsg = buildErrorMsg(statement);

        throw new InvalidInformationException(
          'Statements Information is invalid. ' +
          errorMsg +
          ' Please reach out to your system administrator.'
        );
      }
    }
  }

  /**
   * @param statement
   * @return String error message
   * @description check if the statement data integrity
   */
  public static String buildErrorMsg(Statements statement) {
    String errorMsg = '';

    if (
      statement.statement_from?.year?.value == null ||
      statement.statement_to?.year?.value == null
    ) {
      errorMsg += 'Year ';
    }

    if (
      statement.statement_from?.month?.value == null ||
      statement.statement_to?.month?.value == null
    ) {
      errorMsg += 'Month ';
    }

    if (
      statement.statement_from?.day?.value == null ||
      statement.statement_to?.day?.value == null
    ) {
      errorMsg += 'Day ';
    }

    errorMsg += 'data is missing in response.';

    return errorMsg;
  }

  /**
   * @author Chiranjeeb
   * @since October 2021
   * @description invaid information exception
   */
  public class InvalidInformationException extends Exception {
  }
}
