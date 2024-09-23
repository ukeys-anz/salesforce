/**
 * @author @ramvilas
 * @since August 2024
 * @description Model for SOP Ineligible reason
 */

public with sharing class SOPIneligibleModel extends CalloutModel {
  /**
   * @description ineligibleReasonsWithInfo
   */
  public IneligibleReasonsWithInfo[] ineligibleReasonsWithInfo { get; set; }

  /**
   * @description isError
   */
  public Boolean isError = false;

  /**
   * @description IneligibleReasonsWithInfo wrapper
   */
  public class IneligibleReasonsWithInfo {
    /**
     * @description ineligibleReasonType
     */
    public String ineligibleReasonType {
      get;
      set {
        ineligibleReasonType = SOPIneligibleReasonMappingRepository.reasonLabelToNameMap.get(
            value
          )
          ?.Ineligible_Reason_Display_Name__c ?? value;
      }
    }

    /**
     * @description details
     */
    public Details[] details { get; set; }
  }

  /**
   * @description Details wrapper
   */
  public class Details {
    /**
     * @description ocvId
     */
    public string ocvId { get; set; }

    /**
     * @description accountNumber
     */
    public string accountNumber { get; set; }

    /**
     * @description productSubCode
     */
    public string productSubCode { get; set; }

    /**
     * @description accountRelationshipType
     */
    public string accountRelationshipType { get; set; }

    /**
     * @description capcisId
     */
    public string capcisId { get; set; }
  }
}
