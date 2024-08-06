/**
 * @author Batya Aisman Sufrin
 * @since February 2024
 * @description Model for Stravinsky Customer Onboarding API Error Response
 */
public with sharing class COBRASErrorModel extends CalloutModel {
  public String code;
  public String message;
  public List<Details> details;

  /**
   * @description Details node
   */
  public class Details {
    public String type;
    public String value;
    public Debug debug;
  }

  /**
   * @description Debug node
   */
  public class Debug {
    public String cxOnboardingStage;
    public String reason;
  }

  /**
   * @param json input string to deserialize
   * @return `COBRASErrorModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static COBRASErrorModel parse(String json) {
    try {
      return (COBRASErrorModel) deserialize(json, COBRASErrorModel.class);
    } catch (Exception ex) {
      throw CommonUtil.logException(ex);
    }
  }
}
