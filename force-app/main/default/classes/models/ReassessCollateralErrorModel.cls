/**
 * @author Peter Charalambous
 * @since Thu Jun 20 2024
 * @description Model for error response on reassess collateral
 */
public with sharing class ReassessCollateralErrorModel extends CalloutModel {
  public Integer code;
  public String message;
  public List<Details> details;

  /**
   * @description Details node
   */
  public class Details {
    public String type;
    public String timestamp;
    public String traceId;
    public String requestId;
    public String errorCode;
    public String reason;
  }

  /**
   * @param json input string to deserialize
   * @return `ReassessCollateralErrorModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static ReassessCollateralErrorModel parse(String json) {
    return (ReassessCollateralErrorModel) deserialize(
      json,
      ReassessCollateralErrorModel.class
    );
  }
}
