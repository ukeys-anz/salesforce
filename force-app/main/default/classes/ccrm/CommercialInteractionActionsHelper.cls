/**
 * @author       : Advait Yermalkar
 * @since        : 07-02-2025
 * @description  : Helper for CommercialInteractionActions
 **/
public with sharing class CommercialInteractionActionsHelper {
  private static final String INVALID_CLG_SELECTION = 'Please select the correct CLG related to the Entity.';
  private static final String CLG_REMOVAL_NOT_ALLOWED = 'You cannot remove the CLG record from this Interaction as it is the only valid option.';

  /**
   * @description get opportunity Ids related to Interactions
   * @param records
   * @param oldMap
   * @return Set<Id>
   **/
  public static Set<Id> getOppsIdsAssociatedWithInteractions(
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

  /**
   * @description updates interaction name with the new channel name combination
   * @param updatedInteractions
   * @param oldMap
   **/
  public static void updateInteractionName(
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
   * @description Auto-populate the CLGCustomer__c field on Interaction records based on relationship type.
   * @param records The list of Interaction records
   * @param customerToCLGsMap The map of customer to CLG accounts
   * @param accountMap The map of Account Id to Account records
   */
  public static void populateCLGForInteraction(
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
  public static void validateCLGAccountsAgainstCustomer(
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

  /**
   * @description Get a list of interactions that have updated names or channel information.
   * @param records The list of Interaction records to check.
   * @param oldMap A map of old Interaction records for comparison.
   * @return List<Interaction> A list of updated Interaction records.
   **/
  public static List<Interaction> getUpdatedNameOrChannelInteractions(
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
}
