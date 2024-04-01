/**
 * @author Laxmi Teja Vuyyuru
 * @since January 2024
 * @description Simple mode for CIBA Authentication response
 */

@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing class CIBAAccessTokenResponseModel {
  //Success response
  public String access_token;
  public String scope;
  public String idToken;
  public String tokenType;
  public Integer expires_in;
  //Error response
  public String code;
  public String message;
  public AdditionalInfo additionalInfo;
  /**
   * @description Additional Information of authentication response
   */
  public class AdditionalInfo {
    public String reason;
    public String category;
    public ErrorDetails errorDetails;
  }

  /**
   * @description ErrorDetails Information of authentication response
   */
  public class ErrorDetails {
    public String error_description;
    public String error;
  }
  /**
   * @param json input string to deserialize
   * @return CIBAAccessTokenResponseModel
   * @description deserializes the input string into the model
   */
  public static CIBAAccessTokenResponseModel parse(String json) {
    return (CIBAAccessTokenResponseModel) System.JSON.deserialize(
      json,
      CIBAAccessTokenResponseModel.class
    );
  }
}
