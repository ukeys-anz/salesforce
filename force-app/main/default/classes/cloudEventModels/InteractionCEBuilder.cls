/**
 * @author       : Advait Yermalkar
 * @since        : 07-04-2024
 * @description  : This class helps to generate Interaction Cloud Event Model objects
 *                 Cloud Events are Published from Interaction trigger After Insert and After Update
 **/
public with sharing class InteractionCEBuilder {
  private static final CCRMInteractionActionsRepository IA_REPOSITORY = (CCRMInteractionActionsRepository) Lib_InstanceProvider.forType(
    CCRMInteractionActionsRepository.class
  );

  /**
   * @description Gets Related Ids from Interactions
   * @param theInteractions
   * @return Map<String, Set<Id>>
   **/
  public static Map<String, Set<Id>> getRelatedIds(
    List<Interaction> theInteractions
  ) {
    Map<String, Set<Id>> relatedIdsMap = new Map<String, Set<Id>>();
    Set<Id> relatedCustomerIds = new Set<Id>();
    Set<Id> relatedOppIds = new Set<Id>();
    Set<Id> relatedFinAccountIds = new Set<Id>();
    Set<Id> relatedUserIds = new Set<Id>();

    for (Interaction theInteraction : theInteractions) {
      if (theInteraction.AccountId != null) {
        relatedCustomerIds.add(theInteraction.AccountId);
      }

      if (theInteraction.Opportunity__c != null) {
        relatedOppIds.add(theInteraction.Opportunity__c);
      }

      if (theInteraction.Financial_Account__c != null) {
        relatedFinAccountIds.add(theInteraction.Financial_Account__c);
      }

      if (theInteraction.OwnerId != null) {
        relatedUserIds.add(theInteraction.OwnerId);
      }

      if (theInteraction.LastModifiedById != null) {
        relatedUserIds.add(theInteraction.LastModifiedById);
      }
    }
    relatedIdsMap.put('Account', relatedCustomerIds);
    relatedIdsMap.put('FinServ__FinancialAccount__c', relatedFinAccountIds);
    relatedIdsMap.put('Opportunity', relatedOppIds);
    relatedIdsMap.put('User', relatedUserIds);

    return relatedIdsMap;
  }

  /**
   * @description create cloud events for Interactions
   * @param theInteractions
   * @param interactionCEWrapper
   * @param actionCode
   * @return List<CloudEventModel>
   **/
  public static List<CloudEventModel> createCloudEvents(
    List<Interaction> theInteractions,
    InteractionCEBuilder.InteractionCEWrapper interactionCEWrapper,
    String actionCode
  ) {
    List<CloudEventModel> cloudEvents = new List<CloudEventModel>();

    if (interactionCEWrapper.theAccountMap.size() == 0) {
      return cloudEvents;
    }

    for (Interaction currentInteraction : theInteractions) {
      Account relatedCustomer = interactionCEWrapper.theAccountMap.get(
        currentInteraction.AccountId
      );

      User relatedUser = interactionCEWrapper.theUserMap.get(
        currentInteraction.LastModifiedById
      );
      String operatorLanId = relatedUser.Lan_Id__c;

      User relatedOwner = interactionCEWrapper.theUserMap.get(
        currentInteraction.OwnerId
      );
      CloudEventModel.UserModel ownerModel = new CloudEventModel.UserModel();
      ownerModel.lanId = relatedUser.Lan_Id__c;
      ownerModel.name = '';
      ownerModel.email = '';

      CloudEventModel.CloudEventSystemModel systemdata = new CloudEventModel.CloudEventSystemModel(
        currentInteraction.lastModifiedDate,
        relatedUser
      );

      //create Cap cloud Event
      if (
        currentInteraction.category__c ==
        CCRMConstants.INTER_CAT_CAPDIARYCOMMENTS &&
        actionCode == CCRMConstants.ACTION_CODE_CREATE
      ) {
        FinServ__FinancialAccount__c relatedFinAccount = interactionCEWrapper.theFinAccountMap.get(
          currentInteraction.Financial_Account__c
        );

        InteractionCloudEventModel.InteractionCloudEventDataModel capDataModel = new InteractionCloudEventModel.InteractionCloudEventDataModel(
          currentInteraction,
          relatedCustomer,
          relatedFinAccount,
          ownerModel
        );

        CloudEventModel ceModel = new InteractionCloudEventModel(
          currentInteraction,
          capDataModel,
          systemdata,
          actionCode
        );
        cloudEvents.add(ceModel);
      }

      //create general cloud Event
      if (
        currentInteraction.category__c !=
        CCRMConstants.INTER_CAT_CAPDIARYCOMMENTS
      ) {
        Opportunity relatedOpportunity = interactionCEWrapper.theOpportunityMap.get(
          currentInteraction.Opportunity__c
        );

        InteractionCloudEventModel.InteractionCloudEventDataModel interactionDataModel = new InteractionCloudEventModel.InteractionCloudEventDataModel(
          currentInteraction,
          relatedCustomer,
          relatedOpportunity,
          ownerModel
        );

        CloudEventModel ceModel = new InteractionCloudEventModel(
          currentInteraction,
          interactionDataModel,
          systemdata,
          actionCode
        );
        cloudEvents.add(ceModel);
      }
    }

    return cloudEvents;
  }

  /**
   * @description Wrapper class for the Account, Opportunity, User, and Financial Account data Map
   **/
  public class InteractionCEWrapper {
    public Map<Id, Account> theAccountMap;
    public Map<Id, Opportunity> theOpportunityMap;
    public Map<Id, User> theUserMap;
    public Map<Id, FinServ__FinancialAccount__c> theFinAccountMap;

    /**
     * @description No Argument Constructor
     **/
    public InteractionCEWrapper() {
    }

    /**
     * @description constructor for InteractionCEWrapper
     * @param interactions
     **/
    public InteractionCEWrapper(List<Interaction> interactions) {
      Map<String, Set<Id>> relatedIdsMap = InteractionCEBuilder.getRelatedIds(
        interactions
      );

      this.theAccountMap = new Map<Id, Account>(
        IA_REPOSITORY.getCustomers(relatedIdsMap.get('Account'))
      );

      this.theOpportunityMap = new Map<Id, Opportunity>(
        IA_REPOSITORY.getOpportunities(relatedIdsMap.get('Opportunity'))
      );

      this.theFinAccountMap = new Map<Id, FinServ__FinancialAccount__c>(
        IA_REPOSITORY.getFinAccounts(
          relatedIdsMap.get('FinServ__FinancialAccount__c')
        )
      );

      this.theUserMap = new Map<Id, User>(
        IA_REPOSITORY.getUsers(relatedIdsMap.get('User'))
      );
    }
  }
}
