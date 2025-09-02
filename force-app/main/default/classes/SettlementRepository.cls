/**
 * @description repository class for Settlement records
 * @author @peter
 * @since 06-Aug-2024
 */
public with sharing class SettlementRepository {
  /**
   * @description
   * @return  `List<ActionPlanTemplateVersion>` properties related to the RLAs
   */
  public List<ActionPlanTemplateVersion> queryActionPlanTemplateVersion() {
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
