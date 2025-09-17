/**
 * @description Represents the model for response from broker MFA reset API.
 *  Provides a method for parsing JSON data into the model.
 */
public with sharing class MFAResetModel extends CalloutModel {
  public RemovedByDeviceType removedByDeviceType;

  /**
   * @description nested model body within the parent type
   */
  public class RemovedByDeviceType {
    @SuppressWarnings('PMD.FieldNamingConventions')
    public Integer TYPE_OATH_TOTP;
  }

  /**
   * @description Parses a JSON string and returns an instance of MFAResetModel by deserializing the provided JSON data.
   *
   * @param jsonStr JSON string to parse
   * @return `MFAResetModel` deserialied object from json string
   */
  public static MFAResetModel parse(String jsonStr) {
    return (MFAResetModel) deserialize(jsonStr, MFAResetModel.class);
  }

  /**
   * @description Checks if reset response is for success, or failure.
   *
   * @return true when resposne body indicates that a MFA reset was successful, otherwise false.
   */
  public Boolean isResetSuccess() {
    return 1 == this.removedByDeviceType?.TYPE_OATH_TOTP;
  }
}
