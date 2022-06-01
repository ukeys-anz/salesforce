/**
 * @author Emma Bindi
 * @since  05/2022
 * @description Helper methods for migration of Chatter Posts upon Lead Conversion
 */
public with sharing class LeadChatterMigrationHelper {
  /**
   * @description migrateChatterPostsOnConversion Clones the lists of Chatter
   * Items & Comments from converted Leads to their respective Account Ids
   * @param records | List<Lead> | The Lead records passed from afterUpdate()
   * @param oldMap | Map<Id, SObject> |Map of old Lead records
   */
  public static void migrateChatterPostsOnConversion(
    List<Lead> records,
    Map<Id, SObject> oldMap
  ) {
    try {
      // Filter for only the leads which have been converted in this update
      List<Lead> convertedLeadsList = filterConvertedLeads(records, oldMap);

      if (convertedLeadsList.size() > 0) {
        List<FeedItem> chatterToMigrate = findChatterItemsToMigrate(
          convertedLeadsList
        );

        Map<Id, List<FeedItem>> chatterToMigrateByAccount = putFeedItemsInMapByAccount(
          convertedLeadsList,
          chatterToMigrate
        );

        // Clone Chatter Posts from Lead to Account
        if (chatterToMigrateByAccount.size() > 0) {
          if (PermissionUtils.canQuery('Lead')) {
            List<FeedItem> clonedChatterPosts = ChatterMigrationService.cloneChatterFromOldToNew(
              chatterToMigrateByAccount
            );

            // Clone Comments on Chatter Posts from Lead to Account
            ChatterMigrationService.cloneCommentsFromOldToNew(
              chatterToMigrate,
              clonedChatterPosts
            );
          }
        }
      }
    } catch (Exception e) {
      Lib_SystemLog.createSingleLogAsync(
        LeadChatterMigrationHelper.class.getName(),
        'migrateChatterPostsOnConversion',
        'LEA001',
        e.getMessage()
      );
    }
  }

  /**
   * @description filterConvertedLeads filters the Leads passed from afterUpdate()
   * trigger to those where isConverted has been updated to true
   * @param updatedLeads | List<Lead> | The Lead records passed from afterUpdate()
   * @param oldMap | Map<Id, SObject> | Map of old Lead records
   * @return | List<Lead> | Returns only leads which were converted in the update
   */
  private static List<Lead> filterConvertedLeads(
    List<Lead> updatedLeads,
    Map<Id, SObject> oldMap
  ) {
    List<Lead> convertedLeadsList = new List<Lead>();
    Map<Id, Lead> leadsMap = new Map<Id, Lead>((Map<Id, Lead>) oldMap);

    for (Lead lead : updatedLeads) {
      if (lead.isConverted) {
        if (!leadsMap.get(lead.Id).isConverted) {
          convertedLeadsList.add(lead);
        }
      }
    }
    return convertedLeadsList;
  }

  /**
   * @description private without sharing class to allow querying Feed Items
   */
  private without sharing class FeedItemRetriever {
    /**
     * @description queryFeedItems queries for the Feed Items on the Leads provided
     * @param convertedLeadsList | List<Lead> | The converted Lead records
     * @return | List<FeedItem> | Returns related Chatter Posts from the converted Leads
     */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    private List<FeedItem> queryFeedItems(List<Lead> convertedLeadsList) {
      List<FeedItem> chatterToMigrate = new List<FeedItem>();
      return chatterToMigrate = [
        SELECT
          Body,
          BestCommentId,
          CommentCount,
          LikeCount,
          Type,
          ParentId,
          CreatedById,
          CreatedDate
        FROM FeedItem
        WHERE
          Type IN ('ContentPost', 'LinkPost', 'TextPost')
          AND ParentId IN :convertedLeadsList
      ];
    }
  }

  /**
   * @description findChatterItemsToMigrate queries for the Feed Items on the Leads provided
   * @param convertedLeadsList | List<Lead> | The converted Lead records
   * @return | List<FeedItem> | Returns related Chatter Posts from the converted Leads
   */
  public static List<FeedItem> findChatterItemsToMigrate(
    List<Lead> convertedLeadsList
  ) {
    List<FeedItem> chatterToMigrate = new List<FeedItem>();

    try {
      FeedItemRetriever feedItemRetriever = new FeedItemRetriever();
      chatterToMigrate = feedItemRetriever.queryFeedItems(convertedLeadsList);
    } catch (Exception e) {
      Lib_SystemLog.createSingleLogAsync(
        LeadChatterMigrationHelper.class.getName(),
        'findChatterItemsToMigrate',
        'LEA002',
        e.getMessage()
      );
    }

    return chatterToMigrate;
  }

  /**
   * @description putFeedItemsInMapByAccount stores the related Feed Items in a map with Account Id
   * @param convertedLeads | List<Lead> | The converted Lead records
   * @param chatterPostsOnLead |  List<FeedItem> | List of related Chatter Posts
   * @return | Map<Id, List<FeedItem>> | Returns a map of the related Feed Items with the corresponding Account record
   */
  private static Map<Id, List<FeedItem>> putFeedItemsInMapByAccount(
    List<Lead> convertedLeads,
    List<FeedItem> chatterPostsOnLead
  ) {
    Map<Id, List<FeedItem>> chatterItemsToMigrateByAccountMap = new Map<Id, List<FeedItem>>();

    for (Lead lead : convertedLeads) {
      for (FeedItem feedItem : chatterPostsOnLead) {
        if (feedItem.ParentId == lead.Id) {
          // Check if the map already contains this key
          if (
            chatterItemsToMigrateByAccountMap.containsKey(
              lead.ConvertedAccountId
            )
          ) {
            // If yes, add the Feed Item to the existing list
            chatterItemsToMigrateByAccountMap.get(lead.ConvertedAccountId)
              .add(feedItem);
          } else {
            List<FeedItem> chatterItemList = new List<FeedItem>();
            chatterItemList.add(feedItem);
            chatterItemsToMigrateByAccountMap.put(
              lead.ConvertedAccountId,
              chatterItemList
            );
          }
        }
      }
    }

    return chatterItemsToMigrateByAccountMap;
  }
}
