/**
 * @author Vidhya Raghavan
 * @since Sep 2023
 * @description model for SOP DebtSummary.returns all the sop debt related values and total
 * @group Models
 */

public class SOPDebtSummary {
  public List<SOPDebt> liabilities;
  public List<SOPDebtSources> sources;
  public List<SOPLiabilitySources> partyLiabilities;
  /**
   * @description returns homeLoanLiabilityExists value to show Home Loan title on Debt flexcard
   */
  public boolean homeLoanLiabilityExists {
    get {
      for (SOPDebt debt : liabilities) {
        if (debt?.type == ResidentialLoanApplicationModel.HOME_LOAN) {
          return true;
        }
      }
      return false;
    }
  }
  /**
   * @description returns otherLoanLiabilityExists value to show Other Loan title on Debts flexcard
   */
  public boolean otherLoanLiabilityExists {
    get {
      for (SOPDebt debt : liabilities) {
        if (
          debt?.type == ResidentialLoanApplicationModel.OTHER_LOAN_LIABILITY
        ) {
          return true;
        }
      }
      return false;
    }
  }

  /**
   * @description returns leaseHirePurchaseExists value to show Lease Hire Purchase liability title on Debts flexcard
   */
  public boolean leaseHirePurchaseExists {
    get {
      for (SOPDebt debt : liabilities) {
        if (debt?.type == ResidentialLoanApplicationModel.LEASE_HIRE) {
          return true;
        }
      }
      return false;
    }
  }

  /**
   * @description returns bnplLiabilityExists value to show BNPL title on Debt flexcard
   */
  public boolean bnplLiabilityExists {
    get {
      for (SOPDebt debt : liabilities) {
        if (
          debt?.type == ResidentialLoanApplicationModel.BPL_FACILITY ||
          debt?.type == ResidentialLoanApplicationModel.BPL_LIABILITY
        ) {
          return true;
        }
      }
      return false;
    }
  }
  /**
   * @description returns vehicleLoanLiabilityExists value to show Vehicle Loan title on Debt flexcard
   */
  public boolean vehicleLoanLiabilityExists {
    get {
      for (SOPDebt debt : liabilities) {
        if (debt?.type == ResidentialLoanApplicationModel.VEHICLE_LOAN) {
          return true;
        }
      }
      return false;
    }
  }

  /**
   * @description returns studentLoanExists value to show Student Loan title on Debt flexcard
   */
  public boolean studentLoanExists {
    get {
      for (SOPDebt debt : liabilities) {
        if (debt?.type == ResidentialLoanApplicationModel.STUDENT_LOAN) {
          return true;
        }
      }
      return false;
    }
  }

  /**
   * @description returns overdraftLiabilityExists value to show Overdraft Loan title on Debt flexcard
   */
  public boolean overdraftLiabilityExists {
    get {
      for (SOPDebt debt : liabilities) {
        if (debt?.type == ResidentialLoanApplicationModel.OVERDRAFT) {
          return true;
        }
      }
      return false;
    }
  }

  /**
   * @description returns creditCardExists value to show Credit Loan title on Debt flexcard
   */
  public boolean creditcardLiabilityExists {
    get {
      for (SOPDebt debt : liabilities) {
        if (
          debt?.type == ResidentialLoanApplicationModel.CREDIT_CARD_LIABILITY
        ) {
          return true;
        }
      }
      return false;
    }
  }

  /**
   * @description returns lineOfCreditExists value to show Line of credit title on Debt flexcard
   */
  public boolean lineOfCreditExists {
    get {
      for (SOPDebt debt : liabilities) {
        if (
          debt?.type == ResidentialLoanApplicationModel.LINE_OF_CREDIT_LIABILITY
        ) {
          return true;
        }
      }
      return false;
    }
  }

  /**
   * @description returns marginLoanExists value to show Margin Loan title on Debt flexcard
   */
  public boolean marginLoanExists {
    get {
      for (SOPDebt debt : liabilities) {
        if (debt?.type == ResidentialLoanApplicationModel.MARGIN_LOAN) {
          return true;
        }
      }
      return false;
    }
  }

  /**
   * @description returns otherLiabilityExists value to show Other Liability title on Debt flexcard
   */
  public boolean otherLiabilityExists {
    get {
      for (SOPDebt debt : liabilities) {
        if (debt?.type == ResidentialLoanApplicationModel.OTHER_LIABILITY) {
          return true;
        }
      }
      return false;
    }
  }

  /**
   * @description returns personalLoanLiabilityExists value to show Personal Loan title on Debt flexcard
   */
  public boolean personalLoanLiabilityExists {
    get {
      for (SOPDebt debt : liabilities) {
        if (debt?.type == ResidentialLoanApplicationModel.PERSONAL_LOAN) {
          return true;
        }
      }
      return false;
    }
  }
  public SOPMoney liabilitiesTotalAmount;
}
