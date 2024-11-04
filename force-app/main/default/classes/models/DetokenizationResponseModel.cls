/**
 * @author Shivam Swaraj
 * @since August 2024
 * @description Response Model to store Detokenized Full Card Number response received from Vault via GCP
 */
public with sharing class DetokenizationResponseModel extends CalloutModel {
  public String value;
  public String initializationVector;
  public String publicKeyId;

  /**
   * @param responseInput input string to deserialize
   * @return `DetokenizationResponseModel`
   * @description deserializes the input string into the model
   */
  public static DetokenizationResponseModel parse(String responseInput) {
    return (DetokenizationResponseModel) deserialize(
      responseInput,
      DetokenizationResponseModel.class
    );
  }
}
