/**
 *
 * @author Shermal Warnakula
 * @since May 2021
 * @description Common Access Request Action methods
 * without sharing: used to allow executing user to query User records to access PAM approver Id
 */
public without sharing class AccessRequestCommonActions {
  @testVisible
  private static final String STATUS_SUBMITTED = 'Submitted';
  private static final String STATUS_APPROVED = 'Approved';
  @testVisible
  private static final String STATUS_REJECTED = 'Rejected';

  @testVisible
  private static final String REQUEST_IMMEDIATE = 'Immediate';
  private static final String USER_REQUEST_AND_APPROVE_ERROR_MSG = 'You cannot approve your own request. Please get another user from the PAM Approval Group to approve your Access Request';

  /**
   * @description get user Id related to global PAM approvers defined in custom setting 'PAM_Global_Approver__c'
   * @return String
   */
  public static String getApproverId() {
    String userID;
    try {
      if (Schema.sObjectType.User.isQueryable()) {
        for (User user : [
          SELECT Id
          FROM User
          WHERE
            Username = :PAM_Global_Approver__c.getInstance()
              .PAM_Approver_Username__c.toLowerCase()
        ]) {
          userID = user.Id;
        }
      }
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    }

    return userID;
  }

  /**
   * @description Checks to see if the approver is not the same as the requestor and throws an error otherwise
   * @param records list of new Access Request records being inserted or updated
   *
   **/
  public static void checkApprovers(List<Access_Request__c> records) {
    for (Access_Request__c record : records) {
      if (record.Approver_ID__c == record.Requestor__c) {
        record.addError(USER_REQUEST_AND_APPROVE_ERROR_MSG);
        Logger.error(
          record.Requestor__c + ' attempted to self-approve their PAM request'
        );
      }
    }
    Logger.saveLog();
  }

  /**
   * @description create a map of required fields for new Access_Request__c records
   * This is needed to check if there is any exisiting PARs which ovelaps with the new one
   * @param requests List<Access_Request__c> requests : All new access requests
   * @return Map<String, List<AccessRequestMap> {'requester' : ['Access_Request_Record_Type_Id__c', 'Start_Date_Time__c', 'Revoke_Time__c']}
   **/
  @testVisible
  private static Map<String, List<AccessRequestMap>> createAccessRequestsMap(
    List<Access_Request__c> requests
  ) {
    Map<String, List<AccessRequestMap>> accessRequestsMap = new Map<String, List<AccessRequestMap>>();
    for (Access_Request__c request : requests) {
      AccessRequestMap requestMap = new AccessRequestMap();
      requestMap.recordTypeId = request.RecordTypeId;
      Datetime startTime = calculateStartTime(
        request.When__c,
        request.Expected_Start__c
      );
      requestMap.startTime = startTime;
      requestMap.revokeTime = calculateRevokeTime(
        startTime,
        request.Duration_hrs__c
      );

      String requester = request.Requestor__c;
      if (!accessRequestsMap.containsKey(requester)) {
        accessRequestsMap.put(requester, new List<AccessRequestMap>());
      }
      accessRequestsMap.get(requester).add(requestMap);
    }
    return accessRequestsMap;
  }

  /**
   * @description find all PARs filtered by requesters which comes from createAccessRequestsMap.keySets()
   * @param requesters Set<String> requestors : All new access requestors
   * @return List<Privileged_Access_Request__c>
   **/
  private static List<Privileged_Access_Request__c> getPARsByRequester(
    Set<String> requesters
  ) {
    List<Privileged_Access_Request__c> pars = new List<Privileged_Access_Request__c>();
    if (
      Schema.sObjectType.Privileged_Access_Request__c.isQueryable() == false
    ) {
      return pars;
    }
    return [
      SELECT
        Id,
        Name,
        Access_Request__r.Name,
        Access_Request__r.Requestor__c,
        Access_Request_Record_Type_Id__c,
        Start_Date_Time__c,
        Revoke_Time__c
      FROM Privileged_Access_Request__c
      WHERE Access_Request__r.Requestor__c IN :requesters
    ];
  }

  /**
   * @description create a map of all ovelapping records {requestorId => requestor.Name}
   * This is needed to check if there is any new request there which overlap with previous PARs
   * @param accessRequestsMap Map<String, List<AccessRequestMap>>  | this came from createAccessRequestsMap method
   * @return Map<String, String> {requestorId => requestor.Name}
   **/
  @testVisible
  private static Map<String, String> findOverLappedRequests(
    Map<String, List<AccessRequestMap>> accessRequestsMap
  ) {
    Map<String, String> overlappedRequests = new Map<String, String>();
    Set<String> requesters = accessRequestsMap.keySet();
    if (requesters.isEmpty()) {
      return overlappedRequests;
    }

    List<Privileged_Access_Request__c> pars = getPARsByRequester(requesters);
    if (pars.isEmpty()) {
      return overlappedRequests;
    }
    for (Privileged_Access_Request__c par : pars) {
      String requester = par.Access_Request__r.Requestor__c;
      List<AccessRequestMap> requesterMapList = accessRequestsMap.get(
        requester
      );
      for (AccessRequestMap newRequestMap : requesterMapList) {
        if (
          (par.Start_Date_Time__c <= newRequestMap.revokeTime) &&
          (par.Revoke_Time__c >= newRequestMap.startTime) &&
          (par.Access_Request_Record_Type_Id__c == newRequestMap.recordTypeId)
        ) {
          overlappedRequests.put(requester, par.Access_Request__r.Name);
          break;
        }
      }
    }

    return overlappedRequests;
  }

  /**
   * @description Checks to see if this new PAR is going to overlap with other PARs in the system.
   * If so, throw an error to prevent any unexpected issues during Privilaged Access
   * @param records list of new Access Request records being inserted or updated
   **/
  public static void checkIfRecordsOverlap(List<Access_Request__c> records) {
    List<Access_Request__c> filteredRequests = ListUtil.filter(records)
      .notEquals(Access_Request__c.Status__c, STATUS_REJECTED)
      .toList();
    Map<String, List<AccessRequestMap>> accessRequestsMap = createAccessRequestsMap(
      filteredRequests
    );
    Map<String, String> ovelappedRequests = findOverLappedRequests(
      accessRequestsMap
    );
    if (ovelappedRequests.isEmpty()) {
      return;
    }

    for (Access_Request__c record : filteredRequests) {
      string requester = record.Requestor__c;
      if (!ovelappedRequests.containsKey(requester)) {
        continue;
      }
      //Check if there any overlapped PAR record and return the PAM number
      record.addError(
        'The request overlaps with an existing Privileged Access Request: ' +
          ovelappedRequests.get(requester) +
          '. Please double check the start time and duration to ensure they do not overlap'
      );
    }
  }

  /**
   * @description creates a PAR record when Access Request gets Approved
   * @param newRecords list of new Access Request records
   * @param oldRecordMap map of old Access Request records
   */
  public static void createPARequestRecords(
    List<Access_Request__c> newRecords,
    Map<Id, SObject> oldRecordMap
  ) {
    List<Access_Request__c> approvedRequests = new List<Access_Request__c>();
    List<Id> requesterIdList = new List<Id>();
    Map<Id, User> requesterUserMap = new Map<Id, User>();
    List<Privileged_Access_Request__c> parRequests = new List<Privileged_Access_Request__c>();
    try {
      // identify approved Access Requests and Requesting users
      for (Access_Request__c newRequest : newRecords) {
        if (STATUS_APPROVED == getApprovalDecision(newRequest, oldRecordMap)) {
          approvedRequests.add(newRequest);
          requesterIdList.add(newRequest.Requestor__c);
        }
      }

      if (!requesterIdList.isEmpty()) {
        requesterUserMap = getRequestingUserMap(requesterIdList);
      }

      // create Privileged Access Request records against approved Access Requests
      for (Access_Request__c approvedRequest : approvedRequests) {
        parRequests.add(generatePARRecord(approvedRequest, requesterUserMap));
      }

      // insert new PA records
      if (!parRequests.isEmpty()) {
        insert parRequests;
      }
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    }
  }

  /**
   * @description checks if the Access Request has been Approved now
   * @param newRecord new updated instance of the Access Request
   * @param oldRecordMap map of old Access Request records
   * @return String
   */
  private static String getApprovalDecision(
    Access_Request__c newRecord,
    Map<Id, SObject> oldRecordMap
  ) {
    String approvalDecision = '';
    Access_Request__c oldRecord = (Access_Request__c) oldRecordMap.get(
      newRecord.Id
    );
    if (oldRecord.Status__c != newRecord.Status__c) {
      if (STATUS_APPROVED.equals(newRecord.Status__c)) {
        approvalDecision = STATUS_APPROVED;
      } else if (STATUS_REJECTED.equals(newRecord.Status__c)) {
        approvalDecision = STATUS_REJECTED;
      }
    }
    return approvalDecision;
  }

  /**
   * @description returns a map of requesting User records (having each Profile Id) by Ids
   * @param requesterIdList User Ids of requesting users
   * @return Map<Id, User>
   */
  @testVisible
  private static Map<Id, User> getRequestingUserMap(List<Id> requesterIdList) {
    Map<Id, User> userMap = new Map<Id, User>();
    if (Schema.sObjectType.User.isQueryable()) {
      userMap = new Map<Id, User>(
        [SELECT Id, ProfileId FROM User WHERE Id IN :requesterIdList]
      );
    }
    return userMap;
  }

  /**
   * @description generates a Privileged Access Request record
   * @param approvedRequest approved Access Request record
   * @param requesterUserMap requester User map
   * @return Privileged_Access_Request__c
   */
  @testVisible
  private static Privileged_Access_Request__c generatePARRecord(
    Access_Request__c approvedRequest,
    Map<Id, User> requesterUserMap
  ) {
    Privileged_Access_Request__c par = new Privileged_Access_Request__c();
    par.Access_Request__c = approvedRequest.Id;
    par.Previous_Profile_Id__c = requesterUserMap.get(
        approvedRequest.Requestor__c
      )
      .ProfileId;
    par.Start_Date_Time__c = calculateStartTime(
      approvedRequest.When__c,
      approvedRequest.Expected_Start__c
    );
    par.Revoke_Time__c = calculateRevokeTime(
      par.Start_Date_Time__c,
      approvedRequest.Duration_hrs__c
    );

    return par;
  }

  /**
   * @description check if flows has been disabled for approver of PAM Request
   * @param records List<Access_Request__c>
   */
  public static void checkIfApproverFlowDisabled(
    List<Access_Request__c> records
  ) {
    Salesforce_Library_Settings__c customSettings = Salesforce_Library_Settings__c.getInstance(
      UserInfo.getUserId()
    );
    if (customSettings == null || !customSettings.Disable_Flows__c) {
      return;
    }
    String customSettingsName = (Salesforce_Library_settings__c.getOrgDefaults()
        .Name == customSettings.Name)
      ? 'Salesforce Library Settings (Organization)'
      : ('user\'s ' + customSettings.Name);
    for (Access_Request__c record : records) {
      record.addError(
        'Updating Access request failed due to: ' +
          customSettingsName +
          ' Disable_Flows__c is true.'
      );
    }
  }

  /**
   * @description calculates access grant date/time based on request inputs.
   * Adds a buffer of 5 minutes to current date/time if the request was 'Immediate', to give enough time for automated flows to kick in.
   * @param immediateOrFuture indicates if access was requested effective immediately, or in the future
   * @param startDateTime start date/time if the request was for future
   * @return Datetime
   */
  @testVisible
  private static Datetime calculateStartTime(
    String immediateOrFuture,
    Datetime startDateTime
  ) {
    return REQUEST_IMMEDIATE.equals(immediateOrFuture)
      ? datetime.now()
      : startDateTime;
  }

  /**
   * @description calculates access revoke date/time based on start time and duration.
   * @param startTime privileged access start time
   * @param duration requested duration for privileged access
   * @return Datetime
   */
  private static Datetime calculateRevokeTime(
    Datetime startTime,
    String duration
  ) {
    return startTime.addHours(Integer.valueOf(duration));
  }

  /**
   * @description loggs PAM request submission for approval
   * @param newRecords list of new Access Request records
   * @param oldRecordMap map of old Access Request records
   */
  public static void logSubmission(
    List<Access_Request__c> newRecords,
    Map<Id, SObject> oldRecordMap
  ) {
    String uniquePamTraceId = UniqueIdUtil.getTraceId();
    List<Access_Request__c> recordsToUpdate = new List<Access_Request__c>();
    // identify Submitted Access Requests
    for (Access_Request__c newRequest : newRecords) {
      if (isRequestSubmitted(newRequest, oldRecordMap)) {
        Logger.info(
          'PAM request ' +
            newRequest.Name +
            ' access has been submitted for approval by ' +
            newRequest.Requestor__c +
            ', and awaiting approval by PAM Approvers ',
          newRequest
        );
        newRequest.Trace_Id__c = uniquePamTraceId;
        recordsToUpdate.add(newRequest);
      }
    }
    Logger.saveLog();
  }

  /**
   * @description loggs PAM request approval decision
   * @param newRecords list of new Access Request records
   * @param oldRecordMap map of old Access Request records
   */
  public static void logApprovalDecision(
    List<Access_Request__c> newRecords,
    Map<Id, SObject> oldRecordMap
  ) {
    for (Access_Request__c newRequest : newRecords) {
      String approvalDecision = getApprovalDecision(newRequest, oldRecordMap);
      if (!String.isBlank(approvalDecision)) {
        String bypassAutomationRequestRTId = QueryRT.of(
            Access_Request__c.SObjectType
          )
          .getId('Bypass_Automation_Request');

        String requestLog = bypassAutomationRequestRTId ==
          newRequest.RecordTypeId
          ? ' to bypass ' + newRequest.Automations_to_Bypass__c
          : ' requesting ' + newRequest.Access_Type__c + ' access';
        Logger.info(
          'PAM request ' +
            newRequest.Name +
            requestLog +
            ' has been ' +
            approvalDecision,
          newRequest
        );
      }
    }
    Logger.saveLog();
  }

  /**
   * @description checks if the Access Request has been Submitted now
   * @param newRecord new updated instance of the Access Request
   * @param oldRecordMap map of old Access Request records
   * @return Boolean
   */
  private static Boolean isRequestSubmitted(
    Access_Request__c newRecord,
    Map<Id, SObject> oldRecordMap
  ) {
    Access_Request__c oldRecord = (Access_Request__c) oldRecordMap.get(
      newRecord.Id
    );
    return STATUS_SUBMITTED.equals(newRecord.Status__c) &&
      oldRecord.Status__c != newRecord.Status__c;
  }

  /**
   * @description Wrapper class to hold all the required information from new access request record -
   * - to check if there is any overlapping records.
   */
  public class AccessRequestMap {
    public Id recordTypeId;
    public Datetime startTime;
    public Datetime revokeTime;
  }
}
