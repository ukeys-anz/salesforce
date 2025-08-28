/**
 * @description repository class for action plan records
 * @author Peter Charalambous
 * @since 06-Aug-2024
 */
public with sharing class ActionPlanRepository {
  /**
   * @description retrieve action plan details related to settlement
   * @return  `List<ActionPlanTemplateVersion>`
   */
  public List<ActionPlanTemplateVersion> queryActionPlanTemplateVersionForSettlement() {
    if (SObjectType.ActionPlanTemplateVersion.isQueryable() == false) {
      return new List<ActionPlanTemplateVersion>();
    }
    return [
      SELECT Id, Name
      FROM ActionPlanTemplateVersion
      WHERE
        Name IN (
          :SettlementActions.EXTERNAL_SETTLEMENT_PLAN,
          :SettlementActions.INTERNAL_SETTLEMENT_PLAN
        )
        AND Status = 'Final'
    ];
  }
}
