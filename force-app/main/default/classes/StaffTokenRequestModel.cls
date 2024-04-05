/**
 * @author Hinduja Upadhyay
 * @since Dec 2023
 * @description StaffTokenRequestModel Wrapper Class.
 */
public with sharing class StaffTokenRequestModel {
  /**
   * @description idType Enum for specifying which type of id is used: OCV ID or PERSONA ID
   */
  public Service.IdType idType { get; set; }
  /**
   * @description idValue ocv id or persona Id or mobile
   */
  public String idValue { get; set; }
  /**
   * @description set of anzTokenType replaces requested_token_type query parameter name for v2
   */
  public String anzTokenType { get; set; }
}
