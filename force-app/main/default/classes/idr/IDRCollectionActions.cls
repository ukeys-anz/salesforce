/**
 * @author Boobalakrishnan Duraisamy
 * @since 02/2020
 * @description  IDRCollectionActions class is used to handle all collection related activities in case trigger
 */
public with sharing class IDRCollectionActions {
  /**
   * @description method to trigger collections activity in downstream systems when collections flag is turned on for a customer on a complaint.
   * @param records List of Case records in current  trigger context
   * @param oldMap old Map of Case records in current  trigger context
   */
  public static void triggerCollectionActivities(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Database.SaveResult> publishResults = new List<Database.SaveResult>();
    List<IDR_Collections_Event__e> collectionsCasesEventList = new List<IDR_Collections_Event__e>();
    for (Case c : records) {
      if (c.recordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID) {
        if (
          oldMap == null &&
          (c.Priority == IDRConstants.PRIORITY_COLLECTIONS ||
          c.Priority == IDRConstants.PRIORITY_HARDSHIP) &&
          (c.Type == IDRConstants.ISSUE_TYPE_HARDSHIP ||
          c.Type == IDRConstants.ISSUE_TYPE_COLLECTIONS ||
          c.IDR_Issue_Type_2__c == IDRConstants.ISSUE_TYPE_HARDSHIP ||
          c.IDR_Issue_Type_2__c == IDRConstants.ISSUE_TYPE_COLLECTIONS ||
          c.IDR_Issue_Type_3__c == IDRConstants.ISSUE_TYPE_HARDSHIP ||
          c.IDR_Issue_Type_3__c == IDRConstants.ISSUE_TYPE_COLLECTIONS)
        ) {
          // that means it is on insert
          collectionsCasesEventList.add(buildEvent(c, null));
          c.IDR_Stop_Collections__c = true;
        } else if (
          oldMap != null &&
          (oldMap.get(c.Id).Priority != c.Priority ||
          oldMap.get(c.Id).Type != c.Type ||
          oldMap.get(c.Id).IDR_Issue_Type_2__c != c.IDR_Issue_Type_2__c ||
          oldMap.get(c.Id).IDR_Issue_Type_3__c != c.IDR_Issue_Type_3__c) &&
          (c.Priority == IDRConstants.PRIORITY_COLLECTIONS ||
          c.Priority == IDRConstants.PRIORITY_HARDSHIP) &&
          ((c.Type == IDRConstants.ISSUE_TYPE_HARDSHIP ||
          c.Type == IDRConstants.ISSUE_TYPE_COLLECTIONS) ||
          (c.IDR_Issue_Type_2__c == IDRConstants.ISSUE_TYPE_HARDSHIP ||
          c.IDR_Issue_Type_2__c == IDRConstants.ISSUE_TYPE_COLLECTIONS) ||
          (c.IDR_Issue_Type_3__c == IDRConstants.ISSUE_TYPE_HARDSHIP ||
          c.IDR_Issue_Type_3__c == IDRConstants.ISSUE_TYPE_COLLECTIONS))
        ) {
          collectionsCasesEventList.add(buildEvent(c, oldMap.get(c.Id)));
          c.IDR_Stop_Collections__c = true;
        }
      }
    }
    if (!collectionsCasesEventList.isEmpty()) {
      publishResults = EventBus.publish(collectionsCasesEventList);
    }
    for (Integer i = 0; i < publishResults.size(); i++) {
      Database.SaveResult sr = publishResults[i];
      if (!publishResults[i].isSuccess()) {
        for (Database.Error err : publishResults[i].getErrors()) {
          Lib_SystemLog.logAPIError(
            IDRCaseActions.class.getName(),
            'Error in publishing collection platform event for Case' +
            collectionsCasesEventList[i].IDR_Complaint_Number__c,
            err.getMessage(),
            null,
            IDRCaseActions.class.getName(),
            null,
            null
          );
        }
      }
    }
  }

  /**
   * @description method to trigger collections activity in downstream systems when collections flag is turned on for a customer on a complaint.
   * @param c A case record
   * @param oldCase An old case record
   * @return Platform event record
   */
  private static IDR_Collections_Event__e buildEvent(Case c, Case oldCase) {
    IDR_Collections_Event__e collectionsEvent = new IDR_Collections_Event__e();
    collectionsEvent.IDR_Customer_Number__c = c.IDR_Customer_Number__c;
    collectionsEvent.IDR_OCV_Id__c = null; // When AR&C Customer are in SF replace this line with Account's OCV
    collectionsEvent.IDR_Complaint_Received_Date__c = c.IDR_Date_Received__c;

    if (
      c.Status == IDRConstants.RESOLVED_STATUS ||
      c.Status == IDRConstants.CLOSED_STATUS
    ) {
      collectionsEvent.IDR_Complaint_Resolved_Date__c = (c.ClosedDate == null
        ? System.now()
        : c.ClosedDate);
      if (oldCase == null) {
        collectionsEvent.IDR_Closed_On_Create__c = true;
      }
    }

    collectionsEvent.IDR_Complaint_Number__c = c.CaseNumber;
    collectionsEvent.IDR_Complaint_Status__c = c.Status;
    collectionsEvent.IDR_Account_Details__c = getAccountListJson(c);

    return collectionsEvent;
  }

  /**
   * @description Method to return list of account to be sent for collections in a json string
   * @param c A case record
   * @return Json String
   */
  private static String getAccountListJson(Case c) {
    List<IDRCollectionsAccounts> collectionAcctsList = new List<IDRCollectionsAccounts>();

    collectionAcctsList.add(
      new IDRCollectionsAccounts(
        c.IDR_Account_Card_Policy_Number__c,
        null,
        null
      )
    );

    if (c.IDR_Second_Issue__c) {
      collectionAcctsList.add(
        new IDRCollectionsAccounts(
          c.IDR_Account_Card_Policy_Number_2__c,
          null,
          null
        )
      );
    }

    if (c.IDR_Third_Issue__c) {
      collectionAcctsList.add(
        new IDRCollectionsAccounts(
          c.IDR_Account_Card_Policy_Number_3__c,
          null,
          null
        )
      );
    }

    return Json.serialize(collectionAcctsList);
  }
}
