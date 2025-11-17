/**
 * @author       : Advait Yermalkar
 * @since        : 22-05-2024
 * @description  : Helper methords to to work on A_Z_Review__c Automations
 **/
public with sharing class CommercialA2ZReviewActionHelper {
  private static final String INVALID_CLG_SELECTION = 'Please select the correct CLG related to the Entity.';
  private static final String CLG_REMOVAL_NOT_ALLOWED = 'You cannot remove the CLG record from this Interaction as it is the only valid option.';

  /**
   * @description populates customer field on A2ZReviews based of Leads
   * @name assignCustomersFromLeads
   * @param reviews
   * @param leadsMap
   **/
  public static void assignCustomersFromLeads(
    List<A_Z_Review__c> reviews,
    Map<Id, Lead> leadsMap
  ) {
    for (A_Z_Review__c currReview : reviews) {
      currReview.Customer__c = leadsMap
        ?.get(currReview.Lead__c)
        ?.FinServ__RelatedAccount__c;
    }
  }

  /**
   * @description populates customer field on A2ZReviews based of Opportunities
   * @name assignCustomersFromOpportunities
   * @param reviews
   * @param oppsMap
   **/
  public static void assignCustomersFromOpportunities(
    List<A_Z_Review__c> reviews,
    Map<Id, Opportunity> oppsMap
  ) {
    for (A_Z_Review__c currReview : reviews) {
      currReview.Customer__c = oppsMap
        ?.get(currReview.Opportunity__c)
        ?.AccountId;
    }
  }

  /**
   * @description : set business owner
   * @name : setBusinessOwner
   * @param records List of A-Z records
   * @param individualAccountIds set of account ids
   */
  public static void setBusinessOwner(
    List<A_Z_Review__c> records,
    Set<Id> individualAccountIds
  ) {
    for (A_Z_Review__c rec : records) {
      if (!individualAccountIds.contains(rec.Customer__c)) {
        continue;
      }
      rec.Existing_Business_Owner__c = 'Yes';
      rec.Business_Owner__c = rec.Customer__c;
      rec.Business_Contact__c = null;
    }
  }

  /**
   * @description : This is used to validate the CLG association on Lead
   * @param filteredA2ZList Lead records
   * @param accMap Map of Account
   * @param accIdToClgIdsMap Map of account Id to related CLG Id map
   */
  public static void validateAndPopulateCLGInfo(
    List<A_Z_Review__c> filteredA2ZList,
    Map<Id, Account> accMap,
    Map<Id, Set<Id>> accIdToClgIdsMap
  ) {
    String selectAnyCLGErrorMsg = System.Label.Select_Any_CLG_Error_Message;
    String selectRelatedCLGErrorMsg = System.Label.Select_Related_CLG_Error_Message;
    String noCLGAvailableErrorMsg = System.Label.No_CLG_for_Customer;
    for (A_Z_Review__c a2zReviewRecord : filteredA2ZList) {
      Set<Id> clgIdsSet = accIdToClgIdsMap.get(a2zReviewRecord.Customer__c) ??
        new Set<Id>();

      if (a2zReviewRecord.CLGCustomer__c == null) {
        if (!clgIdsSet.isEmpty()) {
          a2zReviewRecord.CLGCustomer__c.addError(selectAnyCLGErrorMsg);
        }
        continue;
      }
      if (clgIdsSet.isEmpty()) {
        a2zReviewRecord.CLGCustomer__c.addError(noCLGAvailableErrorMsg);
        continue;
      }
      if (!clgIdsSet.contains(a2zReviewRecord.CLGCustomer__c)) {
        a2zReviewRecord.CLGCustomer__c.addError(selectRelatedCLGErrorMsg);
        continue;
      }
      setValueFromAccount(
        a2zReviewRecord,
        accMap.get(a2zReviewRecord.CLGCustomer__c)
      );
    }
  }

  /**
   * @description : This is used to populate the CLG Info on A_Z_Review__c
   * @param filteredA2ZReviewList A_Z_Review__c records
   * @param accMap Map of Account
   * @param accIdToClgIdAARMap Map of account Id to related CLG Id map
   */
  public static void populateClgInfoOnA2ZReview(
    List<A_Z_Review__c> filteredA2ZReviewList,
    Map<Id, Account> accMap,
    Map<Id, Map<Id, FinServ__AccountAccountRelation__c>> accIdToClgIdAARMap
  ) {
    for (A_Z_Review__c a2zReviewRecord : filteredA2ZReviewList) {
      Account accRec = accMap.get(a2zReviewRecord.Customer__c);
      Boolean isClgAccount = accRec?.RecordTypeId == RTAccount.clgAccount;
      Boolean isAccountInMap = accIdToClgIdAARMap.containsKey(
        a2zReviewRecord.Customer__c
      );

      if (isClgAccount) {
        setValueFromAccount(a2zReviewRecord, isAccountInMap ? null : accRec);
        continue;
      }
      if (!isAccountInMap) {
        //when customer = org and no related CLG present then nullify CLG fields
        setValueFromAccount(a2zReviewRecord, null);
        continue;
      }
      Map<Id, FinServ__AccountAccountRelation__c> clgIdToAARMap = accIdToClgIdAARMap.get(
        a2zReviewRecord.Customer__c
      );
      if (clgIdToAARMap.size() != 1) {
        setValueFromAccount(a2zReviewRecord, null);
        continue;
      }
      FinServ__AccountAccountRelation__c aar = clgIdToAARMap.values()[0];
      setValueFromAccount(a2zReviewRecord, aar.FinServ__RelatedAccount__r);
    }
  }

  /**
   * @description : This is used to populate the CLG and CPID Info on Lead from Account
   * @param a2zReviewRecord A_Z_Review__c record
   * @param accRecord Account record
   */
  public static void setValueFromAccount(
    A_Z_Review__c a2zReviewRecord,
    Account accRecord
  ) {
    a2zReviewRecord.CLGCustomer__c = accRecord?.Id;
  }
}
