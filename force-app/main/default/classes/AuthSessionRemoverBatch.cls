/**
 * @author Victor
 * @since  11/2021
 * @description Batch class to delete AuthSession records for Ocvintegration user
 *              can be refactored to be more reusable when need to expire AuthSession tokens for other users
 */
public with sharing class AuthSessionRemoverBatch implements Database.Batchable<sObject> {
  private static final String OCV_INTEGRATION_USERNAME_PREFIX = 'ocvintegration.user';

  // set default reserve session time for 1 hour so current active sessions won't be affected
  private static final Integer OCV_INTEGRATION_TOKEN_RESERVE_HOURS = 1;

  /**
   * @description Get all the authSession records in which users username is like 'ocvintegration.user'
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator scope
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    Datetime comparedDT = Datetime.now()
      .addHours(-OCV_INTEGRATION_TOKEN_RESERVE_HOURS);
    String comparedDTFormat = comparedDT.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');

    return Database.getQueryLocator(
      'SELECT Id ' +
      'FROM AuthSession ' +
      'WHERE Users.username LIKE \'' +
      OCV_INTEGRATION_USERNAME_PREFIX +
      '%\'' +
      'AND CreatedDate < ' +
      comparedDTFormat
    );
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
  @SuppressWarnings('PMD.EmptyStatementBlock')
  public void finish(Database.BatchableContext bc) {
    //No post processing steps as of now
  }
}
