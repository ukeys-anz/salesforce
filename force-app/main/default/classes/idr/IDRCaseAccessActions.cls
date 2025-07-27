/**
 * @author CMOS
 * @since 03/2025
 * @description IDRCaseAccessActions handles access related actions for L1/L2 and L3 level of users.
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class IDRCaseAccessActions {
  private static final IDRCaseActionsRepository CASE_REPOSITORY = (IDRCaseActionsRepository) Lib_InstanceProvider.forType(
    IDRCaseActionsRepository.class
  );
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  @TestVisible
  private static final String ERROR_MSG_RESTRICT_L2_L3_USERS = 'You are not authorized to make updates to this field.';
  private static final String ANZX_STANDARD_USER_PROFILE = 'ANZx Standard User';
  /**
   * @description To identify the cases that match the criteria of case not owned by IDR_Level_2 or IDR_Level_3 users.
   * @param listOfnewCases List of Case record in current context
   * @param oldMap old map of the cases in current context
   */
  public static void restrictL2L3Users(
    List<Case> listOfnewCases,
    Map<Id, Case> oldMap
  ) {
    if (!USER_INFO.checkAnyPermissions(IDRConstants.PSG_L2_L3_USERS)) {
      return;
    }

    Set<Id> oldCaseOwnerIds = ListUtil.getIds(oldMap.values(), Case.OwnerId);

    Map<Id, User> mapOfL2L3Users = new Map<Id, User>(
      CASE_REPOSITORY.queryL2L3User(oldCaseOwnerIds)
    );

    List<Case> casesToBeValidated = getNonEscalatedCasesforL2L3users(
      listOfnewCases,
      oldMap,
      mapOfL2L3Users.keySet()
    );

    List<Case> excludedCases = getExcludedCases(casesToBeValidated, oldMap);

    List<Case> statusChangedCases = getStatusChangedCases(
      excludedCases,
      oldMap
    );
    ListUtil.addError(statusChangedCases, ERROR_MSG_RESTRICT_L2_L3_USERS);
    List<Case> nonStatusChangedCases = ListUtil.filter(excludedCases)
      .noError()
      .toList();

    List<Case> notOwnedByL2L3Users = getNotOwnedByL2L3Users(
      nonStatusChangedCases,
      oldMap,
      mapOfL2L3Users.keySet()
    );

    List<Case> ownerChangedCases = getOwnerChangedCases(
      notOwnedByL2L3Users,
      oldMap
    );
    ListUtil.addError(ownerChangedCases, ERROR_MSG_RESTRICT_L2_L3_USERS);
    List<Case> nonOwnerChangedCases = ListUtil.filter(notOwnedByL2L3Users)
      .noError()
      .toList();

    List<Case> nonAnzUserCases = getNonAnzxStandardUserCases(
      nonOwnerChangedCases,
      oldMap
    );
    ListUtil.addError(nonAnzUserCases, ERROR_MSG_RESTRICT_L2_L3_USERS);
    List<Case> anzxUserCases = ListUtil.filter(nonOwnerChangedCases)
      .noError()
      .toList();

    List<Case> nonBankerRelatedCases = getNonBankerRelatedAnzxUserCases(
      anzxUserCases,
      oldMap
    );
    ListUtil.addError(nonBankerRelatedCases, ERROR_MSG_RESTRICT_L2_L3_USERS);
  }
  /**
   * @description To get all the cases where old owner is not IDR_Level_2 nor IDR_Level_3 users.
   * @param newCases List of new cases.
   * @param oldMap Map of old cases.
   * @param l2l3UsersIds Set of users id which are having either IDR_Level_2 or IDR_Level_3 PSG.
   * @return `List<Case>` return list of cases which full fill the criteria.
   */
  private static List<Case> getNotOwnedByL2L3Users(
    List<Case> newCases,
    Map<Id, Case> oldMap,
    Set<Id> l2l3UsersIds
  ) {
    return ListUtil.filter(newCases, oldMap)
      .oldNotEquals(Case.OwnerId, l2l3UsersIds)
      .toList();
  }
  /**
   * @description To get all those cases where IDR_Complaint_Resolution_Count__c, IDR_Additional_Correspondence_reviewed__c, IDR_Document_Count__c data are not changed.
   * @param newCases List of new cases.
   * @param oldMap Map of old cases.
   * @return `List<Case>` return list of cases which full fill the criteria.
   */
  @TestVisible
  private static List<Case> getExcludedCases(
    List<Case> newCases,
    Map<Id, Case> oldMap
  ) {
    Set<SObjectField> excludedFields = new Set<SObjectField>{
      Case.IDR_Complaint_Resolution_Count__c,
      Case.IDR_Additional_Correspondence_reviewed__c,
      Case.IDR_Document_Count__c
    };

    return ListUtil.filter(newCases, oldMap)
      .allNotChanged(excludedFields)
      .toList();
  }
  /**
   * @description To get all the cases where old owner was not a IDR_Level_2 or IDR_Level_3 user && status is not equal to Escalated || where old CaseNumber__c is not blank.
   * @param newCases List of new cases.
   * @param oldMap Map of old cases.
   * @param l2l3UsersId Set of users id which are having either IDR_Level_2 or IDR_Level_3 PSG.
   * @return `List<Case>` return list of cases which full fill the criteria.
   */
  @TestVisible
  private static List<Case> getNonEscalatedCasesforL2L3users(
    List<Case> newCases,
    Map<Id, Case> oldMap,
    Set<Id> l2l3UsersId
  ) {
    List<Case> filteredCases = new List<Case>();
    for (Case tempCase : newCases) {
      if (
        tempCase.Status == IDRConstants.ESCALATED_STATUS &&
        l2l3UsersId.contains(oldMap.get(tempCase.Id).OwnerId) ||
        String.isBlank(oldMap.get(tempCase.Id).CaseNumber__c)
      ) {
        continue;
      }
      filteredCases.add(tempCase);
    }
    return filteredCases;
  }
  /**
   * @description To get all the cases where status is changed to 'Reopened' or 'Case-On Hold'.
   * @param newCases List of new cases.
   * @param oldMap Map of old cases.
   * @return `List<Case>` return list of cases which full fill the criteria.
   */
  @TestVisible
  private static List<Case> getStatusChangedCases(
    List<Case> newCases,
    Map<Id, Case> oldMap
  ) {
    Set<String> allowedCaseStatus = new Set<String>{
      IDRConstants.REOPENED_STATUS,
      IDRConstants.ON_HOLD_STATUS
    };

    return ListUtil.filter(newCases, oldMap)
      .changedTo(Case.Status, allowedCaseStatus)
      .toList();
  }
  /**
   * @description To get all the cases where owner is not changed && owner is not equal to current logged in user.
   * @param newCases List of new cases.
   * @param oldMap Map of old cases.
   * @return `List<Case>` return list of cases which full fill the criteria.
   */
  @TestVisible
  private static List<Case> getOwnerChangedCases(
    List<Case> newCases,
    Map<Id, Case> oldMap
  ) {
    return ListUtil.filter(newCases, oldMap)
      .allNotChanged(new Set<SObjectField>{ Case.OwnerId })
      .notEquals(Case.OwnerId, USER_INFO.getUser().Id)
      .toList();
  }
  /**
   * @description To get all the cases where owner is changed && old owner is not equal to current logged in user && current logged in user is not having profile as ANZx Standard user.
   * @param newCases List of new cases.
   * @param oldMap Map of old cases.
   * @return `List<Case>` return list of cases which full fill the criteria.
   */
  @TestVisible
  private static List<Case> getNonAnzxStandardUserCases(
    List<Case> newCases,
    Map<Id, Case> oldMap
  ) {
    if (USER_INFO.checkProfile(ANZX_STANDARD_USER_PROFILE)) {
      return new List<Case>();
    }

    return ListUtil.filter(newCases, oldMap)
      .changed(Case.OwnerId)
      .oldNotEquals(Case.OwnerId, USER_INFO.getUser().Id)
      .toList();
  }
  /**
   * @description To get all the cases where owner is changed && old value of status is not equal to 'open' nor 'Under Investigation' &&
   * current logged in user is having profile as ANZx Standard profile user && role is not equal to 'Banker' or 'Banker Line Manager'or 
   * current logged in user should not have custom permission name as 'Hypercare Migration Permissions').
   * @param newCases List of new cases.
   * @param oldMap Map of old cases.
   * @return `List<Case>` return list of cases which full fill the criteria.
   */
  @TestVisible
  private static List<Case> getNonBankerRelatedAnzxUserCases(
    List<Case> newCases,
    Map<Id, Case> oldMap
  ) {
    Boolean isCurrentUserBankerOrBankLineManager = USER_INFO.checkAnyRoles(
      new Set<String>{
        IDRConstants.ROLE_BANKER,
        IDRConstants.ROLE_BANKER_LINE_MANAGER
      }
    );

    if (isCurrentUserBankerOrBankLineManager) {
      return new List<Case>();
    }

    if (!USER_INFO.checkProfile(ANZX_STANDARD_USER_PROFILE)) {
      return new List<Case>();
    }

    Set<String> notAllowedCaseStatus = new Set<String>{
      IDRConstants.OPEN_STATUS,
      IDRConstants.UNDER_INVESTIGATION_STATUS
    };

    return ListUtil.filter(newCases, oldMap)
      .changed(Case.OwnerId)
      .oldNotEquals(Case.Status, notAllowedCaseStatus)
      .toList();
  }
}