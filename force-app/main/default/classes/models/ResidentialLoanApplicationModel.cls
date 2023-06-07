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
  @AuraEnabled
  public List<SOPDebt> liabilities;
  public SOPModel sop;
  public static final String JOINT_ACCOUNT = 'Joint Account';
  public static Map<String, Account> partyIdToAccountMap;
  public static Map<String, FinServ__FinancialAccount__c> accNumberToFinAccountMap;

  /**
   * @description initialize the maps
   */
  public void initMaps() {
    initPartyIdToAccountMap();
    initAccNumberToFinAccountMap();
  }

  /**
   * @description initialize the account Map
   */
  public void initPartyIdToAccountMap() {
    if (ResidentialLoanApplicationModel.partyIdToAccountMap != null) {
      return;
    }
    Map<String, String> partyToOcvMap = new Map<String, String>();
    Map<String, Account> accOcvMap = new Map<String, Account>();
    for (SOPParty party : sop.parties) {
      partyToOcvMap.put(party.id, party.ocvId);
    }

    Set<String> ocvIdSet = new Set<String>();
    for (SOPAsset asset : assets) {
      if (asset.ownership != null) {
        for (SOPOwnership owner : asset.ownership) {
          ocvIdSet.add(partyToOcvMap.get(owner.partyId));
        }
      }
    }

    List<Account> accList = [
      SELECT FirstName, ocv_id__c
      FROM Account
      WHERE ocv_id__c IN :ocvIdSet
    ];
    ResidentialLoanApplicationModel.partyIdToAccountMap = new Map<String, Account>();
    for (Account acc : accList) {
      accOcvMap.put(acc.ocv_id__c, acc);
    }
    for (String partyId : partyToOcvMap.keySet()) {
      ResidentialLoanApplicationModel.partyIdToAccountMap.put(
        partyId,
        accOcvMap.get(partyToOcvMap.get(partyId))
      );
    }
  }

  /**
   * @description initialize the financial account map
   */
  public void initAccNumberToFinAccountMap() {
    if (ResidentialLoanApplicationModel.accNumberToFinAccountMap != null) {
      return;
    }
    Set<String> accNumberSet = new Set<String>();
    for (SOPAsset asset : assets) {
      if (asset.account != null) {
        accNumberSet.add(asset.account.accountNumber);
      }
    }
    List<FinServ__FinancialAccount__c> finAccList = [
      SELECT Name, FinServ__FinancialAccountNumber__c
      FROM FinServ__FinancialAccount__c
      WHERE FinServ__FinancialAccountNumber__c IN :accNumberSet
    ];
    ResidentialLoanApplicationModel.accNumberToFinAccountMap = new Map<String, FinServ__FinancialAccount__c>();
    for (FinServ__FinancialAccount__c finAcc : finAccList) {
      ResidentialLoanApplicationModel.accNumberToFinAccountMap.put(
        finAcc.FinServ__FinancialAccountNumber__c,
        finAcc
      );
    }
  }

  /**
   * @description SOPAsset returns all the sop asset related values
   */
  public class SOPAsset {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String type;
    @AuraEnabled
    public String subType;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public SOPMoney estimatedValue;
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

    /**
     * @description return the owner name of the asset
     */
    @AuraEnabled
    public string ownerName {
      get {
        if (this.ownership.size() == 1) {
          return this.ownership[0].ownerName;
        }
        return JOINT_ACCOUNT;
      }
    }
  }

  /**
   * @description SOPDebt wrapper for SOP liability information
   */
  public class SOPDebt {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String sopId;
    @AuraEnabled
    public String type;
    /**
     * @description return the debt type
     */
    @AuraEnabled
    public String debtType {
      get {
        return getReadableType(type);
      }
    }

    /**
     * @description return the readable debt type
     * @param inputStr the input type from json
     * @return String the readable debt type
     */
    public String getReadableType(String inputStr) {
      String[] words = inputStr.split('_');
      String result = '';
      words.remove(0);
      words.remove(0);

      for (String word : words) {
        if (word.equalsIgnoreCase('of')) {
          result += 'of ';
        } else {
          result +=
            word.substring(0, 1).toUpperCase() +
            word.substring(1).toLowerCase() +
            ' ';
        }
      }
      return result.trim();
    }
    @AuraEnabled
    public SOPInstitutionalLiability institutionalLiability;
    @AuraEnabled
    public SOPAccounts account;
    @AuraEnabled
    public List<SOPOwnership> ownership;
    @AuraEnabled
    public String createTime;
    @AuraEnabled
    public String updateTime;
    @AuraEnabled
    public String updatedBy;
    @AuraEnabled
    public SOPMoney originalOutstandingBalance;
    @AuraEnabled
    public SOPMoney outstandingBalance;
    @AuraEnabled
    public SOPStudentLoan studentLoan;

    /**
     * @description return the owner name of the debt
     */
    @AuraEnabled
    public string ownerName {
      get {
        if (this.ownership.size() == 1) {
          return this.ownership[0].ownerName;
        }
        return JOINT_ACCOUNT;
      }
    }
  }

  /**
   * @description model for general model configuration
   */
  public class SOPModel {
    public List<SOPParty> parties;
  }

  /**
   * @description model for party
   */
  public class SOPParty {
    public String id;
    public String ocvId;
  }

  /**
   * @description wrapper of institution liability model
   */
  public class SOPInstitutionalLiability {
    @AuraEnabled
    public SOPMoney limitAmount;
    @AuraEnabled
    public SOPInterestRate interestRate;
    @AuraEnabled
    public SOPMoney minimumPayment;
    @AuraEnabled
    public SOPMoney repaymentAmount;
    @AuraEnabled
    public String repaymentFrequency;
    @AuraEnabled
    public Integer principalInterestRemainingTerm;
    @AuraEnabled
    public Integer interestOnlyRemainingTerm;
    @AuraEnabled
    public Boolean liabilityDuePaidInFull;
    @AuraEnabled
    public SOPMoney redrawAmount;
    @AuraEnabled
    public String paymentMethod;
    @AuraEnabled
    public String financialInstitution;
    /**
     * @description return a readable frequency
     */
    @AuraEnabled
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
     * @description return a readable P&I Terms in years and months
     */
    @AuraEnabled
    public string readablePIRemainingTerm {
      get {
        if (
          principalInterestRemainingTerm == null ||
          principalInterestRemainingTerm == 0
        ) {
          return '0';
        }
        Integer years = principalInterestRemainingTerm / 12;
        Integer months = Math.mod(principalInterestRemainingTerm, 12);
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
  }

  /**
   * @description wrapper of interest rate model
   */
  public class SOPInterestRate {
    @AuraEnabled
    public string value;
  }

  /**
   * @description wrapper of student loan model
   */
  public class SOPStudentLoan {
    @AuraEnabled
    public Boolean hecsWithheldPayment;
  }

  /**
   * @description returns the estimated value with with currency code units and nanos
   */
  public class SOPMoney {
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
        FinServ__FinancialAccount__c finAcc = ResidentialLoanApplicationModel.accNumberToFinAccountMap.get(
          this.accountNumber
        );
        return finAcc != null ? finAcc.Name : '';
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
        Account acc = ResidentialLoanApplicationModel.partyIdToAccountMap.get(
          this.partyId
        );
        if (acc != null) {
          return acc.FirstName;
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
    ResidentialLoanApplicationModel model = (ResidentialLoanApplicationModel) deserialize(
      json,
      ResidentialLoanApplicationModel.class
    );
    model.initMaps();
    return model;
  }
}
