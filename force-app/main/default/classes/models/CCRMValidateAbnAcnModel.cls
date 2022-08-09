/**
 * @author Boobalakrishnan Duraisamy
 * @since March 2022
 * @description model for CCRM validate ABN ACN API (CCRMAPIRepository), extending the base
 * @group Models
 */
public with sharing class CCRMValidateAbnAcnModel extends CalloutModel {
  public String abn;
  public String abnStatus;
  public Date abnStatusEffectiveFrom;
  public String acn;
  public Date addressDate;
  public String addressState;
  public List<String> businessName;
  public String entityName;
  public String entityTypeCode;
  public String entityTypeName;
  public Date gst;
  public String message;

  /**
   * @param json input string to deserialize
   * @return CCRMValidateAbnAcnModel
   * @description deserializes the input string into the model
   */
  public static CCRMValidateAbnAcnModel parse(String json) {
    return (CCRMValidateAbnAcnModel) System.JSON.deserialize(
      json,
      CCRMValidateAbnAcnModel.class
    );
  }
}
