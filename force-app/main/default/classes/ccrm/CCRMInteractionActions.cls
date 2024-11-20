/**
 * @author Ayushi G
 * @since  05/2024
 * @group CCRM (Commercial CRM)
 * @description CCRMInteractionActions is class to handle all the CCRM (Commercial CRM) Actions
 */
public with sharing class CCRMInteractionActions {
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
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
      throw e;
    }
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
      Set<Id> oppsIds = getOppsIdsAssociatedWithInteractions(records, oldMap);
      List<Opportunity> oppsList = IA_REPOSITORY.getOpportunities(oppsIds);
      Map<Id, Id> oppIdToCustomerIdMap = getCustomerAssociatedWithOpp(oppsList);
      updateCustomerOnInteraction(records, oppIdToCustomerIdMap);
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
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
  private static Set<Id> getOppsIdsAssociatedWithInteractions(
    List<Interaction> records,
    Map<Id, Interaction> oldMap
  ) {
    Set<Id> oppsIds = new Set<Id>();
    for (Interaction record : records) {
      Boolean oppFieldChanged;
      Boolean customerFieldChanged;

      //Checking for insert as well as update case
      //For update, do processing only if opportunity Id is changed and
      //not the account Id as account change gets precedence over opportunity
      if (record.Opportunity__c == null) {
        continue;
      }

      if (oldMap != null) {
        oppFieldChanged = RecordComparisonUtil.fieldWasChanged(
          record,
          oldMap.get(record.Id),
          Interaction.Opportunity__c
        );
        customerFieldChanged = RecordComparisonUtil.fieldWasChanged(
          record,
          oldMap.get(record.Id),
          Interaction.AccountId
        );
      }

      if ((oldMap == null) || (oppFieldChanged && !(customerFieldChanged))) {
        oppsIds.add(record.Opportunity__c);
      }
    }
    return oppsIds;
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
      List<Interaction> updatedInteractions = getUpdatedNameOrChannelInteractions(
        records,
        oldMap
      );
      updateInteractionName(updatedInteractions, oldMap);
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
      throw e;
    }
  }

  @TestVisible
  private static List<Interaction> getUpdatedNameOrChannelInteractions(
    List<Interaction> records,
    Map<Id, Interaction> oldMap
  ) {
    List<Interaction> updatedInteractions = new List<Interaction>();
    for (Interaction record : records) {
      Boolean isNewRecord = !oldMap.containsKey(record.Id);
      Boolean isFieldValueUpdated =
        oldMap.containsKey(record.Id) &&
        (RecordComparisonUtil.fieldWasChanged(
          record,
          oldMap.get(record.Id),
          Interaction.Name
        ) ||
        RecordComparisonUtil.fieldWasChanged(
          record,
          oldMap.get(record.Id),
          Interaction.InteractionType
        ));

      if (isNewRecord || isFieldValueUpdated) {
        updatedInteractions.add(record);
      }
    }
    return updatedInteractions;
  }

  @testVisible
  private static void updateInteractionName(
    List<Interaction> updatedInteractions,
    Map<Id, Interaction> oldMap
  ) {
    for (Interaction record : updatedInteractions) {
      if (oldMap.containsKey(record.Id)) {
        String oldChannelName = oldMap.get(record.Id).InteractionType;

        //gets the index of the last occurence of channel
        Integer index = record.Name.lastIndexOf(oldChannelName);

        //contains all the characters from name field except the old channel name
        record.Name =
          record.Name.subString(0, index) +
          record.Name.subString(index + oldChannelName.length());
      }
      record.Name = record.Name + ' ' + record.InteractionType;
    }
  }
}
