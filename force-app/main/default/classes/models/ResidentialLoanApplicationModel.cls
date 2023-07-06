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
  public List<SOPAssetSummary> assetsSummaries;
  @AuraEnabled
  public List<SOPDebtSummary> liabilitiesSummaries;
  @AuraEnabled
  public List<SOPIncome> incomes;
  @AuraEnabled
  public List<SOPEmployment> employments;
  public static Map<String, SOPEmployment> employeeIdToEmployeeMap;
  public static Map<String, String> employeeIdToPartyIdMap;
  public SOPModel sop;
  public static final String JOINT_ACCOUNT = 'Joint';
  public static Map<String, Account> partyIdToAccountMap;
  public static Map<String, FinServ__FinancialAccount__c> accNumberToFinAccountMap;

  /**
   * @description return the asset size attribute to display no asset message on flexcard
   */
  @AuraEnabled
  public Integer assetSize {
    get {
      if (assetsSummaries.isEmpty() || assetsSummaries[0].assets.isEmpty()) {
        return 0;
      } else {
        return assetsSummaries[0].assets.size();
      }
    }
  }
  /**
   * @description return the income size attribute to display no income message on flexcard.
   */
  @AuraEnabled
  public Integer incomeSize {
    get {
      if (incomes.size() == 0) {
        return 0;
      } else {
        return incomes.size();
      }
    }
  }

  /**
   * @description return the debt size attribute to display no debt message on flexcard.
   */
  @AuraEnabled
  public Integer debtSize {
    get {
      if (
        liabilitiesSummaries.isEmpty() ||
        liabilitiesSummaries[0].liabilities.isEmpty()
      ) {
        return 0;
      } else {
        return liabilitiesSummaries[0].liabilities.size();
      }
    }
  }

  /**
   * @description initialize the maps
   */
  public void initMaps() {
    initPartyIdToAccountMap();
    initAccNumberToFinAccountMap();
    initEmployeeIdToEmployeeMap();
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
    if (assetsSummaries.size() > 0) {
      for (SOPAsset asset : assetsSummaries[0].assets) {
        if (asset.ownership != null) {
          for (SOPOwnership owner : asset.ownership) {
            ocvIdSet.add(partyToOcvMap.get(owner.partyId));
          }
        }
      }
    }
    if (liabilitiesSummaries.size() > 0) {
      for (SOPDebt debt : liabilitiesSummaries[0].liabilities) {
        if (debt.ownership != null) {
          for (SOPOwnership owner : debt.ownership) {
            ocvIdSet.add(partyToOcvMap.get(owner.partyId));
          }
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
    if (assetsSummaries.size() > 0) {
      for (SOPAsset asset : assetsSummaries[0].assets) {
        if (asset.account != null) {
          accNumberSet.add(asset.account.accountNumber);
        }
      }
    }
    if (liabilitiesSummaries.size() > 0) {
      for (SOPDebt debt : liabilitiesSummaries[0].liabilities) {
        if (debt.account != null) {
          accNumberSet.add(debt.account.accountNumber);
        }
      }
    }
    List<FinServ__FinancialAccount__c> finAccList = [
      SELECT Name, FinServ__FinancialAccountNumber__c, Product_Name__c
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
   * @description get Employee details from the employment node
   */
  public void initEmployeeIdToEmployeeMap() {
    if (ResidentialLoanApplicationModel.employeeIdToEmployeeMap != null) {
      return;
    } else {
      ResidentialLoanApplicationModel.employeeIdToEmployeeMap = new Map<String, SOPEmployment>();
      if (this.employments != null) {
        for (SOPEmployment employment : this.employments) {
          ResidentialLoanApplicationModel.employeeIdToEmployeeMap.put(
            employment.Id,
            employment
          );
        }
      }
    }
  }

  /**
   * @description SOPDebtSummary returns all the sop debt related values and total
   */
  public class SOPDebtSummary {
    @AuraEnabled
    public List<SOPDebt> liabilities;
    @AuraEnabled
    public SOPMoney liabilitiesTotalAmount;
  }

  /**
   * @description SOPASummary returns all the sop asset related values and total assets and savings
   */
  public class SOPAssetSummary {
    @AuraEnabled
    public List<SOPAsset> assets;
    @AuraEnabled
    public SOPMoney assetsTotalAmount;
    @AuraEnabled
    public SOPMoney savingsTotalAmount;
  }

  /**
   * @description SOPAsset returns all the sop asset related values
   */
  public class SOPAsset implements Comparable {
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

    /**
     * @description sort the balance values to show on the Savings and Assets flexcard.
     * @param compareTo input object
     * @return `returnValue`
     */
    public Integer compareTo(Object compareTo) {
      SOPAsset compareToIncome = (SOPAsset) compareTo;
      Integer returnValue = 0;
      if (this.estimatedValue.value < compareToIncome.estimatedValue.value) {
        returnValue = 1;
      } else if (
        this.estimatedValue.value > compareToIncome.estimatedValue.value
      ) {
        returnValue = -1;
      }
      return returnValue;
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

    public List<String> sources;

    /**
     * @description return the source type
     */
    @AuraEnabled
    public String sourceType {
      get {
        if (!sources.isEmpty()) {
          if (sources[0] == 'LIABILITY_SOURCE_TYPE_ANZ') {
            return 'ANZ';
          }
          if (sources[0] == 'LIABILITY_SOURCE_TYPE_BUREAU') {
            return 'Bureau';
          }
        }
        return 'Other';
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

    /**
     * @description return a readable interest rate value
     */
    @AuraEnabled
    public string readableValue {
      get {
        try {
          Decimal givenValue = Decimal.valueOf(value);
          String result = (givenValue / 100).setScale(2) + '%';
          return result;
        } catch (Exception e) {
          return 'Not Provided';
        }
      }
    }
  }

  /**
   * @description wrapper of student loan model
   */
  public class SOPStudentLoan {
    @AuraEnabled
    public Boolean hecsWithheldPayment;

    /**
     * @description return Yes or No for withheld value
     */
    @AuraEnabled
    public String outputWithheld {
      get {
        if (hecsWithheldPayment) {
          return 'Yes';
        } else {
          return 'No';
        }
      }
    }
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

    /**
     * @description calculated minus value used for debts
     */
    @AuraEnabled
    public Decimal minusValue {
      get {
        if (value > 0) {
          return -value;
        } else {
          return value;
        }
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
        return finAcc != null ? finAcc.Product_Name__c : '';
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
   * @description Income class for the income node
   */
  public class SOPIncome implements Comparable {
    @AuraEnabled
    public String id;
    /**
     * @description null check for the income child flexcard
     */
    @AuraEnabled
    public String idNullCheck {
      get {
        if (id != null) {
          return 'Y';
        } else {
          return 'N';
        }
      }
    }
    @AuraEnabled
    public String sopId;
    @AuraEnabled
    public List<SOPIncomeDetail> details;
    @AuraEnabled
    public string employmentId;
    @AuraEnabled
    public string updateTime;
    @AuraEnabled
    public SOPverification verification;
    /**
     * @description ownerName for the income card
     */
    @AuraEnabled
    public string ownerName {
      get {
        SOPEmployment employment = ResidentialLoanApplicationModel.employeeIdToEmployeeMap.get(
          this.employmentId
        );

        if (employment != null && employment.partyId != null) {
          Account act = ResidentialLoanApplicationModel.partyIdToAccountMap.get(
            employment.partyId
          );
          if (act.FirstName != null) {
            return act.FirstName;
          } else {
            return null;
          }
        } else {
          return null;
        }
      }
    }

    /**
     * @description employer name for the income card
     */
    @AuraEnabled
    public String employer {
      get {
        SOPEmployment employment = ResidentialLoanApplicationModel.employeeIdToEmployeeMap.get(
          this.employmentId
        );
        if (employment != null && employment.businessName != null) {
          return employment.businessName;
        } else {
          return null;
        }
      }
    }

    /**
     * @description employment name for the income card
     */
    @AuraEnabled
    public String employmentBasis {
      get {
        SOPEmployment employment = ResidentialLoanApplicationModel.employeeIdToEmployeeMap.get(
          this.employmentId
        );
        if (employment != null && employment.basis != null) {
          return employment.basis;
        } else {
          return null;
        }
      }
    }

    /**
     * @description startdate for the income card
     */
    @AuraEnabled
    public String startDate {
      get {
        SOPEmployment employment = ResidentialLoanApplicationModel.employeeIdToEmployeeMap.get(
          this.employmentId
        );
        if (employment != null && employment.startDate != null) {
          return employment.startDate.year +
            employment.startDate.month +
            employment.startDate.day;
        } else {
          return null;
        }
      }
    }

    /**
     * @description employment Type for the income card
     */
    @AuraEnabled
    public String employmentType {
      get {
        String[] words = employmentBasis.split('_');
        String result = '';
        words.remove(0);
        words.remove(0);

        for (Integer i = 0; i < words.size(); i++) {
          if (i == 0) {
            result +=
              words[i].substring(0, 1).toUpperCase() +
              words[i].substring(1).toLowerCase() +
              '-';
          } else {
            result +=
              words[i].substring(0, 1).toUpperCase() +
              words[i].substring(1).toLowerCase() +
              ' ';
          }
          System.debug('Result:' + result);
        }
        return result.trim();
      }
    }

    /**
     * @description baseIncome for the income card
     */
    @AuraEnabled
    public ResidentialLoanApplicationModel.SOPIncomeDetail baseIncome {
      get {
        for (SOPIncomeDetail detail : details) {
          if (detail.type == 'INCOME_TYPE_BASE_SALARY') {
            return detail;
          }
        }
        return null;
      }
    }

    /**
     * @description overTimeIncome for the income card
     */
    @AuraEnabled
    public ResidentialLoanApplicationModel.SOPIncomeDetail overTimeIncome {
      get {
        for (SOPIncomeDetail detail : details) {
          if (detail.type == 'INCOME_TYPE_OVERTIME') {
            return detail;
          }
        }
        return null;
      }
    }

    /**
     * @description commissionIncome for the income card
     */
    @AuraEnabled
    public ResidentialLoanApplicationModel.SOPIncomeDetail commissionIncome {
      get {
        for (SOPIncomeDetail detail : details) {
          if (detail.type == 'INCOME_TYPE_COMMISSION') {
            return detail;
          }
        }
        return null;
      }
    }

    /**
     * @description bonusIncome for the income card
     */
    @AuraEnabled
    public ResidentialLoanApplicationModel.SOPIncomeDetail bonusIncome {
      get {
        for (SOPIncomeDetail detail : details) {
          if (detail.type == 'INCOME_TYPE_BONUS') {
            return detail;
          }
        }
        return null;
      }
    }

    /**
     * @description compareTo attribute to compare the base income
     * @param compareTo input object
     * @return Integer result which one is greater
     */
    public Integer compareTo(Object compareTo) {
      SOPIncome compareToIncome = (SOPIncome) compareTo;
      Integer returnValue = 0;
      if (
        this.baseIncome.amount.value < compareToIncome.baseIncome.amount.value
      ) {
        returnValue = 1;
      } else if (
        this.baseIncome.amount.value > compareToIncome.baseIncome.amount.value
      ) {
        returnValue = -1;
      }
      return returnValue;
    }

    /**
     * @description income Verified for the income card
     */
    @AuraEnabled
    public String incomeVerified {
      get {
        System.debug('Verification method: ' + verification);
        if (this.verification.method == 'VERIFICATION_METHOD_UNSPECIFIED') {
          return 'Yes';
        } else {
          return 'No';
        }
      }
    }
  }
  /**
   * @description Income detail class
   */

  public class SOPIncomeDetail {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String type;
    /**
     * @description income Type
     */
    @AuraEnabled
    public String incomeType {
      get {
        String categoryOfIncome;
        if (this.amountType == 'INCOME_AMOUNT_TYPE_GROSS') {
          categoryOfIncome = 'Before Tax';
        }
        return categoryOfIncome;
      }
    }

    /**
     * @description frequency
     */
    @AuraEnabled
    public String frequency {
      get {
        String result = '';
        String[] words = this.frequency.split('_');
        words.remove(0);
        words.remove(0);

        for (String word : words) {
          result =
            word.substring(0, 1).toUpperCase() +
            word.substring(1).toLowerCase() +
            ' ';
        }
        return result.trim();
      }
    }
    @AuraEnabled
    public SOPMoney amount;
    @AuraEnabled
    public String amountType;
  }

  /**
   * @description model for Employment for income
   */
  public class SOPEmployment {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String partyId;
    @AuraEnabled
    public String businessName;
    @AuraEnabled
    public String basis;
    @AuraEnabled
    public beginDate startDate;
    @AuraEnabled
    public Datetime updateTime;
  }

  /**
   * @description start date
   */
  public class BeginDate {
    public String year;
    public String month;
    public String day;
  }
  /**
   * @description verfication
   */
  public class SOPVerification {
    public string id;
    public string incomeId;
    public string createTime;
    public string method;
    public List<string> documentIds;
    public string createdBy;
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
    if (model.assetsSummaries.size() > 0) {
      model.assetsSummaries[0].assets.sort();
    }
    model.incomes.sort();
    return model;
  }
}
