/**
 * @author Afreen Khan, Olivier Saier
 * @since 03/2021
 * @description Contains Complaints Assignment rules conditions
 * @group IDR(Internal Dispute Resolution)
 * @runTests IDRCaseAssignmentRulesTest
 * CyclomaticComplexity Surpressed : The complexity of this test class is more than it is expected.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
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
        Product_Family__c oProductFamily = productFamilyMap.get(
          c.IDR_Product_Family__c
        );
        c.OwnerId = IDRCaseAssignmentRules.getOwnerId(
          c,
          oProductFamily,
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
    Map<String, Product_Family__c> categoryMap = getProductCategory(cases);

    for (Case c : cases) {
      Case oldCase = (oldMap != null ? oldMap.get(c.Id) : null);
      if (
        IDRCaseActions.isIDRComplaintType(c) &&
        c.Product__c != null &&
        (oldCase == null ||
        oldCase.Product__c != c.Product__c ||
        IDRCaseActions.isANZPlusComplaintConvertedToIDR(oldCase, c))
      ) {
        c.IDR_Product_Family__c = (productMap.get(c.Product__c))
          ?.IDR_Product_Family__c;
        c.IDR_Product_Category__c = (productMap.get(c.Product__c))
          ?.IDR_Product_Family__r.IDR_ANZ_com_Product_Category__c;
      } else if (
        c.RecordTypeId == IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID &&
        c.IDR_Product_Category__c != null &&
        (oldCase == null ||
        oldCase.IDR_Product_Category__c != c.IDR_Product_Category__c) &&
        c.Origin != GetHelpConstants.ANZ_PLUS_WEB_ORIGIN
      ) {
        c.IDR_Product_Family__c = (categoryMap.get(c.IDR_Product_Category__c))
          .Id;
      }
    }
  }

  /**
   * @description Assign cases that aren't escalated. Do this after any prior work has been done.
   * @param lstCases list of cases being updated
   * @param mpOldCases map of old version of cases
   */
  public static void assignUnescalatedCases(
    List<Case> lstCases,
    Map<Id, Case> mpOldCases
  ) {
    Case oOldCase;
    List<Case> lstUpdates = new List<Case>();
    Id idOwner;
    for (Case oCase : lstCases) {
      if (IDRCaseActions.isIDRComplaintType(oCase)) {
        oOldCase = (mpOldCases != null ? mpOldCases.get(oCase.Id) : null);
        idOwner = IDRCaseAssignmentRules.getOwnerId(oCase, oOldCase);
        if (oCase.OwnerId != idOwner) {
          lstUpdates.add(new Case(Id = oCase.Id, OwnerId = idOwner));
        }
      }
    }
    if (!lstUpdates.isEmpty()) {
      if (
        Case.SObjectType.getDescribe().isUpdateable() &&
        Schema.SObjectType.Case.fields.OwnerId.isUpdateable()
      ) {
        update lstUpdates;
      } else {
        CommonUtil.logAndThrowIAE(
          'IDRCaseAssignmentRules',
          'assignUnescalatedCases',
          'Not enough permissions to update Case.'
        );
      }
    }
  }

  /**
   * @description method to run the Case assignment rules conditions
   * @param rec case record
   * @param oProductFamily Product_Family__c object that case relates to. For accessing Name and Workbasket
   * @param oldCase old record of case
   * NcssMethodCount Suppressed : To have all the code lines together in one place. Code is a series of rules applied in order.
   * @return Queue Id
   */
  @SuppressWarnings('PMD.NcssMethodCount')
  private static Id getOwnerId(
    Case rec,
    Product_Family__c oProductFamily,
    Case oldCase
  ) {
    String productWorkbasketName = oProductFamily?.IDR_Workbasket__c;
    String strProductFamily = oProductFamily?.Name;
    //rules to run only on escalation
    if (
      rec.Status == IDRConstants.ESCALATED_STATUS &&
      (oldCase == null ||
      oldCase.Status != IDRConstants.ESCALATED_STATUS ||
      (oldCase.Status == rec.Status &&
      oldCase.RecordTypeId != rec.RecordTypeId))
    ) {
      //CEO or Board
      if (rec.Origin == '9' || rec.Origin == '10') {
        return QUEUE_MAP.get('IDR_CEO');
      }

      // Hardship
      if (rec.Type == '4' || rec.Type == '17') {
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

      System.debug('Product Family: ' + strProductFamily);
      if (rec.Origin == IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED) {
        if (
          strProductFamily != null &&
          strProductFamily == 'Insurance/wealth products'
        ) {
          return QUEUE_MAP.get('EDR_Wealth');
        }
        return QUEUE_MAP.get('EDR_Early_Resolution');
      }

      //Credit Reporting
      if (
        rec.Type == '19' ||
        rec.IDR_Issue_Type_2__c == '19' ||
        rec.IDR_Issue_Type_3__c == '19'
      ) {
        return QUEUE_MAP.get('CCR_Complaints');
      }

      // IDR ANZ Plus Rule #5 needs to be applied before Early Resolution Rule #7
      if (
        productWorkbasketName != null &&
        productWorkbasketName == 'IDR_ANZ_Plus'
      ) {
        return QUEUE_MAP.get(productWorkbasketName);
      }

      // Fraud & Scams
      if (rec.Type == '14') {
        return QUEUE_MAP.get('IDR_Spare'); // IDR Disputes & Scams
      }

      // Early Resolution
      if (rec.Type == '13' || rec.Type == '12' || rec.Type == '9') {
        return QUEUE_MAP.get('IDR_Early_Resolution');
      }

      //Product-based rules
      if (productWorkbasketName != null) {
        return QUEUE_MAP.get(productWorkbasketName);
      }

      //Default workbasket
      return QUEUE_MAP.get('IDR_Early_Resolution');
    }

    //Not escalated, don't change owner
    return rec.OwnerId;
  }

  /**
   * @description get OwnerId without product workbasket
   * @param rec Case record
   * @param oldCase Previous version of Case record
   *
   * @return Calculated Owner Id
   */
  private static Id getOwnerId(Case rec, Case oldCase) {
    if (
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
    if (Group.SObjectType.getDescribe().isQueryable()) {
      queueList = [
        SELECT Id, DeveloperName
        FROM Group
        WHERE
          DeveloperName IN :workBasketNames
          AND Type = :IDRCaseActions.QUEUE_TYPE
      ];
    }
    if (!queueList.isEmpty()) {
      for (Group queueRec : queueList) {
        queueMap.put(queueRec.DeveloperName, queueRec.Id);
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
    if (Product2.SObjectType.getDescribe().isQueryable()) {
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
    List<Id> familyIds = new List<Id>();
    for (Case c : cases) {
      if (c.IDR_Product_Family__c != null) {
        familyIds.add(c.IDR_Product_Family__c);
      }
    }
    Map<Id, Product_Family__c> productFamilies = new Map<Id, Product_Family__c>();
    if (
      Product_Family__c.SObjectType.getDescribe().isQueryable() &&
      familyIds.size() > 0
    ) {
      for (Product_Family__c p : [
        SELECT Name, IDR_ANZ_com_Product_Category__c, IDR_Workbasket__c
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
  private static Map<String, Product_Family__c> getProductCategory(
    Case[] cases
  ) {
    String[] categories = new List<String>();
    for (Case c : cases) {
      if (
        c.RecordTypeId == IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID &&
        c.IDR_Product_Category__c != null
      ) {
        categories.add(c.IDR_Product_Category__c);
      }
    }
    Map<String, Product_Family__c> productFamilyMap = new Map<String, Product_Family__c>();
    if (Product_Family__c.SObjectType.getDescribe().isQueryable()) {
      for (Product_Family__c p : [
        SELECT Id, IDR_ANZ_com_Product_Category__c
        FROM Product_Family__c
        WHERE IDR_ANZ_com_Product_Category__c IN :categories
      ]) {
        productFamilyMap.put(p.IDR_ANZ_com_Product_Category__c, p);
      }
    }
    return productFamilyMap;
  }
}
