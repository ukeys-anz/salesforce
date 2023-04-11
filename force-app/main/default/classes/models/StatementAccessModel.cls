/**
 * Suppressing PMD naming convention warnings as some fields return in snake case formatting from the API.
 */
@SuppressWarnings('PMD.FieldNamingConventions')
/**

/**
 * @author Vidhya Raghavan
 * @since March 2023
 * @description Model to create a log access to statements
 * @group Models
 */

public with sharing class StatementAccessModel extends CalloutModel {
  public String accountId;
  public String financialAccountId;
  public String fromDate;
  public String toDate;
  public String statementType;
  public DateTime timeStamp;
  public String sUID;
}
