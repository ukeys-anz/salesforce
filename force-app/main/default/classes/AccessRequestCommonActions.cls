/**
 *
 * @author Shermal Warnakula
 * @since May 2021
 * @description Common Access Request Action methods
 */
public without sharing class AccessRequestCommonActions {
  private static final String STATUS_APPROVED = 'Approved';
  @testVisible
  private static final String REQUEST_IMMEDIATE = 'Immediate';

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
        '',
        e.getMessage()
      );
    }

    return userID;
  }

  /**
   * @description Calculates PAM request approvers based on requesting user and global PAM approvers defined in custom settings
   * Note:  Approver will be calculated based on the currently executing user, and not based on the user mentioned as the 'Requester'.
   *        Incase if the global approver creates an Access Request onbehalf of another user, the request would be automatically assigned to approver's manager.
   *        Team + TPO agreed on above points based on following assumptions;
   *          1) Access Request creator would most probably be the 'Requester' himself.
   *          2) Only Engineers (same level) would be initially allowed to raise PAM requests, so that the approver would always be the global approver.
   *          3) Only the record owner/creator would have permissions to edit, which means updates does not affect the approver.
   * @param records list of new Access Request records being inserted or updated
   */
  public static void calculateApprover(List<Access_Request__c> records) {
    String approverId = getApproverId();

    for (Access_Request__c record : records) {
      if (!String.isBlank(approverId)) {
        // Make sure the Status is blank to prevent re-setting approver for already processed requests
        if (String.isEmpty(record.Status__c)) {
          record.Approver__c = approverId;
        }
      } else {
        String errorMessage = 'Error occured while trying to automatically assign approvers for PAM requests. Please contact your System Administrator for assistance.';
        record.addError(errorMessage);
        Lib_SystemLog.createSingleLogAsync(
          AccessRequestCommonActions.class.getName(),
          'calculateApprover',
          '',
          errorMessage
        );
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
        if (isRequestApproved(newRequest, oldRecordMap)) {
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
        '',
        e.getMessage()
      );
    }
  }

  /**
   * @description checks if the Access Request has been Approved now
   * @param newRecord new updated instance of the Access Request
   * @param oldRecordMap map of old Access Request records
   * @return Boolean
   */
  private static Boolean isRequestApproved(
    Access_Request__c newRecord,
    Map<Id, SObject> oldRecordMap
  ) {
    Access_Request__c oldRecord = (Access_Request__c) oldRecordMap.get(
      newRecord.Id
    );

    return STATUS_APPROVED.equals(newRecord.Status__c) &&
      oldRecord.Status__c != newRecord.Status__c;
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
   * @description Process the requests sent from flow and update the timestamp on privileged access requests
   * @param requests update timestamp requests sent from PAM - Grant/Revoke Access flow
   */
  @InvocableMethod(
    label='Set Access Granted/Revoked Timestamp'
    description='Set Access Granted/Revoked Timestamp'
    category='Apex'
  )
  public static void setTimestamp(List<UpdateTimestampRequest> requests) {
    if (!requests.isEmpty()) {
      Map<String, String> processTypeByRequestId = new Map<String, String>();
      for (UpdateTimestampRequest req : requests) {
        processTypeByRequestId.put(req.privilegedAccReqId, req.processType);
      }
      handleUpdatePrivilegedAccReq(processTypeByRequestId);
    }
  }

  /**
   * @description Update the timestamp on the requests using a future method to avoid MIXED_DML_OPERATION error
   * @param processTypeByRequestId a map of the privileged access request id and its corresponding process type (grant/revoke)
   */
  @future
  private static void handleUpdatePrivilegedAccReq(
    Map<String, String> processTypeByRequestId
  ) {
    if (!processTypeByRequestId.isEmpty()) {
      List<Privileged_Access_Request__c> pars = getPrivilegedAccessRequests(
        processTypeByRequestId.keySet()
      );

      updateTimestamp(pars, processTypeByRequestId);

      List<Database.SaveResult> srList = Database.update(pars, true);

      //log errors to application log
      lib_systemLog log = new lib_systemLog(
        'AccessRequestCommonActions',
        'setTimestamp'
      );
      log.addDatabaseSaveResult('Privileged_Access_Request__c', srList, pars);
      log.insertLog();
    }
  }

  /**
   * @description Get a list of privileged access requests
   * @param recordIds ids of the privileged access requests that need to be retrieved
   * @return List<Privileged_Access_Request__c> a list of privileged access requests
   */
  private static List<Privileged_Access_Request__c> getPrivilegedAccessRequests(
    Set<String> recordIds
  ) {
    if (Schema.sObjectType.Privileged_Access_Request__c.isQueryable()) {
      List<Privileged_Access_Request__c> pars = [
        SELECT Id, Actual_Access_Granted_Time__c, Actual_Access_Revoked_Time__c
        FROM Privileged_Access_Request__c
        WHERE Id IN :recordIds
      ];
      return pars;
    }
    return null;
  }

  /**
   * @description Update either Actual_Access_Granted_Time__c/Actual_Access_Revoked_Time__c field on each privileged access request record
   * @param pars a list of privileged access requests
   * @param processTypeByRequestId a map of the privileged access request id and its corresponding process type (grant/revoke)
   */
  private static void updateTimestamp(
    List<Privileged_Access_Request__c> pars,
    Map<String, String> processTypeByRequestId
  ) {
    for (Privileged_Access_Request__c par : pars) {
      if (processTypeByRequestId.get(par.Id) == 'grant') {
        par.Actual_Access_Granted_Time__c = System.now();
      } else if (processTypeByRequestId.get(par.Id) == 'revoke') {
        par.Actual_Access_Revoked_Time__c = System.now();
      }
    }
  }

  /**
   * @description Wrapper class for requests sent from PAM - Grant/Revoke Access flow
   */
  public class UpdateTimestampRequest {
    @InvocableVariable
    public Id privilegedAccReqId;

    @InvocableVariable
    public String processType;
  }
}
