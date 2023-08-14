/**
 * @author Vidhya Raghavan
 * @since Jun 2023
 * @description model for SOP Accounts
 * @group Models
 */
public class SOPAccounts {
  public string id;
  public string bsb;
  public string accountNumber;
  /**
   * @description returns the last 4 digits of account number to display cardNumber UI in flexcard
   */
  public string cardNumber {
    get {
      return accountNumber?.right(4);
    }
  }
  /**
   * @description returns the product name from an account number
   */
  public string productName {
    get {
      FinServ__FinancialAccount__c finAcc = ResidentialLoanApplicationModel.accNumberToFinAccountMap.get(
        this.accountNumber
      );
      return finAcc != null ? finAcc.Product_Name__c : '';
    }
  }
  public string accountName;
  public string status;
  public string financialInstitution;
}
