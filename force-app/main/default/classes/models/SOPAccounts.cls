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
  public SOPProductDetails productDetails;
  /**
   * @description returns the last 4 digits of account number to display cardNumber UI in flexcard
   */
  public string cardNumber {
    get {
      return 'xxxx xxxx xxxx ' + accountNumber?.right(4);
    }
  }
  /**
   * @description child class to get the marketing name
   */
  public class SOPProductDetails {
    public string marketingName;
  }
  /**
   * @description returns the product marketing name from an account number
   */
  public string productName {
    get {
      if (productDetails == null) {
        return '';
      }
      return productDetails.marketingName;
    }
  }
  public string accountName;
  public string status;
  public string financialInstitution;
}
