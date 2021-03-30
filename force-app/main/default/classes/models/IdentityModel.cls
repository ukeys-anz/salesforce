/**
 * @author Lance Shi
 * @since March 2021
 * @description model for accounts and goals API, extending the base
 */
public with sharing class IdentityModel extends CalloutModel {
  public String accessToken;
  public String refreshToken;
  public String idToken;
  public long expiresOn;
  public long expiresIn;

  /**
   * @param jsonStr input string to deserialize
   * @return `IdentityModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static IdentityModel parse(String jsonStr) {
    IdentityModel idenModel = (IdentityModel) deserialize(
      jsonStr,
      IdentityModel.class
    );

    if (idenModel.expiresOn == null) {
      //expires_on is not populated in response
      // Add now() datetime to the expires in (which is typically 3599 secs)
      Long currentTime = Datetime.now().getTime() / 1000; // Saleforce returns this in milliseconds, and expires_in is seconds so need to convert to seconds
      idenModel.expiresOn = currentTime + idenModel.expiresIn;
    }
    return idenModel;
  }
}
