/**
 * @author Mani
 * @since June 2023
 * @description View Serviceability Model to get response from SOP, gearbox, LoadApp thru mule
 * @design https://confluence.service.anz/display/ABT/BOH+104+-+View+UMI
 * @group Repository
 */
public with sharing class ViewServiceabilityModel extends CalloutModel {
  public String creditEnquiryId;
  public DateTime createTime;
  public String loanAppId;
  public FabricType.FabricMoney totalUMI;
  public List<Assessment> assessments;
  /**
   * @description assessment node from view UMI api
   */
  public class Assessment {
    public String sopId;
    public AssessmentCategory incomeAssessment;
    public AssessmentCategory hemExpenses;
    public AssessmentCategory nonHemExpenses;
    public AssessmentCategory liabilities;
  }
  /**
   * @description Represents assessment category node from view UMI api
   */
  public class AssessmentCategory {
    public List<AssessmentSummary> summary;
    public FabricType.FabricMoney totalApplicationAmount;
    public FabricType.FabricMoney totalAssessedAmount;
  }
  /**
   * @description Represents assessment summary node from view UMI api
   */
  public class AssessmentSummary {
    public List<PartyInfo> parties;
    public String ocvId;
    public String type;
    public String frequency;
    public FabricType.FabricMoney applicationAmount;
    public FabricType.FabricMoney assessedAmount;
  }

  /**
   * @description Represents patry node from view UMI api
   */
  public class PartyInfo {
    public String ocvId;
  }
  /**
   * @description Represents Response body for view UMI api
   * @param json json response from view umi api.
   * @return `ViewServiceabilityModel` api response is serialised into ViewServiceabilityModel
   */
  public static ViewServiceabilityModel parse(String json) {
    return (ViewServiceabilityModel) deserialize(
      json,
      ViewServiceabilityModel.class
    );
  }
}
