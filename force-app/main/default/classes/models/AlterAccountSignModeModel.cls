/**
 * @author Hrushikesh
 * @since Dec 2023
 * @description SignModeUpdate Model to get response from Fabric thru mule
 * @design https://confluence.service.anz/pages/viewpage.action?pageId=2253292239
 * @group Model
 */
public with sharing class AlterAccountSignModeModel extends CalloutModel {
  public static final String ANZ_ERROR = 'anz.type.ErrorInfo';

  public Integer httpCode;
  public String message;
  public String status;
  public Error errors;
  public Boolean isDefaultError = false;

  /**
   * @description error overview
   */
  public class Error {
    public Integer code;
    public String message;
    public List<Details> details;
  }

  /**
   * @description error details
   */
  public class Details {
    public String gcpMessageType;
    /**
     * @description returns true if error is from anz gcp service
     */
    public Boolean isAnzError {
      get {
        return (String.isNotBlank(gcpMessageType) &&
        gcpMessageType.contains(ANZ_ERROR));
      }
    }
    public Integer errorCode;
    public String reason;
  }

  /**
   * @param json json String
   * @return `AlterAccountSignModeModel` the api response wrapper
   * @description transposes the string into object
   */
  public static AlterAccountSignModeModel.Error parse(String json) {
    return (AlterAccountSignModeModel.Error) deserialize(
      json,
      AlterAccountSignModeModel.Error.class
    );
  }
}
