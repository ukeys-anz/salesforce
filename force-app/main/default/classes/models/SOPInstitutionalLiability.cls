/**
 * @author Lance Shi
 * @since Jun 2023
 * @description model for SOP institutional liability
 * @group Models
 */
public class SOPInstitutionalLiability {
  public SOPMoney limitAmount;
  public Integer interestRate;
  public SOPMoney minimumPayment;
  public SOPMoney repaymentAmount;
  public String repaymentFrequency;
  public Integer principalInterestRemainingTerm;
  public Integer interestOnlyRemainingTerm;
  public Boolean liabilityDuePaidInFull;
  public SOPMoney redrawAmount;
  public String paymentMethod;
  public String financialInstitution;
  /**
   * @description return a readable frequency
   */
  public String readableFrequency {
    get {
      String[] words = repaymentFrequency.split('_');
      String result = '';
      words.remove(0);

      for (String word : words) {
        result +=
          word.substring(0, 1).toUpperCase() +
          word.substring(1).toLowerCase() +
          ' ';
      }
      return result.trim();
    }
  }

  /**
   * @description return a readable interest rate value
   */
  public string readableInterestRate {
    get {
      try {
        Decimal givenValue = Decimal.valueOf(interestRate);
        String result = (givenValue / 100).setScale(2) + '%';
        return result;
      } catch (Exception e) {
        return 'Not Provided';
      }
    }
  }

  /**
   * @description return a readable P&I Terms in years and months
   */
  public string readablePIRemainingTerm {
    get {
      if (
        principalInterestRemainingTerm == null ||
        principalInterestRemainingTerm == 0
      ) {
        return '0';
      }
      Integer years = principalInterestRemainingTerm / 12;
      Integer months = Math.mod(principalInterestRemainingTerm, 12);
      String result = '';
      if (years > 0) {
        result += years + ' year';
        if (years > 1) {
          result += 's';
        }
        if (months > 0) {
          result += ', ';
        }
      }
      if (months > 0) {
        result += months + ' month';
        if (months > 1) {
          result += 's';
        }
      }
      return result;
    }
  }
}
