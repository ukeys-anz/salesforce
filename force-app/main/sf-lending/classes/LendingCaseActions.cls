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
  public static UserRole bohCoachRole = QueryRole.get('BOH_Coach');
  public static UserRole coachLeadRole = QueryRole.get('Coach_Lead');
  public static Group lendingQueue = QueryQueue.get('Lending_Queue');
  public static Set<String> userRoleNameSet = new Set<String>{
    bohCoachRole.DeveloperName,
    coachLeadRole.DeveloperName
  };

  public static final String LENDING_CASE_CANNOT_CREATE_OR_EDIT = 'You don\'t have required permissions to perform the action';
  public static final String LENDING_CASE_CANNOT_BE_ASSIGNED = 'You can\'t assign the lending case directly to someone else. Please assign the case back to the queue for it to be picked up.';
  /**
   * @description Throws validation error when Lending case is updated by user with Role other than BOH Coach or Coach Lead
   * @param records List<Case>
   * @param oldMap Map<Id, Case>
   */
  public static void restrictUserFromUpdatingLendingCase(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    if (
      USER_INFO.checkAnyRoles(userRoleNameSet) ||
      USER_INFO.checkPermission('Loan_app_Integration')
    ) {
      return;
    }
    for (Case lendingCase : records) {
      lendingCase.addError(LENDING_CASE_CANNOT_CREATE_OR_EDIT);
    }
  }

  /**
   * @description Throws validation error when Lending case is being created by any other user than GCP
   * @param records List<Case>
   */
  public static void restrictUserFromCreatingLendingCase(List<Case> records) {
    if (USER_INFO.checkPermission('Loan_app_Integration')) {
      return;
    }
    for (Case lendingCase : records) {
      lendingCase.addError(LENDING_CASE_CANNOT_CREATE_OR_EDIT);
    }
  }

  /**
   * @description Throws validation error when Lending case is being assigned from one user to another user directly without assigning it to a queue.
   * @param records List<Case>
   * @param oldMap Map<Id, Case>
   */
  public static void restrictUserFromChangingOwnerIfNotQueue(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> casesWithUpdatedOwner = ListUtil.filter(records, oldMap)
      .changed(Case.OwnerId)
      .toList();
    if (casesWithUpdatedOwner.isEmpty()) {
      return;
    }
    for (Case lendingCase : casesWithUpdatedOwner) {
      Case oldRecord = oldMap.get(lendingCase.Id);
      if (
        oldRecord.OwnerId.getSobjectType() == User.getSObjectType() &&
        lendingCase.OwnerId != lendingQueue.Id
      ) {
        lendingCase.addError(LENDING_CASE_CANNOT_BE_ASSIGNED);
      }
    }
  }
}
