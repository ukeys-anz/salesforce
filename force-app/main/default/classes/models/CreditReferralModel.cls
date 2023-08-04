/**
 * Suppressing PMD naming convention warnings as some fields return in snake case formatting from the API.
 */
@SuppressWarnings('PMD.FieldNamingConventions, PMD.VariableNamingConventions')
/**
 * @author cruzb
 * @since May 2023
 * @description Model for Credit Referrals
 */
public with sharing class CreditReferralModel extends CalloutModel {
  public List<Assessment> assessments;

  /**
   * @description Assessment node
   */
  public class Assessment {
    public String id;
    public String creditEnquiryId;
    public String collateralAssessmentId;
    public String type;
    /**
     * @description assessedTime format to 'dd/MM/yyyy HH:mm' in local time for interface
     */
    public String assessedTime {
      get {
        if (String.isEmpty(assessedTime)) {
          return assessedTime;
        }
        return DateTimeUtils.getLocalTime(
          (Datetime) JSON.deserialize(
            JSON.serialize(assessedTime),
            Datetime.class
          ),
          TransactionHistoryModel.TIMEZONE,
          'dd/MM/yyyy HH:mm a'
        );
      }
    }
    /**
     * @description outcome transform to retain actual status
     */
    public String outcome {
      get {
        if (String.isEmpty(outcome)) {
          return outcome;
        }
        String[] arrOutcome = outcome.split('_');
        return arrOutcome[arrOutcome.size() - 1].toLowerCase().capitalize();
      }
    }
    public String creditEquiryServiceabilityId;
    public List<Reason> reasons;
    public Lvr lvr;
    public Decimal debtToIncomeRatio;
    public String createdBy;
    public String createdTime;
    public String expiryTime;
  }

  /**
   * @description Reason node
   */
  public class Reason {
    public String reasonCode;
    public String reasonDescription;
    public String reasonOutcome;
    public String applicantId;
    public String guidanceCode;
    public String assessmentCategory;
    public String authorityLevel;
  }

  /**
   * @description Lvr node
   */
  public class Lvr {
    public Decimal maxAllowableLvr;
    public Decimal actualLvr;
  }

  /**
   * @param json input string to deserialize
   * @return `CreditReferralModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static CreditReferralModel parse(String json) {
    return (CreditReferralModel) deserialize(json, CreditReferralModel.class);
  }
}
