/** 
@author Hinduja Upadhyay
* @since April 2024
* @description Model class for AUF
* @group Service
*/
public with sharing class TFMAUFPayloadModel {
  /**
   * @description class having variables
   */
  public class TFMAUFPayload {
    public String field;
    public String operation;
    public String value;
    /**
     * @param field string
     * @param operation string
     * @param value string
     * @description constructor for getConsentAccountList payload
     */
    public TFMAUFPayload(String field, String operation, String value) {
      this.field = field;
      this.operation = operation;
      this.value = value;
    }
  }
}
