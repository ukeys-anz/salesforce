/**
 * @author Ian Huang
 * @since  06/2023
 * @group Platform
 * @description Salesforce Connect External Financial Account business model base class
 */
public abstract class FinancialAccountModelBase {
  //common financial account properties
  public String accountNumber;
  public String accountName;
  public String status;
  public Decimal accountBalance;
  public Decimal accountLimit;
  public String productCode;
}
