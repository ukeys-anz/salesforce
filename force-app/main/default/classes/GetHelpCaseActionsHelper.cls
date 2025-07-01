/**
 *
 * @author Jasmine Nguyen
 * @since 02/2021
 * @description Helper class for @link GetHelpCaseActions
 * CyclomaticComplexity Surpressed : The complexity of this test class is more than it is expected.
 * ExcessivePublicCount Surpressed : GetHelpCaseActions to have all the public methods and attributes together.
 */
@SuppressWarnings(
  'PMD.CyclomaticComplexity, PMD.ExcessivePublicCount, PMD.ExcessiveClassLength'
)
public with sharing class GetHelpCaseActionsHelper {
  public static final String YES = 'Yes';
  public static final String FRAUD_GENERIC_CUSTOMER_NAME = 'Fraud Entitlement Account';
  // Set of record type Ids that will be sent to PEGA
  public static final Set<Id> DISPUTE_PEGA_RT_IDS = new Set<Id>{
    RTCase.atmDispute,
    RTCase.cardDispute,
    RTCase.nppDispute,
    RTCase.imtDispute
  };

  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );

  // Parent Case validation error message
  private static final String PARENT_CASE_ERROR = 'You cannot add parent case. This case is associated with child cases';

  private static final String MORE_THAN_TWO_ADDITIONAL_TYPES_ERROR_MSG = 'You cannot select more than two Additional Types.';
  private static final String SAME_ADDITIONAL_TYPES_ERROR_MSG = 'You cannot select a value in Additional Type that is already selected as the Primary Type.';
  private static final String NO_ENTITLEMENT_ERROR_MSG = 'No entitlement found for account.';

  public static Group cadReferralQueue = QueryQueue.get(
    'CAD_Credit_Referral_Case_Queue'
  );
  public static Group coachRefQueue = QueryQueue.get(
    'No_CAD_Credit_Referral_Case_Queue'
  );

  public static final String CREDIT_REF_ASSIGN_ERROR_ONE = 'You can\'t assign a credit referral case that you do not have authority to resolve. Please select another case.';
  public static final String CREDIT_REF_ASSIGN_ERROR_TWO = 'You can\'t assign a credit referral case to someone who does not have the authority to resolve it.';
  public static final String CREDIT_REF_ASSIGN_ERROR_THREE = 'You can\'t assign the credit referral case directly to someone else. Please assign the case back to the queue for it to be picked up.';
  public static final String CREDIT_REF_EDIT_ERROR = 'Only the Case Owner or Credit Assessor Lead can edit this credit referral case.';
  public static final String CREDIT_REF_ASSIGN_QUEUE_ERROR_ONE = 'You can\'t assign this credit referral case to this queue as it doesn\'t meet the minimum authority level needed to resolve it. Please select another queue.';
  public static final String CREDIT_REF_ASSIGN_QUEUE_ERROR_TWO = 'You can\'t assign this credit referral case by changing the Case Owner field. Please update the case status to Escalated to assign to another queue.';

  /**
   * @description  This method checks if Additional_Type__c has more than 2 values selected or
   * if the Type value is same as one of the additional values
   * @param caseList The caseList for which Additional_Type__c needs to be checked
   */
  public static void checkAdditionalTypes(List<Case> caseList) {
    for (Case singleCase : caseList) {
      if (singleCase.Additional_Type__c != null) {
        List<String> additionalTypes = singleCase.Additional_Type__c.split(';');

        if (additionalTypes.size() > 2) {
          singleCase.addError(MORE_THAN_TWO_ADDITIONAL_TYPES_ERROR_MSG);
        }

        for (String additionalType : additionalTypes) {
          if (additionalType == singleCase.Type) {
            singleCase.addError(SAME_ADDITIONAL_TYPES_ERROR_MSG);
          }
        }
      }
    }
  }

  /**
   * @description validateParentCase method is called before updating the case record to check and throw error if the record is having child cases
   * @param caseIds set of case ids from the trigger
   * @param validateCaseList list of case records from the trigger
   */
  public static void validateParentCase(
    Set<Id> caseIds,
    List<Case> validateCaseList
  ) {
    Set<Id> parentCaseIds = getParentCaseIds(caseIds);

    for (Case record : validateCaseList) {
      if (parentCaseIds.contains(record.id)) {
        record.addError(PARENT_CASE_ERROR);
      }
    }
  }

  @TestVisible
  private static Set<Id> getChildCaseListMock;
  /**
   * @description Get child records
   * @param caseIds Case Ids of the records from trigger
   * @return Set<Id> parent Ids with child records
   */
  public static Set<Id> getParentCaseIds(Set<Id> caseIds) {
    List<Case> childCaseList = new List<Case>();

    if (Schema.sObjectType.Case.isQueryable()) {
      childCaseList = [
        SELECT Id, ParentId
        FROM Case
        WHERE ParentId IN :caseIds
      ];
    }

    Set<Id> parentCaseIds = new Set<Id>();
    for (Case childCase : childCaseList) {
      parentCaseIds.add(childCase.ParentId);
    }

    return parentCaseIds;
  }

  /**
   * @description Get a set of bug Ids
   * @param bugIdSet a list of cases that we need to check for bugs
   * @return list of reported bugs
   */
  public static List<Reported_Bug__c> getReportedBugs(Set<Id> bugIdSet) {
    return [
      SELECT Id, (SELECT Id FROM Cases__r)
      FROM Reported_Bug__c
      WHERE Id IN :bugIdSet
    ];
  }

  /**
   * @description Get a list of account Ids related to entitlement enabled cases
   * @param caseList a list of cases that we need to get account ids from
   * @return list of account ids
   */
  public static Set<Id> getEntitlementAccountIds(List<Case> caseList) {
    Set<Id> accountIds = new Set<Id>();

    for (Case c : caseList) {
      if (
        (c.RecordTypeId == RTCase.generalInquiry ||
        c.RecordTypeId == RTCase.customerFeedback ||
        CheckCaseRecordType.isDispute(c) ||
        c.RecordTypeId == RTCase.confirmationOfPayee ||
        (c.RecordTypeId == RTCase.caseGroup &&
        (c.Type == 'Confirmation of Payee Opt-In' ||
        c.Type == 'Confirmation of Payee Opt-Out'))) && c.AccountId != null
      ) {
        accountIds.add(c.AccountId);
      }
    }
    return accountIds;
  }

  /**
   * @description Get a list of account Ids from general enquiry cases
   * @param accountIds a list of account Ids
   * @param name name of the entitilement
   * @return Map of account Ids and their entitlement Ids
   */
  public static Map<Id, Id> getEntitlements(Set<Id> accountIds, String name) {
    Map<Id, Id> entMap = new Map<Id, Id>();
    if (
      accountIds.isEmpty() || PermissionUtils.canQuery('Entitlement') == false
    ) {
      return entMap;
    }

    for (Entitlement en : [
      SELECT Id, AccountId
      FROM Entitlement
      WHERE AccountId IN :accountIds AND EndDate = NULL AND Name = :name
    ]) {
      entMap.put(en.AccountId, en.Id);
    }

    return entMap;
  }

  /**
   * @description Update the Entitlement Id on the case and the parent account has an entitlement
   * @param caseList a list of cases that we need to update the entitlement Id
   * @param entMap a map of account id and its corresponding entitlement id
   */
  public static void updateEntitlementIdOnCase(
    List<Case> caseList,
    Map<Id, Id> entMap
  ) {
    for (Case c : caseList) {
      if (
        (c.RecordTypeId == RTCase.generalInquiry ||
        c.RecordTypeId == RTCase.customerFeedback ||
        CheckCaseRecordType.isDispute(c) ||
        c.RecordTypeId == RTCase.confirmationOfPayee ||
        (c.RecordTypeId == RTCase.caseGroup &&
        (c.Type == 'Confirmation of Payee Opt-In' ||
        c.Type == 'Confirmation of Payee Opt-Out'))) && c.AccountId != null
      ) {
        if (!entMap.containsKey(c.AccountId)) {
          c.addError(NO_ENTITLEMENT_ERROR_MSG);
        } else {
          c.EntitlementId = entMap.get(c.AccountId);
        }
      } else if (
        (c.RecordTypeId == RTCase.nonCustomerComplaint &&
        c.Origin == GetHelpConstants.ANZ_PLUS_WEB_ORIGIN)
      ) {
        c.EntitlementId = IDRCaseActions.getEntitlement();
        c.IDR_Milestone_Sla__c = IDRConstants.MILESTONE_SLA_NORMAL;
      } else if (c.RecordTypeId == RTCase.anzxComplaint) {
        c.EntitlementId = IDRCaseActions.getEntitlement();
        c.IDR_Milestone_Sla__c = IDRCaseActions.getMilestoneSla(
          c.Status,
          c.IDR_Date_Received__c,
          c.BusinessHoursId
        );
      }
    }
  }

  /**
   * @description Check if a case is General Enquiry or a case requires addtional type check
   * @param record The case record to check
   * @param oldCaseMap old case map
   * @return if the case is a General Enquiry
   */
  public static Boolean isEnquiryOrAdditionalCheckRequired(
    Case record,
    Map<Id, Case> oldCaseMap
  ) {
    if (
      record.RecordTypeId == RTCase.generalInquiry &&
      (String.isNotBlank(record.Type) ||
      String.isNotBlank(record.Additional_Type__c)) &&
      (oldCaseMap == null ||
      (record.Type != oldCaseMap.get(record.Id).Type ||
      record.Additional_Type__c !=
      oldCaseMap.get(record.Id).Additional_Type__c ||
      record.RecordTypeId != oldCaseMap.get(record.Id).RecordTypeId))
    ) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * @description getCaseNumberByTransactionId is called to get all open cases that are linked to a set of transaction Ids
   * @param transactionIds set of transaction Ids
   * @return Map<String, String> a map of case number by their transaction Id
   */
  public static Map<String, String> getCaseNumberByTransactionId(
    Set<String> transactionIds
  ) {
    //remove any null values from the set to ensure case can be created
    transactionIds.remove(null);
    Map<String, String> caseNumberByTransactionId = new Map<String, String>();
    for (Case c : [
      SELECT CaseNumber__c, Transaction_Id__c
      FROM Case
      WHERE Transaction_Id__c IN :transactionIds AND Status != 'Closed'
    ]) {
      caseNumberByTransactionId.put(c.Transaction_Id__c, c.CaseNumber__c);
    }
    return caseNumberByTransactionId;
  }

  /**
   * @description This method check if a case has "Closed" status
   * @param record The case record
   * @return Boolean if a case's status is "Closed"
   */
  public static Boolean isClosed(Case record) {
    Boolean isClosed = record.Status == 'Closed' ? true : false;
    return isClosed;
  }

  /**
   * @description Gett a list of financial account roles based on financial account id, account ids and if the role should be active
   * @param accountIds List of account Ids
   * @param financialAccIds Set of financial account Ids
   * @param isActive If the financial account role is active
   * @return Map<Id, FinServ__FinancialAccountRole__c> a map of financial account roles and their Ids
   */
  public static Map<Id, FinServ__FinancialAccountRole__c> getFinancialAccountRolesMap(
    Set<Id> accountIds,
    Set<Id> financialAccIds,
    Boolean isActive
  ) {
    Map<Id, FinServ__FinancialAccountRole__c> financialRolesMap = new Map<Id, FinServ__FinancialAccountRole__c>();
    if (
      FinServ__FinancialAccountRole__c.SObjectType.getDescribe().isAccessible()
    ) {
      financialRolesMap = new Map<Id, FinServ__FinancialAccountRole__c>(
        [
          SELECT Id, FinServ__FinancialAccount__c, FinServ__RelatedAccount__c
          FROM FinServ__FinancialAccountRole__c
          WHERE
            FinServ__FinancialAccount__c IN :financialAccIds
            AND FinServ__RelatedAccount__c IN :accountIds
            AND FinServ__Active__c = :isActive
        ]
      );
    }
    return financialRolesMap;
  }

  /**
   * @description Checks if a case is a valid PEGA dispute
   * @param record The case record
   * @return Boolean if a case is a valid PEGA dispute
   */
  public static Boolean isValidPegaDispute(Case record) {
    if (
      (record.RecordTypeId == RTCase.nppDispute &&
      record.Dispute_Reason__c ==
      GetHelpCaseAssignmentRules.UNAUTHORISED_TRANSACTION) ||
      record.Is_PayTo_Dispute__c
    ) {
      return false;
    }
    return DISPUTE_PEGA_RT_IDS.contains(record.RecordTypeId) &&
      record.Submitted__c &&
      record.Status == 'Open';
  }

  /**
   * @description Build a list of platform events from the dispute cases' details
   * @param records New record instances to process
   * @return List<sObject> List of platform events to publish
   */
  public static List<sObject> buildPegaPlatformEvents(List<Case> records) {
    List<sObject> peList = new List<sObject>();
    for (Case record : records) {
      // Create a list of platform events
      Disputes_PEGA_Integration_Event__e pe = new Disputes_PEGA_Integration_Event__e(
        Case_Id__c = record.Id,
        Transaction_Id__c = record.Transaction_Id__c,
        Original_Case_Number__c = (record.CaseNumber__c != null)
          ? record.CaseNumber__c
          : record.CaseNumber,
        Record_Type_Name__c = QueryRT.of(Case.SObjectType)
          .get(record.RecordTypeId)
          .Name,
        Span_Id__c = UniqueIdUtil.generateSpanId(),
        Correlation_Id__c = UniqueIdUtil.getTraceId()
      );
      peList.add(pe);
    }
    return peList;
  }

  /**
   * @description Check if the case is a non customer complaint and if the user
   * is ANZx
   * @param records New record instances to process
   */
  public static void setANZxCustomerNonCustomerComplaints(List<Case> records) {
    for (Case record : records) {
      if (
        record.RecordTypeId == RTCase.nonCustomerComplaint &&
        UserInfo.getProfileId() ==
        CommonUtil.getProfileByName('ANZx Standard User').Id
      ) {
        record.ANZx_Customer__c = true;
      }
    }
  }

  /**
   * @description Check if the case is a credit referral case and assign application id and customer to case
   * is ANZx
   * @param records New record instances to process
   */
  public static void setCreditReferralApplication(List<Case> records) {
    Map<String, Case> mapCase = new Map<String, Case>();
    for (Case record : records) {
      if (
        record.RecordTypeId == RTCase.creditReferral &&
        String.isNotBlank(record.Credit_Id__c)
      ) {
        mapCase.put(record.Credit_Id__c, record);
      }
    }

    if (mapCase.isEmpty()) {
      return;
    }

    for (ResidentialLoanApplication rla : [
      SELECT Credit_ID__c, AccountId, Account.PersonContactId
      FROM ResidentialLoanApplication
      WHERE Credit_ID__c = :mapCase.keySet()
    ]) {
      Case newCase = mapCase.get(rla.Credit_ID__c);
      newCase.AccountId = rla.AccountId;
      newCase.Loan_Application__c = rla.Id;
      newCase.ContactId = rla.Account.PersonContactId;

      mapCase.put(newCase.Credit_Id__c, newCase);
    }
  }

  /**
   * @description Check if the account on the case has changed
   * @param records New record instances to process
   * @param oldCaseMap Old case map
   * @return Boolean if a case's account id has changed
   */
  public static Boolean hasAccountUpdated(
    List<Case> records,
    Map<Id, Case> oldCaseMap
  ) {
    for (Case record : (List<Case>) records) {
      if (record.AccountId != oldCaseMap.get(record.Id).AccountId) {
        return true;
      }
    }
    return false;
  }

  /**
   * @description Set card to null if status isn't open
   * @param record Case to process
   */
  public static void handleCardTokenNumber(Case record) {
    if (record.Status != GetHelpConstants.OPEN_STATUS) {
      record.Card_Token_Number__c = null;
    }
  }

  /**
   * @description This method will check if a case is converted from AEM to General Inquiry/ANZX Complaint/Non-Cusotmer Complaint
   * @param oldRecord case: old values of a record to process
   * @param newRecord case: new record instances to process
   * @return Boolean find all the AEM converted cases.
   */
  public static Boolean isAEMConverted(Case oldRecord, Case newRecord) {
    List<String> convertedTypes = new List<String>{
      RTCase.generalInquiry,
      RTCase.anzxComplaint,
      RTCase.nonCustomerComplaint
    };
    return CheckCaseRecordType.isUnauthenticatedEnquiry(oldRecord) &&
      newRecord.ANZx_Customer__c &&
      newRecord.Origin == GetHelpConstants.ANZ_PLUS_WEB_ORIGIN &&
      convertedTypes.contains(newRecord.RecordTypeId);
  }

  /**
   * @description This method will check if the case is converted from AEM to General Inquiry/ANZX Complaint/Non-Cusotmer Complaint
   * @param oldMap Map<Id, Case> oldMap: Map of the old values of the records to process
   * @param caseList List<Case> caseList: New record instances to process
   * @return List<Case> find all the AEM converted cases.
   */
  public static List<Case> filterAEMConvertedCases(
    Map<Id, Case> oldMap,
    List<Case> caseList
  ) {
    List<Case> filteredCases = new List<Case>();
    for (Case newRecord : caseList) {
      Case oldRecord = (Case) oldMap.get(newRecord.Id);
      if (isAEMConverted(oldRecord, newRecord)) {
        filteredCases.add(newRecord);
      }
    }
    return filteredCases;
  }

  /**
   * @description  handleEntitlementForUpdate method is used to update the entitlment and time to escalation flag for ANZ Plus Complaints.
   * 1. when a case is updated by the indexing team. entitlment ID and Flag both need to be calculated.
   * 2. when a case has a status change. Flag status is needs to be recalculated.
   * Note : IDR_Milestone_Sla__c is updated by entitlment process. this code is to handle the edge case scenarios.
   * where the date received is back dated and milestones warning actions will not execute.
   * @param record The actual case record from the trigger
   * @param oldRec The old record values for the case
   */
  public static void handleEntitlementForUpdate(Case record, Case oldRec) {
    //If status changes, recalculate the flag status.
    if (
      record.Status != oldRec.Status &&
      (record.Status == GetHelpConstants.UNDER_INVESTIGATION_STATUS ||
      record.Status == GetHelpConstants.OPEN_STATUS)
    ) {
      record.IDR_Milestone_Sla__c = IDRCaseActions.getMilestoneSla(
        record.Status,
        record.IDR_Date_Received__c,
        record.BusinessHoursId
      );
    }

    // if the date received has been updated , this information needs to flow on to SlaStartDate field. for the entitlments to work as expected.
    if (record.IDR_Date_Received__c != oldRec.IDR_Date_Received__c) {
      record.SlaStartDate = record.IDR_Date_Received__c;
    }
  }

  /**
   * @description Get Account Ids Entitlment map
   * @param accounts List of Accounts
   * @return Account Ids Entitlment map
   */
  public static Map<Id, Id> getAccountIdEntitlmentMap(List<Account> accounts) {
    Set<Id> accIds = (new Map<Id, SObject>(accounts)).keySet();
    // Get matched Accounts Entitelments
    return getEntitlements(
      accIds,
      GetHelpConstants.BASIC_SUBSCRIPTION_ENTITLEMENT_NAME
    );
  }

  /**
   * @description Check if user assigning credit ref case has authority to resolve it
   * @param newCase New values of the case
   * @param oldCase Old values of the case
   */
  public static void isNoAuthorityAssignment(Case newCase, Case oldCase) {
    if (
      isOwnerChanged(oldCase, newCase) && isInvalidAuthorityAssignment(newCase)
    ) {
      newCase.addError(CREDIT_REF_ASSIGN_ERROR_ONE);
    }
  }

  /**
   * @description Determines if the Case owner has changed and if the new owner is the current user.
   * @param oldCase The Case record before the update
   * @param newCase The Case record after the update
   * @return Boolean True if the owner changed and the new owner is the current user, false otherwise
   */
  private static Boolean isOwnerChanged(Case oldCase, Case newCase) {
    return oldCase.OwnerId != newCase.OwnerId &&
      newCase.OwnerId == UserInfo.getUserId();
  }

  /**
   * @description Validates if the case assignment authority is invalid based on user permissions and coaching assignments
   * @param newCase The Case record to validate
   * @return Boolean True if the assignment is invalid, false otherwise
   */
  private static Boolean isInvalidAuthorityAssignment(Case newCase) {
    return isUserWithoutAuthority() || isInvalidCoachOrPermission(newCase);
  }

  /**
   * @description Determines if the current user lacks specific roles or custom permission for case authority
   * @return Boolean Returns true if user does not have any of the specified roles
   */
  private static Boolean isUserWithoutAuthority() {
    return !USER_INFO.checkAnyRoles(
        new Set<String>{
          'Credit_Assessor_Lead',
          'BOH_Coach',
          'BOH_Coach_Lead',
          'Credit_Assessment_Officer'
        }
      ) && !USER_INFO.checkCustomPermission('ANZx_Transfer_Edit_Case');
  }

  /**
   * @description Checks if the user has invalid coach role or permission for the case
   * @param newCase The case record to validate
   * @return Boolean Returns true if user has BOH Coach/Lead role or transfer permission and case authority is not 'NO CAD'
   */
  private static Boolean isInvalidCoachOrPermission(Case newCase) {
    return (UserInfo.getUserRoleId() == QueryRole.bohCoachRole.Id ||
      USER_INFO.checkCustomPermission('ANZx_Transfer_Edit_Case') ||
      UserInfo.getUserRoleId() == QueryRole.bohCoachLeadRole.Id) &&
      newCase.Case_Authority_Level__c.toUpperCase() != 'NO CAD';
  }

  /**
   * @description Check if credit assessor lead is assigning credit ref case to users without authority to resolve it
   * @param newCase New values of the case
   * @param oldCase Old values of the case
   * @param isOwnerSpecialistLender if owner is avaialble in set then they are specialist lender
   */
  public static void isInvalidCreditLeadNoAuthorityAssignment(
    Case newCase,
    Case oldCase,
    Set<Id> isOwnerSpecialistLender
  ) {
    if (
      oldCase.OwnerId != newCase.OwnerId &&
      isCreditAssessLeadOrCoachLead() &&
      newCase.OwnerId.getSObjectType() != Group.SObjectType &&
      (checkOwnerRoleAndAuthLevel(newCase, isOwnerSpecialistLender) ||
      isValidOwner(newCase, isOwnerSpecialistLender))
    ) {
      newCase.addError(CREDIT_REF_ASSIGN_ERROR_TWO);
    }
  }

  /**
   * @description Check if user is Credit_Assessor_Lead or Coach_Lead or BOH_Coach_Lead
   * @return `Boolean`
   */
  private static Boolean isCreditAssessLeadOrCoachLead() {
    return USER_INFO.checkAnyRoles(
      new Set<String>{ 'Credit_Assessor_Lead', 'Coach_Lead', 'BOH_Coach_Lead' }
    );
  }

  /**
   * @description Check if owner role is BohCoach or is Specialist Lender and Authority Level is No CAD
   * @return `Boolean`
   * @param newCase New values of the case
   * @param isOwnerSpecialistLender if owner is avaialble in set then they are specialist lender
   */
  private static Boolean checkOwnerRoleAndAuthLevel(
    Case newCase,
    Set<Id> isOwnerSpecialistLender
  ) {
    return ((newCase.Owner_Role__c == QueryRole.bohCoachRole.Id ||
    newCase.Owner_Role__c == QueryRole.bohCoachLeadRole.Id ||
    isSpecialistLender(newCase, isOwnerSpecialistLender)) &&
    newCase.Case_Authority_Level__c.toUpperCase() != 'NO CAD');
  }

  /**
   * @description Check if user is Specialist Lender
   * @return `Boolean`
   * @param newCase New values of the case
   * @param isOwnerSpecialistLender if owner is avaialble in set then they are specialist lender
   */
  private static Boolean isSpecialistLender(
    Case newCase,
    Set<Id> isOwnerSpecialistLender
  ) {
    return isOwnerSpecialistLender.contains(newCase.OwnerId);
  }

  /**
   * @description Check if user is not bohCoach/specilaist lender/creditassessmentoffice/credit assessor lead
   * @return `Boolean`
   * @param newCase New values of the case
   * @param isOwnerSpecialistLender if owner is avaialble in set then they are specialist lender
   */
  private static Boolean isValidOwner(
    Case newCase,
    Set<Id> isOwnerSpecialistLender
  ) {
    return (newCase.Owner_Role__c != QueryRole.bohCoachRole.Id &&
    newCase.Owner_Role__c != QueryRole.bohCoachLeadRole.Id &&
    !isSpecialistLender(newCase, isOwnerSpecialistLender) &&
    newCase.Owner_Role__c != QueryRole.creditAssessmentOfficerRole.Id &&
    newCase.Owner_Role__c != QueryRole.creditAssessorLeadRole.Id);
  }

  /**
   * @description Check if user is assigning/reassigning case directly to another user
   * @param newCase New values of the case
   * @param oldCase Old values of the case
   */
  public static void isInvalidCreditRefAssignment(Case newCase, Case oldCase) {
    if (
      isNotOwnerAndLeadRole(newCase, oldCase) &&
      isOwnerAndNotAssignedToQueue(newCase, oldCase)
    ) {
      newCase.addError(CREDIT_REF_ASSIGN_ERROR_THREE);
    }

    if (
      isNotOwnerAndLeadRole(newCase, oldCase) &&
      isNotOwnerAndAssignedToQueue(newCase, oldCase)
    ) {
      newCase.addError(CREDIT_REF_ASSIGN_ERROR_THREE);
    }

    if (
      isNotOwnerAndLeadRole(newCase, oldCase) &&
      (oldCase.OwnerId.getSobjectType() == User.getSObjectType() &&
      oldCase.OwnerId != UserInfo.getUserId())
    ) {
      newCase.addError(CREDIT_REF_ASSIGN_ERROR_THREE);
    }
  }

  /**
   * @description Check if there is a change in owner and new owner is not credit assessor lead/coach lead/boh coach lead
   * @param newCase New values of the case
   * @param oldCase Old values of the case
   * @return `Boolean`
   */
  private static Boolean isNotOwnerAndLeadRole(Case newCase, Case oldCase) {
    return oldCase.OwnerId != newCase.OwnerId &&
      !USER_INFO.checkAnyRoles(
        new Set<String>{
          'Credit_Assessor_Lead',
          'Coach_Lead',
          'BOH_Coach_Lead'
        }
      );
  }

  /**
   * @description Check if new owner is not credit assessor lead/coach lead and old owner is current user
   * @param newCase New values of the case
   * @param oldCase Old values of the case
   * @return `Boolean`
   */
  private static Boolean isOwnerAndNotAssignedToQueue(
    Case newCase,
    Case oldCase
  ) {
    return (oldCase.OwnerId == UserInfo.getUserId() &&
    (newCase.OwnerId != coachRefQueue.Id &&
    newCase.OwnerId != cadReferralQueue.Id));
  }

  /**
   * @description Check if old owner is queue and new owner is not current user
   * @param newCase New values of the case
   * @param oldCase Old values of the case
   * @return `Boolean`
   */
  private static Boolean isNotOwnerAndAssignedToQueue(
    Case newCase,
    Case oldCase
  ) {
    return ((oldCase.OwnerId == coachRefQueue.Id ||
    oldCase.OwnerId == cadReferralQueue.Id) &&
    newCase.OwnerId != UserInfo.getUserId());
  }

  /**
   * @description Check if user is editing credit referral case without correct access
   * @param newCase New values of the case
   * @param oldCase Old values of the case
   */
  public static void isInvalidCreditRefEdit(Case newCase, Case oldCase) {
    //Allow integration user to be able to edit cases
    if (
      UserInfo.getProfileId() != QueryProfile.minimumAccessExternalApps.Id &&
      ((newCase.OwnerId == oldCase.OwnerId &&
      newCase.OwnerId != UserInfo.getUserId() &&
      UserInfo.getUserRoleId() != QueryRole.creditAssessorLeadRole.Id) ||
      (newCase.OwnerId == oldCase.OwnerId &&
      newCase.OwnerId.getSobjectType() == Group.getSObjectType() &&
      UserInfo.getUserRoleId() != QueryRole.creditAssessorLeadRole.Id))
    ) {
      newCase.addError(CREDIT_REF_EDIT_ERROR);
    }
  }

  /**
   * @description Prevent assignment of NO CAD authority to CAD referral queue unless it's escalated
   * @param newCase New values of the case
   * @param oldCase Old values of the case
   */
  public static void isInvalidCADQueueAssignment(Case newCase, Case oldCase) {
    if (
      oldCase.OwnerId != newCase.OwnerId &&
      newCase.OwnerId == cadReferralQueue.Id &&
      newCase.Status != 'Escalated' &&
      newCase.Case_Authority_Level__c.toUpperCase() == 'NO CAD'
    ) {
      newCase.addError(CREDIT_REF_ASSIGN_QUEUE_ERROR_TWO);
    }
  }

  /**
   * @description Prevent assignment of CAD authority to Coach queue
   * @param newCase New values of the case
   * @param oldCase Old values of the case
   */
  public static void isInvalidCoachQueueAssignment(Case newCase, Case oldCase) {
    if (
      oldCase.OwnerId != newCase.OwnerId &&
      newCase.OwnerId == coachRefQueue.Id &&
      newCase.Case_Authority_Level__c.toUpperCase() != 'NO CAD'
    ) {
      newCase.addError(CREDIT_REF_ASSIGN_QUEUE_ERROR_ONE);
    }
  }
}
