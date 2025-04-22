/**
 * @author @ramvilas
 * @since April 2025
 * @description Holds cached ResidentialLoanApplication Record Types.
 */
public class RTResidentialLoanApplication {
  static QueryRT base = QueryRT.of(ResidentialLoanApplication.SObjectType);

  public static Id anzxHomeLoan = base.getId('Loan_Application');
}
