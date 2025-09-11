/**
 * @description Represents the model for MFA reset elevated token response.
 * Provides a method to parse a JSON string into the model.
 */
public with sharing class MFAResetElevatedTokenModel extends CalloutModel {
  public String accessToken;
  public String tokenType;
  public Integer expiresIn;
  public String scope;

  /**
   * @description Parses a JSON string and returns an instance of MFAResetElevatedTokenModel by deserializing the provided JSON data.
   *
   * @param jsonStr JSON string to parse
   * @return `MFAResetElevatedTokenModel` deserialied object from json string
   */
  public static MFAResetElevatedTokenModel parse(String jsonStr) {
    return (MFAResetElevatedTokenModel) deserialize(
      jsonStr,
      MFAResetElevatedTokenModel.class
    );
  }
}
