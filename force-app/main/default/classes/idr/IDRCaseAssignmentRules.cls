/**
 * @author Afreen Khan, Olivier Saier
 * @since 03/2021
 * @description Contains Complaints Assignment rules conditions
 * @group IDR(Internal Dispute Resolution)
 */
@SuppressWarnings(
  'PMD.CyclomaticComplexity, PMD.StdCyclomaticComplexity, PMD.CognitiveComplexity'
)
public with sharing class IDRCaseAssignmentRules {
  private static final Map<String, Id> QUEUE_MAP = getWorkbaskets();
  /**
   * @description method to call the Case assignment rules
   * @param cases Records in the current context
   * @param oldMap old map of case record in current trigger context
   */
  public static void assignCases(Case[] cases, Map<Id, Case> oldMap) {
    Map<Id, String> productMap = getProductNames(cases);
    for (Case c : cases) {
      if (IDRCaseActions.isIDRComplaintType(c)) {
        Case oldCase = (oldMap != null ? oldMap.get(c.Id) : null);
        String productName = c.Product__c != null
          ? productMap.get(c.Product__c)
          : null;
        c.OwnerId = IDRCaseAssignmentRules.getOwnerId(c, productName, oldCase);
      }
    }
  }

  /**
   * @description method to run the Case assignment rules conditions
   * @param rec case record
   * @param product name of the product the case relates to
   * @param oldCase old record of case
   * @return Queue Id
   */
  private static ID getOwnerId(Case rec, String product, Case oldCase) {
    //rules to run only on escalation
    if (
      rec.Status == IDRConstants.ESCALATED_STATUS &&
      (oldCase == null ||
      oldCase.Status != IDRConstants.ESCALATED_STATUS)
    ) {
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

      //CEO or Board
      if (rec.Origin == '9' || rec.Origin == '10') {
        return QUEUE_MAP.get('IDR_CEO');
      }

      //Product-based rules
      if (
        rec.Origin != IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED &&
        IDRConstants.caseAssignmentProductMap.containsKey(product)
      ) {
        return QUEUE_MAP.get(
          IDRConstants.caseAssignmentProductMap.get(product)
        );
      }
      //Default workbasket
      if (rec.Origin == IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED) {
        return QUEUE_MAP.get('EDR_Early_Resolution');
      } else {
        return QUEUE_MAP.get('IDR_Early_Resolution');
      }
    }
    //Not escalated, don't change owner
    return rec.OwnerId;
  }

  /**
   * @description method to get a map of workbasket queues, API names and Ids
   * @return a map of workbasket queues, API names and Ids
   */
  private static Map<String, Id> getWorkbaskets() {
    Map<String, Id> queueMap = new Map<String, Id>();
    Group[] queueList = new List<Group>();
    if (Group.sObjectType.getDescribe().isQueryable()) {
      queueList = [
        SELECT id, developername
        FROM Group
        WHERE
          developername IN :IDRConstants.workBasketNames
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
   * @description Method to get a map of product names by product Ids related to cases
   * @param cases List of cases in context, with or without a parent product
   * @return A map of product names by product Ids
   */
  private static Map<Id, String> getProductNames(Case[] cases) {
    Id[] productIds = new List<Id>();
    for (Case c : cases) {
      productIds.add(c.Product__c);
    }
    Map<Id, String> productNamesMap = new Map<Id, String>();
    if (Product2.sObjectType.getDescribe().isQueryable()) {
      for (Product2 p : [SELECT Name FROM PRoduct2 WHERE Id IN :productIds]) {
        productNamesMap.put(p.Id, p.Name);
      }
    }
    return productNamesMap;
  }
}
