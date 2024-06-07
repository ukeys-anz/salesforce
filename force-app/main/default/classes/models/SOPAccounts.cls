/**
 * @author Vidhya Raghavan
 * @since Jun 2023
 * @description model for SOP Accounts
 * @group Models
 */
public class SOPAccounts {
  private static final Map<String, String> ACCOUNT_STATUSES = new Map<String, String>{
    'ACCOUNT_STATE_UNSPECIFIED' => 'Unspecified', // there is no info about what status the account is in
    'ACCOUNT_STATE_OPEN' => 'Open', // the account is open
    'ACCOUNT_STATE_ACTIVE' => 'Active', // the account is active
    'ACCOUNT_STATE_SUSPENDED' => 'Suspended', // the account is suspended
    'ACCOUNT_STATE_DORMANT' => 'Dormant', // the account is dormant
    'ACCOUNT_STATE_CLOSED' => 'Closed' // the account is closed
  };

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
  /**
   * @description returns a readable status for the account
   */
  public String readableStatus {
    get {
      return ACCOUNT_STATUSES.get(status);
    }
  }
  public string financialInstitution;
}
