/**
 * @author Ayushi G
 * @since  05/2024
 * @group CCRM (Commercial CRM)
 * @description CommercialInteractionActions is class to handle all the CCRM (Commercial CRM) Actions
 */
public with sharing class CommercialInteractionActions {
  private static final String INVALID_CLG_SELECTION = 'Please select the correct CLG related to the Entity.';
  private static final String CLG_REMOVAL_NOT_ALLOWED = 'You cannot remove the CLG record from this Interaction as it is the only valid option.';
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
    try {
      List<SObjectField> fieldList = Schema.SObjectType.Interaction.fields.getMap()
        .values();
      Set<SObjectField> richTextFieldSet = CommercialCommonUtil.getRichTextFields(
        fieldList
      );
      CommercialCommonUtil.restrictImages(records, oldMap, richTextFieldSet);
    } catch (Exception e) {
      Logger.error('Error while restrict images on Interaction', e).save();
    }
  }

  /**
   * @description This method will perform redaction on sensitive data in the provided records.
   * @name performRedaction
   * @param records from the trigger
   */
  public static void performRedaction(List<Interaction> records) {
    try {
      TextUtils.maskSObjectDataANZExtended(records, 'Comment__c');
    } catch (Exception e) {
      Logger.error('Error while redacting data on Interaction', e).save();
    }
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

    populateCLGForInteraction(records, customerToCLGsMap, accountMap);
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

    validateCLGAccountsAgainstCustomer(
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

  /**
   * @description Auto-populate the CLGCustomer__c field on Interaction records based on relationship type.
   * @param records The list of Interaction records
   * @param customerToCLGsMap The map of customer to CLG accounts
   * @param accountMap The map of Account Id to Account records
   */
  @TestVisible
  private static void populateCLGForInteraction(
    List<Interaction> records,
    Map<Id, Set<Id>> customerToCLGsMap,
    Map<Id, Account> accountMap
  ) {
    for (Interaction record : records) {
      Set<Id> validCLGs = customerToCLGsMap.get(record.AccountId);

      // Case 1: One related CLG – assign it
      if (validCLGs != null && validCLGs.size() == 1) {
        record.CLGCustomer__c = validCLGs.iterator().next();
        continue;
      }

      // Case 2: No related CLGs – check if customer itself is CLG
      if (
        (validCLGs == null || validCLGs.isEmpty()) &&
        accountMap.containsKey(record.AccountId)
      ) {
        Account acc = accountMap.get(record.AccountId);
        if (acc.RecordTypeId == RTAccount.clgAccount) {
          record.CLGCustomer__c = record.AccountId;
        }
      }
    }
  }

  /**
   * @description Validate CLG account selection against customer.
   * @param records The list of Interaction records
   * @param customerToCLGsMap The map of customer to CLG accounts
   */
  @TestVisible
  private static void validateCLGAccountsAgainstCustomer(
    List<Interaction> records,
    Map<Id, Set<Id>> customerToCLGsMap
  ) {
    List<Interaction> clgRemovalErrors = new List<Interaction>();
    for (Interaction record : records) {
      Set<Id> validCLGs = customerToCLGsMap.get(record.AccountId);
      if (validCLGs == null || validCLGs.isEmpty()) {
        // No CLGs defined - allow self-assignment or no validation here
        continue;
      }
      // Check invalid CLG selection
      if (
        record.CLGCustomer__c != null &&
        !validCLGs.contains(record.CLGCustomer__c)
      ) {
        record.addError(INVALID_CLG_SELECTION);
      }
      // Check CLG removal not allowed if only one CLG exists and field is cleared
      if (validCLGs.size() == 1 && record.CLGCustomer__c == null) {
        clgRemovalErrors.add(record);
      }
    }
    ListUtil.addError(clgRemovalErrors, CLG_REMOVAL_NOT_ALLOWED);
  }
}
