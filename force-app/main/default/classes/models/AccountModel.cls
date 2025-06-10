/**
 * @author Kopal Goswami
 * @since May 2025
 * @description This class is used for forming customer node data in the AccountModel format
 */
public class AccountModel {
  /**
   * @description Holds ocvId of the account
   */
  public String ocvId { get; set; }
  /**
   * @description Holds sourceSystem of the account
   */
  public String sourceSystem { get; set; }
  /**
   * @description Holds sourceSystemId of the account
   */
  public String sourceSystemId { get; set; }

  /**
   * @description get an instance of AccountModel
   * @param theAccount the Account record
   */
  public AccountModel(Account theAccount) {
    this.ocvId = theAccount?.OCV_ID__c;
    this.sourceSystem = theAccount?.Source_System_Name__c;
    this.sourceSystemId = theAccount?.Source_System_ID__c;
  }
}
