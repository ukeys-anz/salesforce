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
  /**
   * @description Name of the Forgerock_Auth_mdt custom metadata that contains the scopes requested by the API
   */
  public String apiScopesRequested { get; set; }
  /**
   * @description Name of the realm custom metadata that contains the scopes requested by the API
   */
  public String realm { get; set; }
  /**
   * @description constructor to set the default value for apiScopesRequested
   */
  public StaffTokenRequestModel() {
    apiScopesRequested = 'ForgeV2';
    realm = 'customer';
  }
}
