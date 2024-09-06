/**
 * @author Shivam Swaraj
 * @since August 2024
 * @description Request Model to store Detokenized Full Card Number response received from Vault via GCP
 */
public with sharing class DetokenizationRequestModel {
  /**
   * @description tokenizedCardNumber to be sent to be detokenized
   */
  public String tokenizedCardNumber { get; set; }
}
