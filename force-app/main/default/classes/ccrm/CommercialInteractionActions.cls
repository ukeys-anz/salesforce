/**
 * @author Ayushi G
 * @since  05/2024
 * @group CCRM (Commercial CRM)
 * @description CommercialInteractionActions is class to handle all the CCRM (Commercial CRM) Actions
 */
public with sharing class CommercialInteractionActions {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final CCRMInteractionActionsRepository IA_REPOSITORY = (CCRMInteractionActionsRepository) Lib_InstanceProvider.forType(
    CCRMInteractionActionsRepository.class
  );

  /**
   * @description publish cloud events for Interactions
   * @param interactions
   * @param actionCode
   **/
  public static void publishCloudEvents(
    List<Interaction> interactions,
    String actionCode
  ) {
    try {
      InteractionCEBuilder.InteractionCEWrapper interactionCEWrapper = new InteractionCEBuilder.InteractionCEWrapper(
        interactions
      );

      List<CloudEventModel> cloudEvents = InteractionCEBuilder.createCloudEvents(
        interactions,
        interactionCEWrapper,
        actionCode
      );
      CloudEventController.publishCloudEvents(cloudEvents);
    } catch (Exception e) {
      Logger.error(
          'Errored out while publishing the cloud event for Interactions',
          e
        )
        .save();
      throw e;
    }
  }

  /**
   * @description creates default Attendees for Broker Interactions
   * @param interactions
   **/
  public static void createBrokerInteractionAttendee(
    List<Interaction> interactions
  ) {
    List<Interaction> filteredInteractionsList = ListUtil.filter(interactions)
      .isNotNull(Interaction.Broker__c)
      .toList();

    List<InteractionAttendee> newAttendeesToCreate = new List<InteractionAttendee>();
    for (Interaction interactionRec : filteredInteractionsList) {
      newAttendeesToCreate.add(
        new InteractionAttendee(
          ContactId = interactionRec.Broker__c,
          InteractionId = interactionRec.Id,
          AttendeeType = 'Customer'
        )
      );
    }

    DML_REPOSITORY.doInsert(newAttendeesToCreate);
  }

  /**
   * @description set Customer on Interaction From Opportunity
   * @param records List of new interaction records
   * @param oldMap Map of old interaction records
   */
  public static void setCustomerOnInteraction(
    List<Interaction> records,
    Map<Id, Interaction> oldMap
  ) {
    try {
      Set<Id> oppsIds = CommercialInteractionActionsHelper.getOppsIdsAssociatedWithInteractions(
        records,
        oldMap
      );
      List<Opportunity> oppsList = IA_REPOSITORY.getOpportunities(oppsIds);
      Map<Id, Id> oppIdToCustomerIdMap = getCustomerAssociatedWithOpp(oppsList);
      updateCustomerOnInteraction(records, oppIdToCustomerIdMap);
    } catch (Exception e) {
      Logger.error(
          'Error while setting Customer on Interaction from Opportunity',
          e
        )
        .save();
      throw e;
    }
  }

  private static Map<Id, Id> getCustomerAssociatedWithOpp(
    List<Opportunity> opps
  ) {
    Map<Id, Id> oppIdToCustomerIdMap = new Map<Id, Id>();

    for (Opportunity opp : opps) {
      oppIdToCustomerIdMap.put(opp.Id, opp.AccountId);
    }
    return oppIdToCustomerIdMap;
  }

  @TestVisible
  private static void updateCustomerOnInteraction(
    List<Interaction> records,
    Map<Id, Id> oppIdToCustomerIdMap
  ) {
    if (oppIdToCustomerIdMap.keySet().isEmpty()) {
      return;
    }
    for (Interaction record : records) {
      if (oppIdToCustomerIdMap.containsKey(record.Opportunity__c)) {
        record.AccountId = oppIdToCustomerIdMap.get(record.Opportunity__c);
      }
    }
  }

  /**
   * @description set interaction name
   * @param records List of new interaction records
   * @param oldMap map of interaction records
   */
  public static void setInteractionName(
    List<Interaction> records,
    Map<Id, Interaction> oldMap
  ) {
    try {
      List<Interaction> updatedInteractions = CommercialInteractionActionsHelper.getUpdatedNameOrChannelInteractions(
        records,
        oldMap
      );
      CommercialInteractionActionsHelper.updateInteractionName(
        updatedInteractions,
        oldMap
      );
    } catch (Exception e) {
      Logger.error(
          'Error while setting Interaction Name on Interaction records',
          e
        )
        .save();
      throw e;
    }
  }

  /**
   * @description : It will restrict the user to upload images in rich text fields
   * @name : restrictImagesInRichTextFields
   * @param records List of Interaction records
   * @param oldMap Map of old Interaction records
   */
  public static void restrictImagesInRichTextFields(
    List<Interaction> records,
    Map<Id, Interaction> oldMap
  ) {
    List<SObjectField> fieldList = Schema.SObjectType.Interaction.fields.getMap()
      .values();
    Set<SObjectField> richTextFieldSet = CommercialCommonUtil.getRichTextFields(
      fieldList
    );
    CommercialCommonUtil.restrictImages(records, oldMap, richTextFieldSet);
  }

  /**
   * @description This method will perform redaction on sensitive data in the provided records.
   * @name performRedaction
   * @param records from the trigger
   */
  public static void performRedaction(List<Interaction> records) {
    TextUtils.maskSObjectDataANZExtended(records, 'Comment__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Optional_Notes__c');
  }

  /**
   * @description handle CLG validation and populate CLG value.
   * @param records The list of List<Interaction>
   * @param oldMap The map of old Interaction records
   */
  public static void populateCLG(
    List<Interaction> records,
    Map<Id, Interaction> oldMap
  ) {
    Set<Id> accountIds = ListUtil.getIds(records, Interaction.AccountId);

    List<FinServ__AccountAccountRelation__c> relatedCLGAccounts = IA_REPOSITORY.getRelatedCLGAccounts(
      accountIds
    );

    Map<Id, Set<Id>> customerToCLGsMap = mapCustomerToCLGAccounts(
      relatedCLGAccounts
    );

    Map<Id, Account> accountMap = IA_REPOSITORY.getAccountsWithRecordTypes(
      accountIds
    );

    CommercialInteractionActionsHelper.populateCLGForInteraction(
      records,
      customerToCLGsMap,
      accountMap
    );
  }

  /**
   * @description handle CLG validation on Update.
   * @param records The list of List<Interaction>
   * @param oldMap The map of old Interaction records
   */
  public static void validateAndPopulateCLG(
    List<Interaction> records,
    Map<Id, Interaction> oldMap
  ) {
    List<Interaction> filteredInteractionsList = ListUtil.filter(
        records,
        oldMap
      )
      .changed(Interaction.CLGCustomer__c)
      .toList();

    Set<Id> accountIds = ListUtil.getIds(
      filteredInteractionsList,
      Interaction.AccountId
    );

    List<FinServ__AccountAccountRelation__c> relatedCLGAccounts = IA_REPOSITORY.getRelatedCLGAccounts(
      accountIds
    );

    Map<Id, Set<Id>> customerToCLGsMap = mapCustomerToCLGAccounts(
      relatedCLGAccounts
    );

    CommercialInteractionActionsHelper.validateCLGAccountsAgainstCustomer(
      filteredInteractionsList,
      customerToCLGsMap
    );
  }

  /**
   * @description mapping of customer to their related CLG accounts.
   * @param relatedCLGAccounts The list of List<FinServ__AccountAccountRelation__c>
   * @return Map<Id, Set<Id>>
   */
  @TestVisible
  private static Map<Id, Set<Id>> mapCustomerToCLGAccounts(
    List<FinServ__AccountAccountRelation__c> relatedCLGAccounts
  ) {
    Map<Id, Set<Id>> customerToCLGAccountsMap = new Map<Id, Set<Id>>();

    for (FinServ__AccountAccountRelation__c aar : relatedCLGAccounts) {
      if (
        aar.FinServ__Account__c == null ||
        aar.FinServ__RelatedAccount__c == null
      ) {
        continue;
      }

      if (!customerToCLGAccountsMap.containsKey(aar.FinServ__Account__c)) {
        customerToCLGAccountsMap.put(aar.FinServ__Account__c, new Set<Id>());
      }
      customerToCLGAccountsMap.get(aar.FinServ__Account__c)
        .add(aar.FinServ__RelatedAccount__c);
    }
    return customerToCLGAccountsMap;
  }
}
