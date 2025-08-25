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
      Set<Id> oppsIds = new Set<Id>();
      List<Interaction> filteredInteractionsForInsert = ListUtil.filter(records)
        .isNotNull(Interaction.Opportunity__c)
        .toList();
      List<Interaction> filteredInteractionsForUpdate = ListUtil.filter(
          records,
          oldMap
        )
        .changed(Interaction.Opportunity__c)
        .allNotChanged(new Set<SObjectField>{ Interaction.AccountId })
        .isNotNull(Interaction.Opportunity__c)
        .toList();

      oppsIds.addAll(
        ListUtil.getIds(
          filteredInteractionsForInsert,
          Interaction.Opportunity__c
        )
      );
      oppsIds.addAll(
        ListUtil.getIds(
          filteredInteractionsForUpdate,
          Interaction.Opportunity__c
        )
      );

      List<Opportunity> oppsList = IA_REPOSITORY.getOpportunities(oppsIds);
      Map<Id, Id> oppIdToCustomerIdMap = CommercialInteractionActionsHelper.getCustomerAssociatedWithOpp(
        oppsList
      );
      CommercialInteractionActionsHelper.updateCustomerOnInteraction(
        records,
        oppIdToCustomerIdMap
      );
    } catch (Exception e) {
      Logger.error(
          'Error while setting Customer on Interaction from Opportunity',
          e
        )
        .save();
      throw e;
    }
  }

  /**
   * @description set interaction name
   * @param records List of new interaction records
   **/
  public static void setNameWithChannel(List<Interaction> records) {
    List<Interaction> validRecords = ListUtil.filter(records)
      .isNotNull(Interaction.InteractionType)
      .toList();

    for (Interaction record : validRecords) {
      record.Name = record.Name.trim() + ' ' + record.InteractionType;
    }
  }

  /**
   * @description set interaction name when channel is changed
   * @param records List of new interaction records
   * @param oldMap Map of old interaction records
   **/
  public static void updateNameWithChannelChange(
    List<Interaction> records,
    Map<Id, Interaction> oldMap
  ) {
    List<Interaction> updates = ListUtil.filter(records, oldMap)
      .changed(Interaction.InteractionType)
      .toList();

    for (Interaction record : updates) {
      String oldChannel = oldMap.get(record.Id).InteractionType;
      Integer index = record.Name.lastIndexOf(oldChannel);
      record.Name =
        record.Name.substring(0, index) +
        record.Name.substring(index + oldChannel.length());
      record.Name = record.Name.trim() + ' ' + record.InteractionType;
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
    List<Interaction> filteredInteractions = ListUtil.filter(records, oldMap)
      .changed(Interaction.AccountId)
      .toList();
    Set<Id> accountIds = ListUtil.getIds(
      filteredInteractions,
      Interaction.AccountId
    );

    List<FinServ__AccountAccountRelation__c> relatedCLGAccounts = IA_REPOSITORY.getRelatedCLGAccounts(
      accountIds
    );

    Map<Id, Set<Id>> customerToCLGsMap = CommercialInteractionActionsHelper.mapCustomerToCLGAccounts(
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

    Map<Id, Set<Id>> customerToCLGsMap = CommercialInteractionActionsHelper.mapCustomerToCLGAccounts(
      relatedCLGAccounts
    );

    CommercialInteractionActionsHelper.validateCLGAccountsAgainstCustomer(
      filteredInteractionsList,
      customerToCLGsMap
    );
  }
}
