/**
 * @author       : Advait Yermalkar
 * @since        : 07-02-2025
 * @description  : Helper for CommercialInteractionActions
 **/
public with sharing class CommercialInteractionActionsHelper {
  private static final String INVALID_CLG_SELECTION = 'Please select the correct CLG related to the Entity.';
  private static final String CLG_REMOVAL_NOT_ALLOWED = 'You cannot remove the CLG record from this Interaction as it is the only valid option.';

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
    // Case 1 – Customer is a CLG → assign their own ID
    // Case 2 – Customer has exactly one related CLG → assign that CLG
    // Case 3 – Customer has multiple related CLGs → leave CLGCustomer__c blank
    // Case 4 – Customer has no related CLGs and is not a CLG → leave CLGCustomer__c blank
    for (Interaction record : records) {
      Account customer = accountMap.get(record.AccountId);

      // Case 1 – Customer is a CLG → assign their own ID
      if (customer?.RecordTypeId == RTAccount.clgAccount) {
        record.CLGCustomer__c = record.AccountId;
        continue;
      }

      // Case 2 – Customer has exactly one related CLG → assign that CLG
      Set<Id> relatedCLGs = customerToCLGsMap.get(record.AccountId);
      if (relatedCLGs?.size() == 1) {
        record.CLGCustomer__c = new List<Id>(relatedCLGs)[0];
      }
      // Case 3 & 4 are implicitly handled by skipping assignment
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
   * @description mapping of customer to their related CLG accounts.
   * @param relatedCLGAccounts The list of List<FinServ__AccountAccountRelation__c>
   * @return Map<Id, Set<Id>>
   */
  public static Map<Id, Set<Id>> mapCustomerToCLGAccounts(
    List<FinServ__AccountAccountRelation__c> relatedCLGAccounts
  ) {
    Map<Id, Set<Id>> customerToCLGAccountsMap = new Map<Id, Set<Id>>();

    for (FinServ__AccountAccountRelation__c aar : relatedCLGAccounts) {
      if (!customerToCLGAccountsMap.containsKey(aar.FinServ__Account__c)) {
        customerToCLGAccountsMap.put(aar.FinServ__Account__c, new Set<Id>());
      }
      customerToCLGAccountsMap.get(aar.FinServ__Account__c)
        .add(aar.FinServ__RelatedAccount__c);
    }
    return customerToCLGAccountsMap;
  }

  /**
   * @description Get the customer associated with a list of opportunities.
   * @param opps
   * @return Map<Id, Id>
   **/
  public static Map<Id, Id> getCustomerAssociatedWithOpp(
    List<Opportunity> opps
  ) {
    Map<Id, Id> oppIdToCustomerIdMap = new Map<Id, Id>();

    for (Opportunity opp : opps) {
      oppIdToCustomerIdMap.put(opp.Id, opp.AccountId);
    }
    return oppIdToCustomerIdMap;
  }

  /**
   * @description Update the customer on interaction records based on opportunity mapping.
   * @param records
   * @param oppIdToCustomerIdMap
   **/
  public static void updateCustomerOnInteraction(
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
}
