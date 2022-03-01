/**
 * @author Mouhamed "Mo" Assafiri
 * @since  02/2022
 * @description Provides the Migration service class for use with the API Controller and the LWC
 */

public with sharing class ChatterMigrationService {
  @SuppressWarnings('PMD.ApexCRUDViolation')
  //Supressing warning in this function because we are checking for CRUD but PMD doesn't want to validate it. - Mo 17/02/22

  /**
   * @description Clones all Chatter Feed from the VictimId to the SurvivorId
   * @param victimId String of the External Account Id for the victim, this must be a valid Account Id
   * @param survivorId String of the External Account Id for the surviving party, this must be a valid Account Id
   * @return Boolean, if successful the method will return true. Otherwise will throw an error and return false.
   */
  public static Boolean cloneChatterFromVicimToSurvivor(
    String victimId,
    String survivorId
  ) {
    ListException error = new System.ListException(); //Init
    String errorString = null;

    if (hasPermissions()) {
      Id victimAccount = getAccountIdFromExternalId(victimId);
      if (victimAccount == null) {
        errorString = 'The victimId used does not match with any Accounts';
        error.setMessage(errorString);
        throw error;
      }

      Id survivorAccount = getAccountIdFromExternalId(survivorId);
      if (survivorAccount == null) {
        errorString = 'The survivorId used does not match with any Accounts';
        error.setMessage(errorString);
        throw error;
      }

      lib_systemLog log = new lib_systemLog(
        ChatterMigrationService.class.getName(),
        'ChatterMigrationService Found Accounts'
      );

      log.info(
        String.format(
          'Migrating chatter from account: {0} to: {1}',
          new List<String>{ victimAccount, survivorAccount }
        )
      );

      log.insertLogAsync();

      SystemModeActions systemAction = new SystemModeActions(
        'ChatterMigrationService',
        'cloneChatterFromVicimToSurvivor'
      );
      List<FeedItem> items = systemAction.query(
        'SELECT Body, BestCommentId, CommentCount, LikeCount, Type, ParentId, CreatedById, CreatedDate FROM FeedItem WHERE ParentId = \'' +
        victimAccount +
        '\''
      );
      List<FeedItem> clonedItems = new List<FeedItem>();
      FeedItem cloned;

      for (FeedItem item : items) {
        cloned = item.clone(false, true, true, true);
        cloned.ParentId = survivorAccount;
        clonedItems.add(cloned);
      }

      insert clonedItems;

      log.info(
        String.format(
          'Migrated {0} chatter items from: {1} to: {2}',
          new List<String>{
            String.valueOf(clonedItems.size()),
            victimAccount,
            survivorAccount
          }
        )
      );

      log.insertLogAsync();

      return true;
    }

    return false;
  }

  /**
   * @description Checks if the user has permissions
   * @return Boolean - True if the user has the right permissions, otherwise throws an error
   */

  private static Boolean hasPermissions() {
    QueryException error = new System.QueryException();

    if (!Account.sObjectType.getDescribe().isQueryable()) {
      error.setMessage('User does not have the permissions to query Accounts');
      throw error;
    }

    if (!(FeedItem.sObjectType.getDescribe().isAccessible())) {
      error.setMessage(
        'User does not have the permissions to query Feed Items'
      );
      throw error;
    }

    if (!(FeedItem.sObjectType.getDescribe().isCreateable())) {
      error.setMessage(
        'User does not have the permissions to create Feed Items'
      );
      throw error;
    }

    return true;
  }

  /**
   * @description Returns the Account Id from the External ID
   * @param externalId String | The unique external ID you are searching for
   * @return Id | The Account Id from the found Account or null if nothing is found
   */
  private static Id getAccountIdFromExternalId(String externalId) {
    SystemModeActions systemAction = new SystemModeActions(
      'ChatterMigrationService',
      'cloneChatterFromVicimToSurvivor'
    );
    List<Account> account = systemAction.query(
      'SELECT Id FROM Account WHERE External_Id__c = \'' +
      externalId +
      '\' LIMIT 1'
    );

    if (account.isEmpty()) {
      return null;
    }

    return account[0].Id;
  }
}
