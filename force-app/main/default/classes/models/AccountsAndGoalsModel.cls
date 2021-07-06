/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description model for accounts and goals API, extending the base
 * @group Models
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class AccountsAndGoalsModel extends CalloutModel {
  @AuraEnabled
  public List<FinancialAccount> accountList;

  /**
   * @description a customer financial account
   */
  public class FinancialAccount {
    @AuraEnabled
    public String accountNumber;
    @AuraEnabled
    public String bsb;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public Balance balance;
    @AuraEnabled
    public Balance currentBalance;
    @AuraEnabled
    public String balanceValidAsOf;
    @AuraEnabled
    public String openDate;
    @AuraEnabled
    public String openDateTime;
    @AuraEnabled
    public String accountType;
    @AuraEnabled
    public Goal goal;
    /**
     * @description validates the response for expected values by the UI
     */
    @AuraEnabled
    public Boolean isValid {
      get {
        return (String.isNotBlank(this.accountNumber) &&
          (this.balance != null &&
          this.balance.value != null) &&
          (this.currentBalance != null &&
          this.currentBalance.value != null) &&
          String.isNotBlank(this.accountType))
          ? true
          : false;
      }
      set;
    }
  }

  /**
   * @description balance within a financial account
   */
  public class Balance {
    /**
     * @description reserved keyword "currency" replacement
     */
    @AuraEnabled
    public String currencyCode;
    @AuraEnabled
    public Decimal value;
  }

  /**
   * @description goal within a financial account
   */
  public class Goal {
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String iconId;
    @AuraEnabled
    public String startDate;
    @AuraEnabled
    public String startDateTime;
    @AuraEnabled
    public String themeId;
    @AuraEnabled
    public String themeColour;
    @AuraEnabled
    public String targetDate;
    @AuraEnabled
    public String targetDateTime;
    @AuraEnabled
    public Balance targetAmount;
  }

  /**
   * @param json input string to deserialize
   * @return `AccountsAndGoalsModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static AccountsAndGoalsModel parse(String json) {
    return (AccountsAndGoalsModel) deserialize(
      json,
      AccountsAndGoalsModel.class
    );
  }
}
