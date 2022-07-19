/**
 *
 * @author Shermal Warnakula
 * @since May 2021
 * @description Common Access Request Action methods
 */
public without sharing class AccessRequestCommonActions {
  @testVisible
  private static final String STATUS_SUBMITTED = 'Submitted';
  private static final String STATUS_APPROVED = 'Approved';
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
      Lib_SystemLog.createSingleLogAsync(
        AccessRequestCommonActions.class.getName(),
        'getApproverUserInfo',
        'PAM001',
        e.getMessage()
      );
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

        Lib_SystemLog.createSingleLogAsync(
          AccessRequestCommonActions.class.getName(),
          'CheckApprovers',
          'PAM005',
          'User ' +
          record.Requestor__c +
          ' attempted to self-approve their PAM request'
        );
      }
    }
  }

  /**
   * @description Checks to see if this new PAR is going to overlap with other PARs in the system.
   * If so, throw an error to prevent any unexpected issues during Privilaged Access
   * @param records list of new Access Request records being inserted or updated
   **/
  @SuppressWarnings('PMD.OperationWithLimitsInLoop')
  public static void checkIfRecordsOverlap(List<Access_Request__c> records) {
    for (Access_Request__c record : records) {
      //If the record is being rejected we can ignore checking if this record overlaps
      if (record.Status__c == 'Rejected') {
        continue;
      }

      if (Schema.sObjectType.Privileged_Access_Request__c.isQueryable()) {
        //Create a dummy PAR
        List<Id> requesterIdList = new List<Id>();
        Map<Id, User> requesterUserMap = new Map<Id, User>();
        requesterIdList.add(record.Requestor__c);
        requesterUserMap = getRequestingUserMap(requesterIdList);
        Privileged_Access_Request__c dummyPAR = generatePARRecord(
          record,
          requesterUserMap
        );

        // Note: Informed decision to compromise the Golden Rule of no DMLs/Qeries inside for loops.
        // Because it is very unlikely that there will be many PARs at one time
        // See if this Dummy PAR will overlap with any other PARs
        List<Privileged_Access_Request__c> overlappingRequests = [
          SELECT Id, Name, Access_Request__r.Name
          FROM Privileged_Access_Request__c
          WHERE
            Access_Request__r.Requestor__c = :record.Requestor__c
            AND Start_Date_Time__c <= :dummyPAR.Revoke_Time__c
            AND Revoke_Time__c >= :dummyPAR.Start_Date_Time__c
        ];

        if (!overlappingRequests.isEmpty()) {
          record.addError(
            'The request overlaps with an existing Privilaged Access Request: ' +
            overlappingRequests[0].Access_Request__r.Name +
            '. Please double check the start time and duration to ensure they do not overlap'
          );
        }
      }
    }
  }

  /**
   * @description creates a PAR record when Access Request gets Approved
   * Suppressed 'ApexCRUDViolation' warning as PAR record creation should happen regardless of the executing user permissions
   * @param newRecords list of new Access Request records
   * @param oldRecordMap map of old Access Request records
   */
  @SuppressWarnings('PMD.ApexCRUDViolation')
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
      Lib_SystemLog.createSingleLogAsync(
        AccessRequestCommonActions.class.getName(),
        'createPARequestRecords',
        'PAM003',
        e.getMessage()
      );
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
    lib_systemLog log = new lib_systemLog(
      AccessRequestCommonActions.class.getName(),
      'logSubmission'
    );
    List<Access_Request__c> recordsToUpdate = new List<Access_Request__c>();
    // identify Submitted Access Requests
    for (Access_Request__c newRequest : newRecords) {
      if (isRequestSubmitted(newRequest, oldRecordMap)) {
        log.info(
          'PAM request ' +
          newRequest.Name +
          ' requesting ' +
          newRequest.Access_Type__c +
          ' access has been submitted for approval by ' +
          newRequest.Requestor__c +
          ', and awaiting approval by ' +
          newRequest.Approver__c,
          uniquePamTraceId
        );
        newRequest.Trace_Id__c = uniquePamTraceId;
        recordsToUpdate.add(newRequest);
      }
    }
    log.insertLogAsync();
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
    lib_systemLog log = new lib_systemLog(
      AccessRequestCommonActions.class.getName(),
      'logApprovalDecision'
    );
    for (Access_Request__c newRequest : newRecords) {
      String approvalDecision = getApprovalDecision(newRequest, oldRecordMap);
      if (!String.isBlank(approvalDecision)) {
        log.info(
          'PAM request ' +
          newRequest.Name +
          ' requesting ' +
          newRequest.Access_Type__c +
          ' access has been ' +
          approvalDecision,
          newRequest.Trace_Id__c
        );
      }
    }
    log.insertLogAsync();
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
}
