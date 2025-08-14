/**
 *
 * @author Ram vilas
 * @since 07/2025
 * @description Class to handle Credit Referral Case actions
 */

public class CreditReferralCaseActions {
  private static final String FRAUD = 'FRAUD';
  private static final String ESCALATED_STATUS = 'Escalated';
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static Id cadRefQueue = QueryQueue.get(
      'CAD_Credit_Referral_Case_Queue'
    )
    ?.Id;
  private static Id noCadRefQueue = QueryQueue.get(
      'No_CAD_Credit_Referral_Case_Queue'
    )
    ?.Id;
  private static Id fraudRefQueue = QueryQueue.get(
      'Fraud_Credit_Referral_Case_Queue'
    )
    ?.Id;

  private static final String CREDIT_REF_ASSIGN_ERROR = 'You can\'t assign a credit referral case to someone who does not have the authority to resolve it.';

  /**
   * @description Auto assignment of credit ref cases based on authoerity level
   * @param records List<Case>
   * @return List<Case>
   */
  public static List<Case> ownerAssignment(List<Case> records) {
    List<Case> defaultCases = ListUtil.filter(records)
      .notEquals(Case.Case_Authority_Level__c, FRAUD)
      .toList();

    List<Case> fraudCases = ListUtil.filter(records)
      .equals(Case.Case_Authority_Level__c, FRAUD)
      .toList();

    ListUtil.setField(defaultCases, case.OwnerId, noCadRefQueue);

    ListUtil.setField(fraudCases, case.OwnerId, fraudRefQueue);

    return records;
  }

  /**
   * @description If Authority level is changing to fraud then owner change required
   * @param records List<Case>
   * @param oldMap Map<Id, Case>
   * @return List<Case>
   */
  public static List<Case> ownerUpdateToFruadCases(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> fraudCases = ListUtil.filter(records, oldMap)
      .changedTo(Case.Case_Authority_Level__c, FRAUD)
      .toList();

    ListUtil.setField(fraudCases, case.OwnerId, fraudRefQueue);

    return records;
  }

  /**
   * @description Update case status to Escalated
   * @param records List<Case>
   * @param oldMap Map<Id, Case>
   * @return List<Case>
   */
  public static List<Case> escalateFraudCase(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> fraudCases = new List<Case>();
    fraudCases = ListUtil.filter(records, oldMap)
      .changedTo(Case.Case_Authority_Level__c, FRAUD)
      .toList();
    ListUtil.setField(fraudCases, Case.Status, ESCALATED_STATUS);
    return records;
  }

  /**
   * @description update RLA Application progress to escalate
   * @param records List<Case>
   * @param oldMap Map<Id, Case>
   */
  public static void escalateRLA(List<Case> records, Map<Id, Case> oldMap) {
    List<Case> fraudCases = ListUtil.filter(records, oldMap)
      .changedTo(Case.Case_Authority_Level__c, FRAUD)
      .toList();

    Set<Id> rlaIds = ListUtil.getIds(fraudCases, Case.Loan_Application__c);

    List<ResidentialLoanApplication> rlaListToUpdate = new List<ResidentialLoanApplication>();
    for (Id rlaId : rlaIds) {
      rlaListToUpdate.add(
        new ResidentialLoanApplication(
          Id = rlaId,
          Application_Progress__c = ESCALATED_STATUS
        )
      );
    }

    DML_REPOSITORY.doUpdate(rlaListToUpdate);
  }

  /**
   * @description check if AL is fraud then owner can only be fraudx agent
   * @param records List<Case>
   * @param oldMap Map<Id, Case>
   */
  public static void invalidUserForFraudCase(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> fraudALCases = ListUtil.filter(records, oldMap)
      .equals(Case.Case_Authority_Level__c, FRAUD)
      .notEquals(
        Case.Assessment_Outcome__c,
        new Set<String>{ 'Approved', 'Declined' }
      )
      .toList();
    for (Case fraudCase : fraudALCases) {
      if (
        fraudCase.OwnerId.getSobjectType() == User.getSObjectType() &&
        fraudCase.Owner_Role__c != QueryRole.fraudXAgent.Id
      ) {
        fraudCase.addError(CREDIT_REF_ASSIGN_ERROR);
      }
    }
  }

  /**
   * @description check if AL is fraud and outcome is not completed then owner can only be updated to Fraud Queue or Fraud agent
   * @param records List<Case>
   * @param oldMap Map<Id, Case>
   */
  public static void invalidOutcomeToUpdateOwner(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> fraudALCases = ListUtil.filter(records, oldMap)
      .equals(Case.Case_Authority_Level__c, FRAUD)
      .equals(
        Case.Assessment_Outcome__c,
        new Set<String>{ 'Processing', 'Referred' }
      )
      .changed(Case.OwnerId)
      .notEquals(Case.OwnerId, fraudRefQueue)
      .toList();
    for (Case fraudCase : fraudALCases) {
      //Allowing the ownership change only for Fraud Agents
      if (
        (fraudCase.OwnerId.getSobjectType() == Group.getSObjectType()) ||
        (fraudCase.OwnerId.getSobjectType() == User.getSObjectType() &&
        fraudCase.Owner_Role__c != QueryRole.fraudXAgent.Id)
      ) {
        fraudCase.addError(CREDIT_REF_ASSIGN_ERROR);
      }
    }
  }
}
