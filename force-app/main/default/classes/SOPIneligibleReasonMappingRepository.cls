/**
 * @author @ramvilas
 * @since September 2024
 * @description Repository class for SOP Ineligible Reason Mapping
 */

public with sharing class SOPIneligibleReasonMappingRepository {
  /**
   * @description reasonLabelToNameMap
   */
  public static Map<String, SOP_Ineligible_Reason_Mapping__mdt> reasonLabelToNameMap;

  static {
    List<SOP_Ineligible_Reason_Mapping__mdt> reasonMappinglist = SOP_Ineligible_Reason_Mapping__mdt.getAll()
      .values();
    reasonLabelToNameMap = (Map<String, SOP_Ineligible_Reason_Mapping__mdt>) ListUtil.mapBy(
      reasonMappinglist,
      SOP_Ineligible_Reason_Mapping__mdt.Ineligible_Reason_Type__c
    );
  }
}
