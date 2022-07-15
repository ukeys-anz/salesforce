/**
 * @author Sahil Sachar
 * @since 10/2021
 * @description ChatterPost Actions consists of all the Chatter Post related methods which can be reused. LeadTriggerHandlerTest covers createLeadChatterPost
 */
@SuppressWarnings(
  'PMD.ApexCRUDViolation, PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity'
)
public with sharing class ChatterPostActions {
  /**
   * @description Get Lead Owner Names.
   * @name getOwnerNames
   * @param listOfLeads List of User Ids to fetch Name.
   * @return Map<Id, User> List of Owner Details.
   */
  private static Map<Id, User> getLeadOwnerNames(List<Lead> listOfLeads) {
    Set<Id> ownerIds = new Set<Id>();
    Map<Id, User> ownerDetails = new Map<Id, User>();

    if (!Schema.sObjectType.User.isQueryable() || listOfLeads.isEmpty()) {
      return new Map<Id, User>();
    }

    for (Lead leadRec : listOfLeads) {
      ownerIds.add(leadRec.OwnerId);
    }

    return new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :ownerIds]);
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
    Map<Id, User> globalUserRecord = getLeadOwnerNames(parentRecords);

    lsitViewLink.url = getListViewURL('Lead', Label.CCRM_ListViewName);
    lsitViewLink.urlName = Label.CCRM_ListViewName;

    if (String.isNotBlank(messageBody)) {
      /* Create Chatterfeeds for Owner when Lead Owner is assigned to them. */
      for (Lead parentLead : parentRecords) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        mentionSegmentInput.id = parentLead.ownerId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);

        for (String messageText : messageBody.Split('#')) {
          ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

          if (messageText.contains('{LeadId}')) {
            ConnectApi.EntityLinkSegmentInput entityLinkSegmentInputLead = new ConnectApi.EntityLinkSegmentInput();
            entityLinkSegmentInputLead.entityId = parentLead.Id;
            messageBodyInput.messageSegments.add(entityLinkSegmentInputLead);
          } else if (messageText.contains('{LeadListViewId}')) {
            ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
            feedElementCapabilitiesInput.link = lsitViewLink;
            feedItemInput.capabilities = feedElementCapabilitiesInput;
          } else if (messageText.contains('{Lead.Lead_Originator__c}')) {
            textSegmentInput = new ConnectApi.TextSegmentInput();
            textSegmentInput.text = parentLead.Lead_Originator__c;
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
          FeedItem chatterPost = new FeedItem();
          chatterPost.ParentId = parentLead.Id;
          chatterPost.Body = globalUserRecord.containsKey(parentLead.OwnerId)
            ? '@' + globalUserRecord.get(parentLead.OwnerId).Name + messageBody
            : messageBody;
          newChatterPostList.add(chatterPost);
        }
      }

      try {
        if (!Test.isRunningTest()) {
          ConnectApi.ChatterFeeds.postFeedElementBatch(
            Network.getNetworkId(),
            feedItemInputBatch
          );
        } else {
          Database.Insert(newChatterPostList);
        }
      } catch (Exception err) {
        lib_systemLog.createSingleLog(
          'CCRMLeadActions',
          'createLeadChatterPost',
          'CHATTER_POST_NOT_GETTING_CREATED',
          err.getMessage(),
          lib_systemLog.Severity.ERROR
        );
      }
    }
  }
}
