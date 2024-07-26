/**
 * @description Trigger handler for Loan Application Property
 * @author @fangl6
 * @since 11/06/2024
 */
public with sharing class LoanApplicationPropertyTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description constructor
   */
  public LoanApplicationPropertyTriggerHandler() {
    super();
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap trigger old map
   */
  public override void handleAfterUpdate(Map<Id, SObject> oldMap) {
    LoanApplicationPropertyActions.updateRelatedCases(
      (List<LoanApplicationProperty>) records,
      (Map<Id, LoanApplicationProperty>) oldMap
    );
  }
}
