/**
 * @author Naman Garg
 * @since  Nov 2024
 * @description This is the action class for CommercialOpportunityTriggerHandler
 */
public with sharing class CommercialOpportunityActions {
  private static final CommercialOpportunityRepository OPP_REPOSITORY = (CommercialOpportunityRepository) Lib_InstanceProvider.forType(
    CommercialOpportunityRepository.class
  );

  /**
   * @description Define custom exceptions
   */
  public class CustomException extends Exception {
  }

  /**
   * @description : It will restrict the user to upload images in rich text fields
   * @name : restrictImagesInRichTextFields
   * @param records List of Opportunity records
   * @param oldMap Map of old Opportunity records
   */
  public static void restrictImagesInRichTextFields(
    List<Opportunity> records,
    Map<Id, Opportunity> oldMap
  ) {
    try {
      List<SObjectField> fieldList = Schema.SObjectType.Opportunity.fields.getMap()
        .values();
      Set<SObjectField> richTextFieldSet = CommercialCommonUtil.getRichTextFields(
        fieldList
      );
      CommercialCommonUtil.restrictImages(records, oldMap, richTextFieldSet);
    } catch (Exception e) {
      Logger.error('Error while restrict images on Opportunity', e).save();
    }
  }

  /**
   * @description This method will populate fields
   * @name populateCLG
   * @param records list of Opportunity records
   * @param oldMap map of old records
   */
  public static void populateCLG(
    List<Opportunity> records,
    Map<Id, Opportunity> oldMap
  ) {
    Set<Id> accountIdsSet = extractAccountIds(records, oldMap);
    List<FinServ__AccountAccountRelation__c> aarList = OPP_REPOSITORY.getAccountAccountRelations(
      accountIdsSet
    );

    Map<Id, FinServ__AccountAccountRelation__c> accountToAARMap = (Map<Id, FinServ__AccountAccountRelation__c>) ListUtil.mapBy(
      aarList,
      FinServ__AccountAccountRelation__c.FinServ__Account__c
    );

    populateCLGAccount(records, accountToAARMap);
  }

  /**
   * @description This method will fetch the Existing customer Id from Opportunities
   * @name fetchAccountIds
   * @param records list of Opportunity records
   * @param oldMap map of old records
   * @return Set<Id> set of account Id
   */
  @testVisible
  private static Set<Id> extractAccountIds(
    List<Opportunity> records,
    Map<Id, Opportunity> oldMap
  ) {
    if (oldMap == null) {
      return ListUtil.getIds(records, Opportunity.AccountId);
    }
    List<Opportunity> filteredOppsList = ListUtil.filter(records, oldMap)
      .changed(Opportunity.AccountId)
      .toList();

    return ListUtil.getIds(filteredOppsList, Opportunity.AccountId);
  }

  /**
   * @description This method will populate CLG account
   * @name populateCLGAccount
   * @param oppList from the trigger
   * @param accountToAARMap Map of account to AAR
   */
  public static void populateCLGAccount(
    List<Opportunity> oppList,
    Map<Id, FinServ__AccountAccountRelation__c> accountToAARMap
  ) {
    for (Opportunity oppRecord : oppList) {
      if (!accountToAARMap.containsKey(oppRecord.AccountId)) {
        continue;
      }
      FinServ__AccountAccountRelation__c aarRecord = accountToAARMap.get(
        oppRecord.AccountId
      );
      oppRecord.CLG__c = aarRecord?.FinServ__RelatedAccount__c;
    }
  }
}
