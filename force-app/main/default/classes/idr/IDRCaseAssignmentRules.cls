/**
 * @author Afreen Khan, Olivier Saier
 * @since 03/2021
 * @description Contains Complaints Assignment rules conditions
 * @group IDR(Internal Dispute Resolution)
 */
@SuppressWarnings(
  'PMD.ApexCRUDViolation,PMD.CyclomaticComplexity, PMD.StdCyclomaticComplexity, PMD.CognitiveComplexity'
)
public with sharing class IDRCaseAssignmentRules {
  private static final Map<String, Id> QUEUE_MAP = getWorkbaskets();
  /**
   * @description method to call the Case assignment rules
   * @param cases Records in the current context
   * @param oldMap old map of case record in current trigger context
   */
  public static void assignCases(Case[] cases, Map<Id, Case> oldMap) {
    Map<Id, Product_Family__c> productFamilyMap = getProductFamilies(cases);

    for (Case c : cases) {
      if (IDRCaseActions.isIDRComplaintType(c)) {
        Case oldCase = (oldMap != null ? oldMap.get(c.Id) : null);
        String productWorkbasketName = productFamilyMap.get(
            c.IDR_Product_Family__c
          )
          ?.IDR_Workbasket__c;
        c.OwnerId = IDRCaseAssignmentRules.getOwnerId(
          c,
          productWorkbasketName,
          oldCase
        );
      }
    }
  }
  /**
   * @description method to Assign product family
   * @param cases Records in the current context
   * @param oldMap old map of case record in current trigger context
   */
  public static void assignProductFamily(Case[] cases, Map<Id, Case> oldMap) {
    Map<Id, Product2> productMap = getProductNames(cases);
    Map<string, Product_Family__c> categoryMap = getProductCategory(Cases);

    for (Case c : cases) {
      Case oldCase = (oldMap != null ? oldMap.get(c.Id) : null);
      if (
        IDRCaseActions.isIDRComplaintType(c) &&
        c.Product__c != null &&
        (oldCase == null ||
        oldCase.Product__c != c.Product__c)
      ) {
        c.IDR_Product_Family__c = (productMap.get(c.Product__c))
          ?.IDR_Product_Family__c;
        c.IDR_Product_Category__c = (productMap.get(c.Product__c))
          ?.IDR_Product_Family__r.IDR_ANZ_com_Product_Category__c;
      } else if (
        c.RecordTypeId == IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID &&
        c.IDR_Product_Category__c != null &&
        (oldCase == null ||
        oldCase.IDR_Product_Category__c != c.IDR_Product_Category__c)
      ) {
        c.IDR_Product_Family__c = (categoryMap.get(c.IDR_Product_Category__c))
          .Id;
      }
    }
  }

  /**
   * @description method to run the Case assignment rules conditions
   * @param rec case record
   * @param productWorkbasketName name of the product the case relates to
   * @param oldCase old record of case
   * @return Queue Id
   */
  private static ID getOwnerId(
    Case rec,
    String productWorkbasketName,
    Case oldCase
  ) {
    //rules to run only on escalation
    if (
      rec.Status == IDRConstants.ESCALATED_STATUS &&
      (oldCase == null ||
      oldCase.Status != IDRConstants.ESCALATED_STATUS ||
      (oldCase.Status == rec.Status &&
      oldCase.recordTypeId != rec.recordTypeId))
    ) {
      //CEO or Board
      if (rec.Origin == '9' || rec.Origin == '10') {
        return QUEUE_MAP.get('IDR_CEO');
      }

      //Priority
      if (
        rec.Priority == 'Customer in Collections' ||
        rec.Priority == 'Financial Hardship'
      ) {
        if (rec.Origin == IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED) {
          return QUEUE_MAP.get('Specialised_Early_Resolution_Hardship');
        } else {
          return QUEUE_MAP.get('IDR_Hardship');
        }
      }
      //Inappropriate lending/maladministration
      if (
        rec.IDR_Subsequent_Issue__c == '38' ||
        rec.IDR_Subsequent_Issue_2__c == '38' ||
        rec.IDR_Subsequent_Issue_3__c == '38'
      ) {
        if (rec.Origin == IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED) {
          return QUEUE_MAP.get('Specialised_EarlyRes_Responsible_Lending');
        } else {
          return QUEUE_MAP.get('IDR_Responsible_Lending');
        }
      }

      //Credit Reporting
      if (
        rec.Origin != IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED &&
        (rec.Type == '19' ||
        rec.IDR_Issue_Type_2__c == '19' ||
        rec.IDR_Issue_Type_3__c == '19')
      ) {
        return QUEUE_MAP.get('CCR_Complaints');
      }

      //Product-based rules
      if (
        rec.Origin != IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED &&
        productWorkbasketName != null
      ) {
        return QUEUE_MAP.get(productWorkbasketName);
      }
      //Default workbasket
      if (rec.Origin == IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED) {
        return QUEUE_MAP.get('EDR_Early_Resolution');
      } else {
        return QUEUE_MAP.get('IDR_Early_Resolution');
      }
    } else if (
      (rec.Status == IDRConstants.PROVISIONALLY_CLOSED_STATUS ||
      rec.Status == IDRConstants.CLOSED_STATUS) &&
      (oldCase == null ||
      oldCase.Status != IDRConstants.ESCALATED_STATUS) &&
      ((rec.Type == '4' &&
      IDRConstants.SUB_ISSUE_TYPE_HARDSHIP.contains(
        rec.IDR_Subsequent_Issue__c
      )) ||
      (rec.IDR_Issue_Type_2__c == '4' &&
      IDRConstants.SUB_ISSUE_TYPE_HARDSHIP.contains(
        rec.IDR_Subsequent_Issue_2__c
      )) ||
      (rec.IDR_Issue_Type_3__c == '4' &&
      IDRConstants.SUB_ISSUE_TYPE_HARDSHIP.contains(
        rec.IDR_Subsequent_Issue_3__c
      ))) &&
      (FeatureManagement.checkPermission('IDR_Level_2') ||
      FeatureManagement.checkPermission('IDR_Level_3'))
    ) {
      //To auto assign cases to the workbasket 'Hardship_IDR_Letter'
      return QUEUE_MAP.get('Hardship_IDR_Letter');
    }

    //Not escalated, don't change owner
    return rec.OwnerId;
  }

  /**
   * @description method to get a map of Cmos workbasket queues, API names and Ids
   * @return a map of workbasket queues, API names and Ids
   */
  public static Map<String, Id> getWorkbaskets() {
    return getWorkbaskets(IDRConstants.workBasketNames);
  }

  /**
   * @description method to get a map of ANZx workbasket queues, API names and Ids
   * @return a map of workbasket queues, API names and Ids
   */
  public static Map<String, Id> getAnzxWorkbaskets() {
    return getWorkbaskets(GetHelpConstants.workBasketNames);
  }

  /**
   * @description method to get a map of workbasket queues, API names and Ids
   * @param workBasketNames list of work basket names that can be included in the list
   * @return a map of workbasket queues, API names and Ids
   */
  public static Map<String, Id> getWorkbaskets(List<String> workBasketNames) {
    Map<String, Id> queueMap = new Map<String, Id>();
    Group[] queueList = new List<Group>();
    if (Group.sObjectType.getDescribe().isQueryable()) {
      queueList = [
        SELECT id, developername
        FROM Group
        WHERE
          developername IN :workBasketNames
          AND Type = :IDRCaseActions.QUEUE_TYPE
      ];
    }
    if (!queueList.isEmpty()) {
      for (Group queueRec : queueList) {
        queueMap.put(queueRec.developername, queueRec.Id);
      }
    }
    return queueMap;
  }

  /**
   * @description Method to get a map of product families by product Ids related to cases
   * @param cases List of cases in context, with or without a parent product
   * @return A map of product names by product Ids
   */
  private static Map<Id, Product2> getProductNames(Case[] cases) {
    Id[] productIds = new List<Id>();
    for (Case c : cases) {
      if (IDRCaseActions.isIDRComplaintType(c)) {
        productIds.add(c.Product__c);
      }
    }
    Map<Id, Product2> productMap = new Map<Id, Product2>();
    if (Product2.sObjectType.getDescribe().isQueryable()) {
      for (Product2 p : [
        SELECT
          Name,
          IDR_Product_Family__c,
          IDR_Product_Family__r.IDR_ANZ_com_Product_Category__c
        FROM Product2
        WHERE Id IN :productIds
      ]) {
        productMap.put(p.Id, p);
      }
    }
    return productMap;
  }
  /**
   * @description Method to get a map of product families related to cases
   * @param cases List of cases in context
   * @return A map of product family by Ids
   */
  private static Map<Id, Product_Family__c> getProductFamilies(Case[] cases) {
    list<Id> familyIds = new List<Id>();
    for (Case c : cases) {
      if (c.IDR_Product_Family__c != null) {
        familyIds.add(c.IDR_Product_Family__c);
      }
    }
    Map<Id, Product_Family__C> productFamilies = new Map<Id, Product_Family__c>();
    if (
      Product_Family__c.sObjectType.getDescribe().isQueryable() &&
      familyIds.size() > 0
    ) {
      for (Product_Family__c p : [
        SELECT Name, IDR_ANZ_com_Product_Category__c, IDR_WorkBasket__c
        FROM Product_Family__c
        WHERE Id IN :familyIds
      ]) {
        productFamilies.put(p.Id, p);
      }
    }
    return productFamilies;
  }
  /**
   * @description Method to get a map of product families  related to cases based on product category
   * @param cases List of cases in context
   * @return A map of product family by product categories
   */
  private static Map<string, Product_Family__c> getProductCategory(
    Case[] cases
  ) {
    string[] categories = new List<string>();
    for (Case c : cases) {
      if (
        c.RecordTypeId == IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID &&
        c.IDR_Product_Category__c != null
      ) {
        categories.add(c.IDR_Product_Category__c);
      }
    }
    Map<string, Product_Family__c> productFamilyMap = new Map<string, Product_family__c>();
    if (Product_Family__c.sObjectType.getDescribe().isQueryable()) {
      for (Product_Family__c p : [
        SELECT ID, IDR_ANZ_com_Product_Category__c
        FROM Product_Family__c
        WHERE IDR_ANZ_com_Product_Category__c IN :categories
      ]) {
        productFamilyMap.put(p.IDR_ANZ_com_Product_Category__c, p);
      }
    }
    return productFamilyMap;
  }
}
