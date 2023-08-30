/**
 * @author Sahil Sachar
 * @since 10/2021
 * @description ChatterPost Actions consists of all the Chatter Post related methods which can be reused. LeadTriggerHandlerTest covers createLeadChatterPost
 */
@SuppressWarnings(
  'PMD.ApexCRUDViolation, PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity'
)
public with sharing class ChatterPostActions {
  //Map for lead expiry mapping
  static Map<String, LeadExpiryNotificationWrapper> leadExpNotificationWrapMap {
    get {
      return new Map<String, LeadExpiryNotificationWrapper>{
        '48;Adobe;Inprogress' => new LeadExpiryNotificationWrapper(
          System.Label.NotfiyInprogressLead2DaysPriorExpiry,
          'Owner'
        ),
        '48;CCRM;Inprogress' => new LeadExpiryNotificationWrapper(
          System.Label.NotfiyInprogressLead2DaysPriorExpiry,
          'Owner'
        ),
        '48;UNICA;Inprogress' => new LeadExpiryNotificationWrapper(
          System.Label.NotfiyInprogressLead2DaysPriorExpiry,
          'Owner'
        ),
        '24;Adobe;Inprogress' => new LeadExpiryNotificationWrapper(
          System.Label.NotfiyInprogressLead1DayPriorExpiry,
          'TeamManager'
        ),
        '48;Adobe;Assigned' => new LeadExpiryNotificationWrapper(
          System.Label.NotfiyInprogressLead2DaysPriorExpiry,
          'Owner'
        ),
        '48;CCRM;Assigned' => new LeadExpiryNotificationWrapper(
          System.Label.NotfiyInprogressLead2DaysPriorExpiry,
          'Owner'
        ),
        '48;UNICA;Assigned' => new LeadExpiryNotificationWrapper(
          System.Label.NotfiyInprogressLead2DaysPriorExpiry,
          'Owner'
        ),
        '24;Adobe;Assigned' => new LeadExpiryNotificationWrapper(
          System.Label.NotfiyInprogressLead1DayPriorExpiry,
          'TeamManager'
        ),
        '48;Adobe;Outcome;OpportunityIdentified' => new LeadExpiryNotificationWrapper(
          System.Label.NotfiyOutcomeLead2DayPriorExpiry,
          'Owner'
        ),
        '48;UNICA;Outcome;OpportunityIdentified' => new LeadExpiryNotificationWrapper(
          System.Label.NotfiyOutcomeLead2DayPriorExpiry,
          'Owner'
        ),
        '48;CCRM;Outcome;OpportunityIdentified' => new LeadExpiryNotificationWrapper(
          System.Label.NotfiyOutcomeLead2DayPriorExpiry,
          'Owner'
        ),
        '24;Adobe;Outcome;OpportunityIdentified' => new LeadExpiryNotificationWrapper(
          System.Label.NotfiyOutcomeLead1DayPriorExpiry,
          'TeamManager'
        ),
        '24;CCRM;Outcome;OpportunityIdentified' => new LeadExpiryNotificationWrapper(
          System.Label.NotfiyOutcomeLead1DayPriorExpiry,
          'TeamManager'
        ),
        '24;UNICA;Outcome;OpportunityIdentified' => new LeadExpiryNotificationWrapper(
          System.Label.NotfiyOutcomeLead1DayPriorExpiry,
          'TeamManager'
        )
      };
    }
  }

  /* @description Get Lead Owner Names.
   * @name getOwnerNames
   * @param listOfLeads List of User Ids to fetch Name.
   * @return Map<Id, User> List of Owner Details.
   */
  private static Map<Id, User> getLeadOwnerNames(List<Lead> listOfLeads) {
    Set<Id> ownerIds = new Set<Id>();
    if (!Schema.sObjectType.User.isQueryable() || listOfLeads.isEmpty()) {
      return new Map<Id, User>();
    }

    for (Lead leadRec : listOfLeads) {
      ownerIds.add(leadRec.OwnerId);
    }

    return new Map<Id, User>(
      [
        SELECT Id, Name, Manager.Id, Manager.Name, Manager.Email
        FROM User
        WHERE Id IN :ownerIds
      ]
    );
  }

  /**
   * @description get ListView URL Link based on Object Name and Listview Label.
   * @param objectName Object Name of the Listview.
   * @param listViewLabel Name of the Listview.
   * @return Final URL of the requested sObject Listview.
   */
  private static String getListViewURL(
    String objectName,
    String listViewLabel
  ) {
    String prefix = Schema.getGlobalDescribe()
      .get(objectName)
      .getDescribe()
      .getKeyPrefix();

    ApexPages.StandardSetController controller = new ApexPages.StandardSetController(
      Database.getQueryLocator('SELECT Name FROM ' + objectName + ' LIMIT 1')
    );

    for (SelectOption listView : controller.getListViewOptions()) {
      if (listView.getLabel() == listViewLabel) {
        return String.format(
          '{0}/{1}?fcf={2}',
          new List<String>{
            System.Url.getSalesforceBaseURL().toExternalForm(),
            prefix,
            listView.getValue()
          }
        );
      }
    }
    return null;
  }

  /**
   * @description Create Chatter Post to notify Lead Owner.
   * @name createLeadChatterPost
   * @param parentRecords List of Lead Records.
   * @param messageBody Notification Message.
   */
  public static void createLeadChatterPost(
    List<Lead> parentRecords,
    String messageBody
  ) {
    /* Declaration */
    List<FeedItem> newChatterPostList = new List<FeedItem>();
    List<ConnectApi.BatchInput> feedItemInputBatch = new List<ConnectApi.BatchInput>();
    ConnectApi.LinkCapabilityInput lsitViewLink = new ConnectApi.LinkCapabilityInput();
    String leadNotifcationWrapperKey = '';
    Map<Id, User> globalUserRecord = getLeadOwnerNames(parentRecords);
    Map<Id, String> leadNotificationWrapperKeyMap = new Map<Id, String>();
    // Changes added as part of CC-1101 to include ML Lead record type records also for chatter notification.
    // Changes made as part of CC-1100
    String mlMessageBody = String.isNotBlank(messageBody)
      ? getMLMessage(messageBody)
      : '';

    lsitViewLink.url = getListViewURL('Lead', Label.CCRM_ListViewName);
    lsitViewLink.urlName = Label.CCRM_ListViewName;
    if (String.isNotBlank(messageBody) || String.isNotBlank(mlMessageBody)) {
      /* Create Chatterfeeds for Owner when Lead Owner is assigned to them. */
      leadNotificationWrapperKeyMap = getLeadNotificationWrapperKey(
        parentRecords
      );
      for (Lead parentLead : parentRecords) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        mentionSegmentInput.id = parentLead.ownerId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        // Changes added as part of CC-1101 to include ML Lead record type records also for chatter notification.
        String strExpiryMessageBody = '';
        if (parentLead.RecordTypeId == CCRMConstants.CCRM_LEAD_RT_ID) {
          leadNotifcationWrapperKey = leadNotificationWrapperKeyMap.get(
            parentLead.Id
          );
          //get expiry message
          strExpiryMessageBody = String.isNotBlank(leadNotifcationWrapperKey) &&
            leadExpNotificationWrapMap.containsKey(leadNotifcationWrapperKey)
            ? String.isNotBlank(
                  leadExpNotificationWrapMap.get(leadNotifcationWrapperKey)
                    .message
                )
                ? leadExpNotificationWrapMap.get(leadNotifcationWrapperKey)
                    .message
                : messageBody
            : messageBody;
          //assign user to notify
          mentionSegmentInput.id = String.isNotBlank(
              leadNotifcationWrapperKey
            ) &&
            leadExpNotificationWrapMap.containsKey(leadNotifcationWrapperKey) &&
            String.isNotBlank(
              leadExpNotificationWrapMap.get(leadNotifcationWrapperKey)
                .userToNotify
            )
            ? leadExpNotificationWrapMap.get(leadNotifcationWrapperKey)
                  .userToNotify.equalsIgnoreCase('Owner')
                ? parentLead.ownerId
                : globalUserRecord.containsKey(parentLead.ownerId) &&
                    globalUserRecord.get(parentLead.ownerId).Manager.Id != null
                    ? globalUserRecord.get(parentLead.ownerId).Manager.Id
                    : parentLead.ownerId
            : parentLead.ownerId;
        } else if (parentLead.RecordTypeId == MLCRMConstants.MLCRM_LEAD_RT_ID) {
          strExpiryMessageBody = mlMessageBody;
          mentionSegmentInput.id = parentLead.ownerId;
        }
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        for (String messageText : strExpiryMessageBody.Split('#')) {
          if (messageText.contains('{LeadId}')) {
            ConnectApi.EntityLinkSegmentInput entityLinkSegmentInputLead = new ConnectApi.EntityLinkSegmentInput();
            entityLinkSegmentInputLead.entityId = parentLead.Id;
            messageBodyInput.messageSegments.add(entityLinkSegmentInputLead);
          } else if (messageText.contains('{Lead.Lead_Originator__c}')) {
            textSegmentInput = new ConnectApi.TextSegmentInput();
            textSegmentInput.text = messageText.replace(
              '{Lead.Lead_Originator__c}',
              parentLead.Lead_Originator__c
            );
            messageBodyInput.messageSegments.add(textSegmentInput);
          } else {
            textSegmentInput = new ConnectApi.TextSegmentInput();
            textSegmentInput.text = ' ' + messageText;
            messageBodyInput.messageSegments.add(textSegmentInput);
          }
        }

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = parentLead.Id;

        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(
          feedItemInput
        );
        feedItemInputBatch.add(batchInput);

        if (Test.isRunningTest()) {
          newChatterPostList.add(
            getchatterPostForTesting(
              globalUserRecord,
              strExpiryMessageBody,
              parentLead
            )
          );
        }
      }

      if (!feedItemInputBatch.isEmpty() || !newChatterPostList.isEmpty()) {
        insertChatterPost(feedItemInputBatch, newChatterPostList);
      }
    }
  }

  /**
   * @description assign correct ML message
   * @name getMLMessage
   * @param messageBody chatter message to post
   * @return String
   */
  private static String getMLMessage(String messageBody) {
    String mlMessageBody = '';
    if (messageBody.equals(Label.CCRM_NewSourceLeadMessage)) {
      mlMessageBody = Label.MLCRM_NewSourceLeadMessage;
    } else if (messageBody.equals(Label.CCRM_ExpiryReminderMessage)) {
      mlMessageBody = Label.ML_ExpiryRemainderMessage;
    }
    return mlMessageBody;
  }

  /**
   * @description chatter post for Unit Testing
   * @name getchatterPostForTesting
   * @param globalUserRecord user record
   * @param strExpiryMessageBody Chatter message to post
   * @param parentLead lead record
   * @return FeedItem
   */
  private static FeedItem getchatterPostForTesting(
    Map<Id, User> globalUserRecord,
    String strExpiryMessageBody,
    Lead parentLead
  ) {
    FeedItem chatterPost = new FeedItem();
    chatterPost.ParentId = parentLead.Id;
    chatterPost.Body = globalUserRecord.containsKey(parentLead.OwnerId)
      ? '@' +
        globalUserRecord.get(parentLead.OwnerId).Name +
        strExpiryMessageBody
      : strExpiryMessageBody;
    return chatterPost;
  }

  /**
   * @description to do inseert DML on chatter post/Feed item
   * @name insertChatterPost
   * @param feedItemInputBatch batch of chatter post input
   * @param newChatterPostList list of feed item
   */
  private static void insertChatterPost(
    List<ConnectApi.BatchInput> feedItemInputBatch,
    List<FeedItem> newChatterPostList
  ) {
    try {
      if (!Test.isRunningTest() && !feedItemInputBatch.isEmpty()) {
        ConnectApi.ChatterFeeds.postFeedElementBatch(
          Network.getNetworkId(),
          feedItemInputBatch
        );
      } else {
        Database.Insert(newChatterPostList);
      }
    } catch (Exception err) {
      Logger.error('CHATTER_POST_NOT_GETTING_CREATED' + err.getMessage(), err);
      Logger.saveLog();
    }
  }

  /**
   * @description Create Chatter Post to notify Lead Owner.
   * @name getLeadNotificationWrapperKey
   * @param parentRecords List of Lead Records.
   * @return Map of lead id and key
   */
  private static Map<Id, String> getLeadNotificationWrapperKey(
    List<Lead> parentRecords
  ) {
    Map<Id, String> leadNotifcationWrapperKeyMap = new Map<Id, String>();
    for (Lead parentLead : parentRecords) {
      if (parentLead.RecordTypeId == CCRMConstants.CCRM_LEAD_RT_ID) {
        leadNotifcationWrapperKeyMap.put(
          parentLead.Id,
          String.valueOf(
            Date.today().daysBetween(parentLead.Expiry_Date__c) * 24
          ) +
          ';' +
          parentLead.Lead_Originator__c +
          (parentLead.Status.equalsIgnoreCase(
              System.Label.CCRM_LeadStatusInProgress
            ) ||
            parentLead.Status.equalsIgnoreCase(
              System.Label.CCRM_LeadStatusAssigned
            )
            ? ';' + parentLead.Status.deleteWhitespace()
            : parentLead.Status.equalsIgnoreCase(
                  System.Label.CCRM_LeadStatusOutcome
                ) &&
                parentLead.Lead_Outcome__c.equalsIgnoreCase(
                  System.Label.CCRM_LeadOutcomeOpportunityIdentified
                )
                ? ';' +
                  parentLead.Status +
                  ';' +
                  parentLead.Lead_Outcome__c.deleteWhitespace()
                : '')
        );
      }
    }
    return leadNotifcationWrapperKeyMap;
  }

  class LeadExpiryNotificationWrapper {
    String message;
    String userToNotify;
    LeadExpiryNotificationWrapper(String message, String userToNotify) {
      this.message = message;
      this.userToNotify = userToNotify;
    }
  }
}
