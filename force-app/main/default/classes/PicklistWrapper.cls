/**
 * @author Shermal Warnakula
 * @since 09/2021
 * @description Wrapper class to serve Picklist attibutes
 */
public with sharing class PicklistWrapper {
  /**
   * @description Picklist value/key
   */
  public String value { get; set; }
  /**
   * @description Picklist label
   */
  public String label { get; set; }
  /**
   * @description Controlling Picklist (parent) Value
   */
  public List<String> controllingPLValues { get; set; }
}
