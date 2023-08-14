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
  /**
   * @description return the transformed value of minimumPayment based on its value from payload
   */
  public String actualMinimumPayment {
    get {
      if (minimumPayment != null && minimumPayment.units != null) {
        return String.valueOf(minimumPayment.minusValue);
      } else {
        return ResidentialLoanApplicationModel.CREDIT_CARD_UI_MESSAGE;
      }
    }
  }
  public SOPMoney repaymentAmount;
  public String repaymentFrequency;
  public Integer principalInterestRemainingTerm;
  public Integer interestOnlyRemainingTerm;
  public Boolean liabilityDuePaidInFull;
  /**
   * @description return the transformed value of liabilityDuePaidInFull for flexcard UI
   */
  public String liabilityDueValue {
    get {
      if (liabilityDuePaidInFull == false) {
        return ResidentialLoanApplicationModel.N;
      } else {
        return ResidentialLoanApplicationModel.Y;
      }
    }
  }
  public SOPMoney redrawAmount;
  public String paymentMethod;
  public String financialInstitution;
  public Integer verifiedPrincipalInterestRemainingTerm;
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
  public String readablePIRemainingTerm {
    get {
      return fetchReadableTerm(principalInterestRemainingTerm);
    }
  }

  /**
   * @description return a readable verified P&I Terms in years and months
   */
  public String readableVerifiedPIRemainingTerm {
    get {
      return fetchReadableTerm(verifiedPrincipalInterestRemainingTerm);
    }
  }

  /**
   * @description transform total number of months into a string of years and months
   * @param totalMonths number of months from the payload
   * @return String formatted years and months to display in the card
   */
  private String fetchReadableTerm(Integer totalMonths) {
    if (totalMonths == null || totalMonths == 0) {
      return '0';
    }
    Integer years = totalMonths / 12;
    Integer months = Math.mod(totalMonths, 12);
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
