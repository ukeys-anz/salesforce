/**
 * @author @fangl6(Lei Fang)
 * @since April 2023
 * @description model for Statement of position
 * @group Models
 */
@SuppressWarnings(
  'PMD.CyclomaticComplexity, PMD.StdCyclomaticComplexity, PMD.ExcessivePublicCount'
)
public with sharing class ResidentialLoanApplicationModel extends CalloutModel {
  @AuraEnabled
  public List<SOPAsset> assets;
  /**
   * @description SOPAsset returns all the sop asset related values
   */
  public class SOPAsset {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String type;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public SOPEstimatedValue estimatedValue;
    @AuraEnabled
    public SOPAccounts account;
    @AuraEnabled
    public List<SOPOwnership> ownership;
    @AuraEnabled
    public String propertyId;
    @AuraEnabled
    public String createTime;
    @AuraEnabled
    public Datetime updateTime;
    @AuraEnabled
    public String updatedBy;
  }

  /**
   * @description returns the estimated value with with currency code units and nanos
   */
  public class SOPEstimatedValue {
    @AuraEnabled
    public String currencyCode;
    @AuraEnabled
    public String units;
    @AuraEnabled
    public Integer nanos;
    /**
     * @description calculated value
     */
    @AuraEnabled
    public Decimal value {
      get {
        //Need to check if units and nanos exist as they aren't always returned
        Decimal unitValue = String.isNotBlank(this.units)
          ? decimal.valueOf(this.units)
          : 0;
        Decimal nanoValue = this.nanos != null ? this.nanos : 0;
        return unitValue + (nanoValue / 1000000000);
      }
    }
  }

  /**
   * @description returns the bank account parameters
   */
  public class SOPAccounts {
    @AuraEnabled
    public string id;
    @AuraEnabled
    public string bsb;
    @AuraEnabled
    public string accountNumber;
    @AuraEnabled
    /**
     * @description returns the product name from an account number
     */
    public string productName {
      get {
        FinServ__FinancialAccount__c account = [
          SELECT Name
          FROM FinServ__FinancialAccount__c
          WHERE FinServ__FinancialAccountNumber__c = :this.accountNumber
          LIMIT 1
        ];
        return account.Name;
      }
    }
    @AuraEnabled
    public string accountName;
    @AuraEnabled
    public string status;
    @AuraEnabled
    public string financialInstitution;
  }

  /**
   * @description returns the ownership values
   */
  public class SOPOwnership {
    @AuraEnabled
    public String partyId;
    @AuraEnabled
    public SOPProportion proportion;
    /**
     * @description returns the owner name from a given partyid
     */
    @AuraEnabled
    public string ownerName {
      get {
        List<Account> acc = [
          SELECT FirstName
          FROM Account
          WHERE ocv_id__c = :this.partyId
          LIMIT 1
        ];
        if (acc != null && acc.size() == 1) {
          return acc[0].FirstName;
        } else {
          return null;
        }
      }
    }
  }

  /**
   * @description returns the SOP proportion value
   */
  public class SOPProportion {
    @AuraEnabled
    public String value;
  }

  /**
   * @param json input string to deserialize
   * @return `List of SOP Assets`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static ResidentialLoanApplicationModel parse(String json) {
    return (ResidentialLoanApplicationModel) deserialize(
      json,
      ResidentialLoanApplicationModel.class
    );
  }
}
