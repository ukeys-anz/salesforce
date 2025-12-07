/**
 *
 * @author Jaya Srivastava
 * @since 02/2025
 * @description Class to handle Lending Case actions
 */

public with sharing class LendingCaseActions {
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );

  public static String bohCoachRole = QueryRole.get('BOH_Coach').DeveloperName;
  public static String coachLeadRole = QueryRole.get('Coach_Lead')
    .DeveloperName;
  public static String bohCoachLeadRole = QueryRole.get('BOH_Coach_Lead')
    .DeveloperName;
  public static Id lendingQueue = QueryQueue.get('Lending_Queue').Id;
  public static Set<String> userRoleNameSetForEdit = new Set<String>{
    bohCoachRole,
    coachLeadRole,
    bohCoachLeadRole
  };
  public static Set<String> validUserRolesForOwnerShip = new Set<String>{
    bohCoachRole,
    bohCoachLeadRole
  };
  public static Set<String> lendingCaseLeadActionRoleSet = new Set<String>{
    coachLeadRole,
    bohCoachLeadRole
  };
  public static Set<String> closedStatus = new Set<String>{
    'Closed - Cancelled',
    'Closed - Approved',
    'Closed - Declined'
  };

  public static final String LENDING_CASE_CANNOT_CREATE_OR_EDIT = 'You don\'t have required permissions to perform the action.';
  public static final String LENDING_CASE_CANNOT_BE_ASSIGNED = 'You can\'t assign the lending case directly to someone else. Please assign the case back to the queue for it to be picked up.';
  public static final String LENDING_STATUS_CANNOT_BE_UPDATED = 'You can\'t edit a case because you are not the owner.';
  public static final String CANNOT_UPDATE_CLOSED_CASE = 'You can\'t edit a case that has been closed.';
  public static final String RESTRICT_BOH_COACH_TO_CHANGE_OWNER = 'You can\'t assign a case because you are not the owner.';
  public static final String CASE_CAN_ONLY_BE_ASSIGNED_TO_BOH_COACH_USERS = 'You can\'t assign a lending case that you do not have authority to resolve. Please select another case.';
  public static final String RESTRICT_USER_TO_CLOSE = 'You can\'t close the case. Please click \'Approve or Reject\' to complete this request which will automatically close the case.';

  /**
   * @description Throws validation error when Lending case is updated by user with Role other than BOH Coach ,Coach Lead or BOH Coach Lead
   * @param records List<Case>
   * @param oldMap Map<Id, Case>
   */
  public static void restrictFromUpdatingLendingCase(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    if (
      USER_INFO.checkAnyRoles(userRoleNameSetForEdit) ||
      USER_INFO.checkPermission('Loan_app_Integration')
    ) {
      return;
    }
    ListUtil.addError(records, LENDING_CASE_CANNOT_CREATE_OR_EDIT);
  }

  /**
   * @description Throws validation error when user tries to update a closed Lending Case
   * @param records List<Case>
   * @param oldMap Map<Id, Case>
   */
  public static void restrictFromUpdatingClosedCase(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> closedCases = ListUtil.filter(records, oldMap)
      .oldEquals(Case.Status, closedStatus)
      .toList();
    ListUtil.addError(closedCases, CANNOT_UPDATE_CLOSED_CASE);
  }

  /**
   * @description Throws validation error when Lending case is being created by any other user than GCP
   * @param records List<Case>
   */
  public static void restrictUserFromCreatingLendingCase(List<Case> records) {
    if (USER_INFO.checkPermission('Loan_app_Integration')) {
      return;
    }
    ListUtil.addError(records, LENDING_CASE_CANNOT_CREATE_OR_EDIT);
  }

  /**
   * @description Throws validation error when user tries to assign Case directly to another user without assigning it to Lending queue
   * @param records List<Case>
   * @param oldMap Map<Id, Case>
   */
  public static void restrictFromChangingOwnerToOtherUser(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> casesWithUpdatedOwner = ListUtil.filter(records, oldMap)
      .changed(Case.OwnerId)
      .notEquals(Case.OwnerId, lendingQueue)
      .oldNotEquals(Case.OwnerId, lendingQueue)
      .toList();
    ListUtil.addError(casesWithUpdatedOwner, LENDING_CASE_CANNOT_BE_ASSIGNED);
  }

  /**
   * @description Throws validation error when user tries to assign Case to Queue other than Lending Queue
   * @param records List<Case>
   * @param oldMap Map<Id, Case>
   */
  public static void restrictFromAssigningToOtherQueue(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> casesWithUpdatedOwner = ListUtil.filter(records, oldMap)
      .changed(Case.OwnerId)
      .notEquals(Case.OwnerId, lendingQueue)
      .toList();
    for (Case lendingCase : casesWithUpdatedOwner) {
      if (lendingCase.OwnerId.getSobjectType() != User.getSObjectType()) {
        lendingCase.addError(CASE_CAN_ONLY_BE_ASSIGNED_TO_BOH_COACH_USERS);
      }
    }
  }

  /**
   * @description Throws validation error when the user tries to update the Case status who is not the owner
   * @param records List<Case>
   * @param oldMap Map<Id, Case>
   */
  public static void restrictFromUpdatingStatusIfNotOwner(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> casesWithUpdatedStatus = ListUtil.filter(records, oldMap)
      .changed(Case.Status)
      .notEquals(Case.OwnerId, USER_INFO.getUser().Id)
      .toList();
    ListUtil.addError(casesWithUpdatedStatus, LENDING_STATUS_CANNOT_BE_UPDATED);
  }

  /**
   * @description Throws validation error when a Boh Coach tries to assign the case to another user or another Queue
   * @param records List<Case>
   * @param oldMap Map<Id, Case>
   */
  public static void restrictBohCoachFromChangingOwnerIfNotCaseOwner(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    if (USER_INFO.checkAnyRoles(lendingCaseLeadActionRoleSet)) {
      return;
    }
    List<Case> casesWithUpdatedOwner = ListUtil.filter(records, oldMap)
      .changed(Case.OwnerId)
      .notEquals(Case.OwnerId, USER_INFO.getUser().Id)
      .oldNotEquals(Case.OwnerId, USER_INFO.getUser().Id)
      .toList();
    ListUtil.addError(
      casesWithUpdatedOwner,
      RESTRICT_BOH_COACH_TO_CHANGE_OWNER
    );
  }

  /**
   * @description Throws validation error when Coach Lead or BOH Coach Lead tries to assign case to user other than Boh Coach or Lead or to any other queue other than Lending Queue
   * @param records List<Case>
   * @param oldMap Map<Id, Case>
   */
  public static void restrictLeadsFromAssigningCaseToOtherUsersOrQueue(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    if (!USER_INFO.checkAnyRoles(lendingCaseLeadActionRoleSet)) {
      return;
    }
    List<Case> casesWithUpdatedOwner = ListUtil.filter(records, oldMap)
      .changedFrom(Case.OwnerId, lendingQueue)
      .toList();
    Set<Id> caseOwnerSet = ListUtil.getIds(casesWithUpdatedOwner, Case.OwnerId);
    List<User> ownerList = LendingUserRepository.getUserDetailsByIds(
      caseOwnerSet
    );
    Map<Id, User> newOwnerMap = (Map<Id, User>) ListUtil.mapBy(
      ownerList,
      User.Id
    );
    for (Case lendingCase : casesWithUpdatedOwner) {
      if (
        !validUserRolesForOwnerShip.contains(
          newOwnerMap.get(lendingCase.OwnerId)?.UserRole?.DeveloperName
        )
      ) {
        lendingCase.addError(CASE_CAN_ONLY_BE_ASSIGNED_TO_BOH_COACH_USERS);
      }
    }
  }
  /**
   * @description Throws validation error when user tries to update the status to Closed
   * @param records List<Case>
   * @param oldMap Map<Id, Case>
   */
  public static void restrictUserFromUpdatingCaseToClosed(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    if (USER_INFO.checkPermission('Loan_app_Integration')) {
      return;
    }
    List<Case> caseWithUpdatedStatus = ListUtil.filter(records, oldMap)
      .changedTo(Case.Status, closedStatus)
      .equals(Case.System_Action__c, false)
      .toList();
    ListUtil.addError(caseWithUpdatedStatus, RESTRICT_USER_TO_CLOSE);
  }
}
