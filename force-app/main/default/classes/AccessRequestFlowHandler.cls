/**
 * @author Shermal Warnakula, Mouhamed "Mo" Assafiri
 * @since June 2021
 * @description Handler class related to 'PAM - Grant/Revoke Access' flow invocable actions
 */
public without sharing class AccessRequestFlowHandler {
  private static final String STATUS_GRANTED = 'Granted';
  private static final String STATUS_REVOKED = 'Revoked';

  /**
   * @description Process the requests sent from 'PAM - Grant/Revoke Access' flow to update user profile
   * @param requests list of ProfileUpdateWrapper instances sent from PAM - Grant/Revoke Access flow
   * @return List<Boolean> returning result status to support unit testing
   */
  @InvocableMethod(
    label='Update user Profile'
    description='Updates user profile based on grant/revoke flow parameters'
    category='Apex'
  )
  public static List<Boolean> updateUserProfile(
    List<ProfileUpdateWrapper> requests
  ) {
    List<Boolean> resultStatus = new List<Boolean>();
    // Note: Informed decision to compromise the Golden Rule of no DMLs/Qeries inside for loops.
    // There is only a little chance of having multiple PAR/user records in a single flow instance (multiple users requesting PAM access to start at the same time).
    // So even if it does, it would only be a couple of records.
    for (ProfileUpdateWrapper req : requests) {
      // Modify privileged access by updating user profile
      if (modifyPrivilegedAccess(req)) {
        // Update PAR record with Grant/Revoke timestamp
        updateSuccessTimeStamp(
          req.privilegedAccReqId,
          req.processType,
          System.now()
        );
        resultStatus.add(true);
      } else {
        resultStatus.add(false);
      }
    }

    return resultStatus;
  }

  /**
   * @description Grant/Revoke privileged access by updating user profile based on flow type
   * @param flowInstance ProfileUpdateWrapper instances sent from PAM - Grant/Revoke Access flow
   * @return Boolean success or failure result
   */
  private static Boolean modifyPrivilegedAccess(
    ProfileUpdateWrapper flowInstance
  ) {
    Boolean isSuccess;
    try {
      if (Schema.sObjectType.User.isQueryable()) {
        List<User> users = [
          SELECT Id, ProfileId, UserRole.Name
          FROM User
          WHERE Id = :flowInstance.userId
        ];

        if (!users.isEmpty()) {
          //If the Process is Revoke, restore the default Profile for the user's Role.
          //EG: A Engineer will be mapped on the Metadata to 'Minimum Access'

          if (flowInstance.processType == 'revoke') {
            String profileName = [
              SELECT Profile_Name__c
              FROM User_Provisioning_Setting__mdt
              WHERE Role_Name__c = :users[0].UserRole.Name
              LIMIT 1
            ][0]
            .Profile_Name__c;
            String profileId = [
              SELECT Id
              FROM Profile
              WHERE Name = :profileName
              LIMIT 1
            ][0]
            .Id;

            users[0].ProfileId = profileId;
            update users[0];
            isSuccess = true;
          } else {
            //If the Profile ID is the same do nothing.
            if (users[0].ProfileId == flowInstance.profileId) {
              logFailures(
                flowInstance,
                'Tried to change user profile that already had the same profile.'
              );
              isSuccess = false;
            } else {
              users[0].ProfileId = flowInstance.profileId;
              update users[0];
              isSuccess = true;
            }
          }
        } else {
          logFailures(
            flowInstance,
            'Failed to locate a user record with expected conditions to update the profile.'
          );
          isSuccess = false;
        }
      }
    } catch (Exception e) {
      logFailures(flowInstance, e.getMessage());
      isSuccess = false;
    }
    return isSuccess;
  }

  /**
   * @description Log failures related to 'modifyPrivilegedAccess' method
   * @param flowInstance ProfileUpdateWrapper instances sent from PAM - Grant/Revoke Access flow
   * @param errorMessage additional details about the error
   * @return String returning Trace Id used for unit testing
   */
  @TestVisible
  private static String logFailures(
    ProfileUpdateWrapper flowInstance,
    String errorMessage
  ) {
    Privileged_Access_Request__c par = getPrivilegedAccessRequests(
      new Set<String>{ flowInstance.privilegedAccReqId }
    )[0];

    lib_systemLog log = new lib_systemLog(
      AccessRequestFlowHandler.class.getName(),
      'modifyPrivilegedAccess'
    );
    log.error(
      '',
      'Error occured in PAM ' +
      flowInstance.processType +
      ' flow. Related to' +
      ' request ' +
      par.Access_Request__r.Name +
      ' requesting ' +
      par.Access_Request__r.Access_Type__c +
      ' access.' +
      ' More details: ' +
      errorMessage,
      par.Access_Request__r.Trace_Id__c
    );
    log.insertLogAsync();

    return par.Access_Request__r.Trace_Id__c;
  }

  /**
   * @description Updates PAR records with actual Grant/Revoke timestamp using an async method
   * Use of @future to prevent MIXED_DML_OPERATION error -- DML operation on setup object is not permitted after you have updated a non-setup object (or vice versa)
   * @param parId Privileged Access Request record Id
   * @param processType String representing flow action 'grant' or 'revoke'
   * @param actualTime actial DateTime of grant/revoke
   */
  @future
  @TestVisible
  private static void updateSuccessTimeStamp(
    String parId,
    String processType,
    Datetime actualTime
  ) {
    List<Privileged_Access_Request__c> parList = getPrivilegedAccessRequests(
      new Set<String>{ parId }
    );

    try {
      String actionName;
      if (processType == 'grant') {
        parList[0].Actual_Access_Granted_Time__c = actualTime;
        actionName = STATUS_GRANTED;
      } else if (processType == 'revoke') {
        parList[0].Actual_Access_Revoked_Time__c = actualTime;
        actionName = STATUS_REVOKED;
      }
      // Log Grant/Revoke success
      logSuccess(processType, parList[0], actionName);

      // Update PAR record with Time Stamp
      update parList[0];
    } catch (Exception e) {
      lib_systemLog log = new lib_systemLog(
        AccessRequestFlowHandler.class.getName(),
        'updateSuccessTimeStamp'
      );
      log.error(
        '',
        'Error occured while updating actual ' +
        processType +
        ' timestamp on PAR record ' +
        parId +
        '. More details: ' +
        e.getMessage(),
        parList.isEmpty() ? '' : parList[0].Access_Request__r.Trace_Id__c
      );

      // Cannot use async method here, as Future method cannot be called from a future or batch method.
      log.insertLog();
    }
  }

  /**
   * @description Add success logs related to PAM request Grant or Revoke actions
   * @param processType process action type 'grant' or 'revoke'
   * @param par Privileged Access Request being processed
   * @param actionName String representing flow action 'Granted' or 'Revoked'
   * @return String returning Trace Id used for unit testing
   */
  public static String logSuccess(
    String processType,
    Privileged_Access_Request__c par,
    String actionName
  ) {
    lib_systemLog log = new lib_systemLog(
      AccessRequestFlowHandler.class.getName(),
      'logSuccess'
    );
    log.info(
      'PAM request ' +
      par.Access_Request__r.Name +
      ' requesting ' +
      par.Access_Request__r.Access_Type__c +
      ' access has been ' +
      actionName,
      par.Access_Request__r.Trace_Id__c
    );

    // Cannot use async method here, as Future method cannot be called from a future or batch method.
    // (one of the parent calling methods "updateSuccessTimeStamp()" is a future method)
    log.insertLog();

    return par.Access_Request__r.Trace_Id__c;
  }

  /**
   * @description Get a list of privileged access requests
   * @param recordIds ids of the privileged access requests that need to be retrieved
   * @return List<Privileged_Access_Request__c> a list of privileged access requests
   */
  private static List<Privileged_Access_Request__c> getPrivilegedAccessRequests(
    Set<String> recordIds
  ) {
    List<Privileged_Access_Request__c> parList;
    if (Schema.sObjectType.Privileged_Access_Request__c.isQueryable()) {
      parList = [
        SELECT
          Id,
          Actual_Access_Granted_Time__c,
          Actual_Access_Revoked_Time__c,
          Access_Request__r.Name,
          Access_Request__r.Access_Type__c,
          Access_Request__r.Trace_Id__c
        FROM Privileged_Access_Request__c
        WHERE Id IN :recordIds
      ];
    }
    return parList;
  }

  /**
   * @description Wrapper class to hold context information from PAM - Grant/Revoke Access flow
   */
  public class ProfileUpdateWrapper {
    @InvocableVariable
    public Id userId;

    @InvocableVariable
    public String profileId;

    @InvocableVariable
    public Id privilegedAccReqId;

    @InvocableVariable
    public String processType;
  }
}
