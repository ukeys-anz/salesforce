/**
 * @author Victor
 * @since  11/2021
 * @description Batch class to delete AuthSession records for integration users
 */
public with sharing class AuthSessionRemoverBatch implements Database.Batchable<sObject> {
  private static final String OCV_INTEGRATION_USERNAME_PREFIX = 'ocvintegration.user';
  private static final String DISPUTES_INTEGRATION_USERNAME_PREFIX = 'disputesintegration.user';
  private static final String PEGA_INTEGRATION_USERNAME_PREFIX = 'pegaintegration.user';
  private static final String KYC_QA_INTEGRATION_USERNAME_PREFIX = 'kycqaintegration.user';
  private static final String NO_POST_PROCESSING_STEPS_MSG = 'No post processing steps as of now';

  private static final List<String> USERNAMES_PREFIX = new List<String>{
    OCV_INTEGRATION_USERNAME_PREFIX,
    DISPUTES_INTEGRATION_USERNAME_PREFIX,
    PEGA_INTEGRATION_USERNAME_PREFIX,
    KYC_QA_INTEGRATION_USERNAME_PREFIX
  };

  // set default reserve session time for 1 hour so current active sessions won't be affected
  private static final Integer TOKEN_RESERVED_HOURS = 1;

  /**
   * @description Get all the authSession records in which users username is like 'ocvintegration.user'
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator scope
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    String queryStr = buildQueryStr();

    return Database.getQueryLocator(queryStr);
  }

  /**
   * @description  method which is called when batch is exeuted, delete retrieved auth records
   * @param bc Database.BatchableContext
   * @param authSessionScope from start method
   */
  public void execute(
    Database.BatchableContext bc,
    List<AuthSession> authSessionScope
  ) {
    if (authSessionScope?.size() > 0) {
      Database.delete(authSessionScope, false);
    }
  }

  /**
   * @description To execute any post processing steps
   * @param bc Database.BatchableContext
   */
  public void finish(Database.BatchableContext bc) {
    System.debug(LoggingLevel.debug, NO_POST_PROCESSING_STEPS_MSG);
  }

  /**
   * @description  method which is used to build query string for Database.getQueryLocator
   * @return String query string
   */
  private static String buildQueryStr() {
    Datetime comparedDT = Datetime.now().addHours(-TOKEN_RESERVED_HOURS);
    String comparedDTFormat = comparedDT.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');

    String queryStr = 'SELECT Id ' + 'FROM AuthSession ' + 'WHERE (';

    for (String usernamePrefix : USERNAMES_PREFIX) {
      queryStr += 'Users.username LIKE \'' + usernamePrefix + '%\'' + ' OR ';
    }

    // remove last ' OR ', 4 chars
    queryStr = queryStr.substring(0, queryStr.length() - 4);

    queryStr += ') AND CreatedDate < ' + comparedDTFormat;

    return queryStr;
  }
}
