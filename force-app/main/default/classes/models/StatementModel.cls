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
    public String statementId;
    @AuraEnabled
    public String accountNumber;
    @AuraEnabled
    public StatementFrom statementFrom;
    @AuraEnabled
    public StatementTo statementTo;
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
    public Integer value;
  }
  /**
   * @description statement month value information
   */
  public class Month {
    public Integer value;
  }
  /**
   * @description statement day value information
   */
  public class Day {
    public Integer value;
  }
  /**
   * @description statementUrl information
   */
  public class StatementUrl {
    @AuraEnabled
    public String statementId;
    @AuraEnabled
    public String url;
  }
  /**
   * @param json input string to deserialize
   * @return `StatementModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static StatementModel parse(String json) {
    return (StatementModel) deserialize(json, StatementModel.class);
  }
}
