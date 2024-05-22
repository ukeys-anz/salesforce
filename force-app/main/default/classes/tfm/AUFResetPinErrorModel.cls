/** 
@author Hinduja Upadhyay
* @since April 2024
* @description Model class for AUF
* @group TFM
*/
public with sharing class AUFResetPinErrorModel extends CalloutModel {
  /**
   * @description class having variables
   */

  public class AdditionalInfo {
    public String reason;
    public String category;
    public ErrorDetails errorDetails;
  }
  /**
   * @description class having variables
   */
  public class Details {
    public String name;
    public String reason;
  }
  /**
   * @description class having variables
   */

  public String code;
  public String message;
  public AdditionalInfo additionalInfo;
  /**
   * @description class having variables
   */
  public class Error {
    public String code;
    public String description;
    public List<Details> details;
  }
  /**
   * @description class having variables
   */
  public class ErrorDetails {
    public Error error;
  }
  /**
   * @description Represents Error body for AUF Reset Pin API
   * @param json json response from AUF Reset Pin API
   * @return `AUFResetPinErrorModel` api response is serialised into AUFResetPinErrorModel
   */
  public static AUFResetPinErrorModel parse(String json) {
    return (AUFResetPinErrorModel) deserialize(
      json,
      AUFResetPinErrorModel.class
    );
  }
}
