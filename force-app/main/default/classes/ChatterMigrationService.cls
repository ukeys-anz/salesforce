/**
 * @author Mouhamed "Mo" Assafiri
 * @since  02/2022
 * @description Provides the Migration service class for use with the API Controller and the LWC
 */

@SuppressWarnings('PMD.ApexCRUDViolation')
//Supressing warning in this function because we are checking for CRUD but PMD doesn't want to validate it. The HasPermission Method will check for CRUD - Mo 17/02/22
public with sharing class ChatterMigrationService {
  /**
   * @description Clones all Chatter Feed from the VictimId to the SurvivorId
   * @param victimId String of the External Account Id for the victim, this must be a valid Account Id
   * @param survivorId String of the External Account Id for the surviving party, this must be a valid Account Id
   * @return Boolean, if successful the method will return true. Otherwise will throw an error and return false.
   */
  public static Boolean cloneChatterFromVictimToSurvivor(
    String victimId,
    String survivorId
  ) {
    ListException error = new System.ListException(); //Init
    String errorString = null;

    if (PermissionUtils.canQuery('Account')) {
      Id victimAccountId = getAccountIdFromExternalId(victimId);
      if (victimAccountId == null) {
        errorString = 'The victimId used does not match with any Accounts';
        error.setMessage(errorString);
        throw error;
      }

      Id survivorAccountId = getAccountIdFromExternalId(survivorId);
      if (survivorAccountId == null) {
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
          new List<String>{ victimAccountId, survivorAccountId }
        )
      );

      log.publishEvent();

      SystemModeActions systemAction = new SystemModeActions(
        'ChatterMigrationService',
        'cloneChatter'
      );
      List<FeedItem> items = systemAction.query(
        'SELECT Body, BestCommentId, CommentCount, LikeCount, Type, ParentId, CreatedById, CreatedDate FROM FeedItem ' +
        'WHERE Type IN (\'ContentPost\', \'LinkPost\', \'TextPost\') AND ParentId = \'' +
        victimAccountId +
        '\''
      );

      if (items.size() == 0) {
        log.info(
          String.format(
            'Not chatter items to migrate from {0} to {1}',
            new List<String>{ victimAccountId, survivorAccountId }
          )
        );
        return true;
      }

      Map<Id, List<FeedItem>> chatterItemsByAccountId = new Map<Id, List<FeedItem>>();
      chatterItemsByAccountId.put(survivorAccountId, items);

      List<FeedItem> clonedItems = cloneChatterFromOldToNew(
        chatterItemsByAccountId
      );
      cloneCommentsFromOldToNew(items, clonedItems);

      log.publishEvent();

      delete items;
      log.info(
        String.format(
          'Deleted {0} chatter items from: {1}',
          new List<String>{ String.valueOf(items.size()), victimAccountId }
        )
      );

      log.publishEvent();

      return true;
    }

    return false;
  }

  /**
   * @description Clones the lists of Chatter Items to the new Account Ids
   * @param feedItemsToMigrateByAccountIdMap | Map<Id, List<FeedItem> | Map of the list of chatter items to
   * be migrated along with the Salesforce Id of the account where the Chatter Items will be cloned to
   * @return List<FeedItem> | Returns the newly inserted cloned Chatter Items with the newAccountId
   */
  public static List<FeedItem> cloneChatterFromOldToNew(
    Map<Id, List<FeedItem>> feedItemsToMigrateByAccountIdMap
  ) {
    List<FeedItem> clonedItems = new List<FeedItem>();
    FeedItem cloned;
    if (PermissionUtils.canCreate('FeedItem')) {
      for (Id newAccountId : feedItemsToMigrateByAccountIdMap.keySet()) {
        for (
          FeedItem item : feedItemsToMigrateByAccountIdMap.get(newAccountId)
        ) {
          cloned = item.clone(false, true, true, true);
          cloned.ParentId = newAccountId;
          clonedItems.add(cloned);
        }
      }

      insert clonedItems;
    }

    lib_systemLog log = new lib_systemLog(
      ChatterMigrationService.class.getName(),
      'cloneChatterFromOldToNew'
    );

    log.publishEvent();

    return clonedItems;
  }

  /**
   * @description Clones all the Sub-Comments from each of the FeedItems supplied to the migrated FeedItems
   * @param originalItems | List<FeedItem> | The list of the original Chatter Items
   * @param clonedItems | List<FeedItem> | The list of newly created chatter items
   */
  public static void cloneCommentsFromOldToNew(
    List<FeedItem> originalItems,
    List<FeedItem> clonedItems
  ) {
    lib_systemLog log = new lib_systemLog(
      ChatterMigrationService.class.getName(),
      'cloneCommentsFromOldToNew'
    );

    SystemModeActions systemAction = new SystemModeActions(
      'ChatterMigrationService',
      'cloneComments'
    );

    List<Id> feedCommentIds = new List<Id>();
    for (FeedItem item : originalItems) {
      feedCommentIds.add(item.Id);
    }

    String feedIds = '\'' + String.join(feedCommentIds, '\',\'') + '\''; //Convert List to SOQL Query

    List<FeedComment> feedComments = systemAction.query(
      'SELECT CommentBody, CreatedById, CreatedDate, FeedItemId, CommentType From FeedComment WHERE FeedItemID IN (' +
      feedIds +
      ')'
    );

    Map<Id, Id> originalFeedIdMapping = new Map<Id, Id>{};

    for (FeedItem newItem : clonedItems) {
      originalFeedIdMapping.put(newItem.getCloneSourceId(), newItem.Id);
    }

    List<FeedComment> clonedComments = new List<FeedComment>();
    FeedComment comment;
    for (FeedComment originalComment : feedComments) {
      comment = originalComment.clone(false, true, true, true);
      comment.FeedItemId = originalFeedIdMapping.get(
        originalComment.FeedItemId
      );
      clonedComments.add(comment);
    }

    insert clonedComments;

    log.info(
      String.format(
        'Migrated {0} chatter comments',
        new List<String>{ String.valueOf(clonedComments.size()) }
      )
    );

    log.publishEvent();
  }

  /**
   * @description Returns the Account Id from the External ID
   * @param externalId String | The unique external ID you are searching for
   * @return Id | The Account Id from the found Account or null if nothing is found
   */
  @TestVisible
  private static Id getAccountIdFromExternalId(String externalId) {
    SystemModeActions systemAction = new SystemModeActions(
      'ChatterMigrationService',
      'cloneChatterFromVictimToSurvivor'
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
