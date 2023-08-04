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
  public SOPAssetSummary assetsSummary;
  public SOPDebtSummary liabilitiesSummary;
  public SOPExpenseSummary monthlyExpensesSummary;
  public SOPIncomeSummary incomesSummary;
  public static Map<String, String> employeeIdToPartyIdMap;
  public SOPModel sop;
  public static final String JOINT_ACCOUNT = 'Joint';
  public static Map<String, Account> partyIdToAccountMap;
  public static Map<String, FinServ__FinancialAccount__c> accNumberToFinAccountMap;
  public List<SOPExpenseNode> expenseNodes;
  public Map<String, SOPExpense> expenseMap;
  public static final String OVERTIME_INCOME = 'INCOME_TYPE_OVERTIME';
  public static final String BASE_INCOME = 'INCOME_TYPE_BASE_SALARY';
  public static final String COMMISSION_INCOME = 'INCOME_TYPE_COMMISSION';
  public static final String BONUS_INCOME = 'INCOME_TYPE_BONUS';
  public static final String VERIFICATION_METHOD = 'VERIFICATION_METHOD_UNSPECIFIED';
  public static final String UNSPECIFIED = 'UNSPECIFIED';
  public static final String NOT_SPECIFIED = 'Not Specified';
  public static final String ASSET_TYPE_SHARES = 'ASSET_TYPE_SHARES';
  public static final String ASSET_TYPE_HOME_CONTENTS = 'ASSET_TYPE_HOME_CONTENTS';
  public static final String ASSET_TYPE_OTHER = 'ASSET_TYPE_OTHER';
  public static final String ASSET_TYPE_VEHICLE = 'ASSET_TYPE_VEHICLE';
  public static final String ASSET_TYPE_SUPER = 'ASSET_TYPE_SUPER';
  public static final String ASSET_TYPE_BANK_ACCOUNT = 'ASSET_TYPE_BANK_ACCOUNT';
  public static final String SAVINGS_ANZ = 'ANZ';
  public static final String SAVINGS_ANZ_PLUS = 'ANZ Plus';
  public static final String ASSET_TYPE_CASH = 'ASSET_TYPE_CASH';
  public static final String ASSET_TYPE_PROPERTY = 'ASSET_TYPE_PROPERTY';
  public static final String ASSET_TYPE_VERIFICATION = 'VERIFICATION_METHOD_UNSPECIFIED';
  public static final String INCOME_GROSS = 'INCOME_AMOUNT_TYPE_GROSS';
  public static final String INCOME_NET = 'INCOME_AMOUNT_TYPE_NET';
  public static final String Y = 'Yes';
  public static final String N = 'No';
  public static final String BEFORE_TAX = 'Before Tax';
  public static final String AFTER_TAX = 'After Tax';

  /**
   * @description return the debt size attribute to display no debt message on flexcard.
   */
  public Integer debtSize {
    get {
      return liabilitiesSummary.liabilities.size();
    }
  }

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
    if (assetsSummary != null) {
      for (SOPAsset asset : assetsSummary.assets) {
        if (asset.ownership != null) {
          for (SOPOwnership owner : asset.ownership) {
            ocvIdSet.add(partyToOcvMap.get(owner.partyId));
          }
        }
      }
    }
    for (SOPDebt debt : liabilitiesSummary.liabilities) {
      if (debt.ownership != null) {
        for (SOPOwnership owner : debt.ownership) {
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
    if (assetsSummary != null) {
      for (SOPAsset asset : assetsSummary.assets) {
        if (asset.account != null) {
          accNumberSet.add(asset.account.accountNumber);
        }
      }
    }
    for (SOPDebt debt : liabilitiesSummary.liabilities) {
      if (debt.account != null) {
        accNumberSet.add(debt.account.accountNumber);
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
   * @description organize expense nodes into a tree structure
   */
  public void organizeExpenseNodes() {
    expenseNodes = new List<SOPExpenseNode>();
    for (SOPExpense expense : monthlyExpensesSummary.monthlyExpenses) {
      if (expense.expenseParent == null) {
        expense.layer = 1;
        expenseNodes.add(new SOPExpenseNode(expense));
      }
    }
    List<SOPExpenseNode> l1Nodes = new List<SOPExpenseNode>();
    for (SOPExpense expense : monthlyExpensesSummary.monthlyExpenses) {
      if (expense.layer == null) {
        for (SOPExpenseNode node : expenseNodes) {
          if (node.expense.categoryId == expense.expenseParent) {
            expense.layer = 2;
            SOPExpenseNode newNode = new SOPExpenseNode(expense);
            node.childExpenses.add(newNode);
            l1Nodes.add(newNode);
          }
        }
      }
    }
    for (SOPExpense expense : monthlyExpensesSummary.monthlyExpenses) {
      if (expense.layer == null) {
        for (SOPExpenseNode node : l1Nodes) {
          if (node.expense.categoryId == expense.expenseParent) {
            expense.layer = 3;
            SOPExpenseNode newNode = new SOPExpenseNode(expense);
            node.childExpenses.add(newNode);
          }
        }
      }
    }
    expenseMap = new Map<String, SOPExpense>();
    for (SOPExpense expense : monthlyExpensesSummary.monthlyExpenses) {
      expenseMap.put(expense.categoryName.replaceAll('&', 'and'), expense);
    }
  }

  /**
   * @description SOPDebtSummary returns all the sop debt related values and total
   */
  public class SOPDebtSummary {
    public List<SOPDebt> liabilities;
    public SOPMoney liabilitiesTotalAmount;
  }

  /**
   * @description SOPExpenseSummary returns all the sop expense related values and total
   */
  public class SOPExpenseSummary {
    public List<SOPExpense> monthlyExpenses;
    public SOPMoney expensesTotalAmount;
  }

  /**
   * @description SOPASummary returns all the sop asset related values and total assets and savings
   */
  public class SOPAssetSummary {
    /**
     * @description returns cashSavingsExists value to show Cash tile title on Savings flexcard
     */
    public boolean cashSavingsExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (asset?.type == ASSET_TYPE_CASH) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns propertyAssetsExists value to show Property tile title on Assets flexcard
     */
    public boolean propertyAssetsExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (asset?.type == ASSET_TYPE_PROPERTY) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns savingsANZPlusExists value to show ANZ Plus tile title on Savings flexcard
     */
    public boolean savingsANZPlusExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (
            asset?.type == ASSET_TYPE_BANK_ACCOUNT &&
            asset?.account.financialInstitution == SAVINGS_ANZ_PLUS
          ) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns savingsANZExists value to show ANZ tile title on Savings flexcard
     */
    public boolean savingsANZExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (
            asset?.type == ASSET_TYPE_BANK_ACCOUNT &&
            asset.account.financialInstitution == SAVINGS_ANZ
          ) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns otherInstExists value to show Other Institution tile title on Savings flexcard
     */
    public boolean otherInstExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (
            asset?.type == ASSET_TYPE_BANK_ACCOUNT &&
            asset?.account.financialInstitution != SAVINGS_ANZ &&
            asset?.account.financialInstitution != SAVINGS_ANZ_PLUS
          ) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns superAssetsExists value to show Super tile title on Assets flexcard
     */
    public boolean superAssetsExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (asset?.type == ASSET_TYPE_SUPER) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns vehicleAssetsExists value to show Vehicle tile title on Assets flexcard
     */
    public boolean vehicleAssetsExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (asset?.type == ASSET_TYPE_VEHICLE) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns otherAssetsExists value to show Other tile title on Assets flexcard
     */
    public boolean otherAssetsExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (asset?.type == ASSET_TYPE_OTHER) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns homeContentsAssetsExists value to show Home Content tile title on Assets flexcard
     */
    public boolean homeContentsAssetsExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (asset?.type == ASSET_TYPE_HOME_CONTENTS) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns sharesAssetsExists value to show Investment tile title on Assets flexcard
     */
    public boolean sharesAssetsExists {
      get {
        boolean returnValue = false;
        for (SOPAsset asset : assets) {
          if (asset?.type == ASSET_TYPE_SHARES) {
            returnValue = true;
          }
        }
        return returnValue;
      }
    }
    /**
     * @description returns savingsExists value to show the message if none of savings type exists.
     */
    public boolean savingsExists {
      get {
        boolean returnValue = false;
        if (
          this.cashSavingsExists ||
          this.savingsANZPlusExists ||
          this.savingsANZExists ||
          this.otherInstExists
        ) {
          returnValue = true;
        }
        return returnValue;
      }
    }
    public List<SOPAsset> assets;
    public SOPMoney assetsTotalAmount;
    public SOPMoney savingsTotalAmount;
  }

  /**
   * @description SOPIncomeSummary displays all the income related values
   */
  public class SOPIncomeSummary {
    public List<SOPIncome> incomes;
    public SOPMoney incomesTotalAmount;
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
   * @description Income class for the income node
   */
  public class SOPIncome implements Comparable {
    public String id;
    public String sopId;
    public List<SOPIncomeDetail> details;
    public SOPEmployment employment;
    public string employmentId;
    public string updateTime;
    public SOPverification verification;
    /**
     * @description ownerName for the income card
     */
    public string ownerName {
      get {
        if (employment?.partyId != null) {
          Account act = ResidentialLoanApplicationModel.partyIdToAccountMap.get(
            employment.partyId
          );
          if (act != null) {
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
    public String employer {
      get {
        if (employment?.businessName != null) {
          return employment.businessName;
        } else {
          return null;
        }
      }
    }

    /**
     * @description startdate for the income card
     */
    public String startDate {
      get {
        if (employment?.startDate != null) {
          return employment.startDate.year +
            '-' +
            employment.startDate.month +
            '-' +
            employment.startDate.day;
        } else {
          return null;
        }
      }
    }

    /**
     * @description employment Type for the income card
     */
    public String employmentType {
      get {
        if (employment?.basis != null) {
          String[] words = employment.basis.split('_');
          String result = '';
          words.remove(0);
          words.remove(0);

          for (Integer i = 0; i < words.size(); i++) {
            if (i == 0 && words.size() > 1) {
              result +=
                words[i].substring(0, 1).toUpperCase() +
                words[i].substring(1).toLowerCase() +
                '-';
            } else if (words[i] == UNSPECIFIED) {
              result = NOT_SPECIFIED;
            } else {
              result +=
                words[i].substring(0, 1).toUpperCase() +
                words[i].substring(1).toLowerCase() +
                ' ';
            }
          }
          return result.trim();
        } else {
          return null;
        }
      }
    }

    /**
     * @description baseIncome for the income card
     */
    public ResidentialLoanApplicationModel.SOPIncomeDetail baseIncome {
      get {
        for (SOPIncomeDetail detail : details) {
          if (detail?.type == BASE_INCOME) {
            return detail;
          }
        }
        return null;
      }
    }

    /**
     * @description overTimeIncome for the income card
     */
    public ResidentialLoanApplicationModel.SOPIncomeDetail overTimeIncome {
      get {
        for (SOPIncomeDetail detail : details) {
          if (detail?.type == OVERTIME_INCOME) {
            return detail;
          }
        }
        return null;
      }
    }

    /**
     * @description commissionIncome for the income card
     */
    public ResidentialLoanApplicationModel.SOPIncomeDetail commissionIncome {
      get {
        for (SOPIncomeDetail detail : details) {
          if (detail?.type == COMMISSION_INCOME) {
            return detail;
          }
        }
        return null;
      }
    }

    /**
     * @description bonusIncome for the income card
     */
    public ResidentialLoanApplicationModel.SOPIncomeDetail bonusIncome {
      get {
        for (SOPIncomeDetail detail : details) {
          if (detail?.type == BONUS_INCOME) {
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
        this.baseIncome != null &&
        compareToIncome.baseIncome != null &&
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
    public String incomeVerified {
      get {
        if (
          this.verification != null &&
          this.verification.method == ASSET_TYPE_VERIFICATION
        ) {
          return 'Y';
        } else {
          return 'N';
        }
      }
    }
  }
  /**
   * @description Income detail class
   */

  public class SOPIncomeDetail {
    public String id;
    public String type;
    /**
     * @description income Type
     */
    public String incomeType {
      get {
        String categoryOfIncome;
        if (this.amountType != null && this.amountType == INCOME_GROSS) {
          categoryOfIncome = BEFORE_TAX;
        } else if (this.amountType == INCOME_NET) {
          categoryOfIncome = AFTER_TAX;
        }
        return categoryOfIncome;
      }
    }

    /**
     * @description frequency
     */
    public String frequency {
      get {
        if (this.frequency != null) {
          String result = '';
          String[] words = this.frequency.split('_');
          words.remove(0);
          words.remove(0);

          for (String word : words) {
            if (word == UNSPECIFIED) {
              result = NOT_SPECIFIED;
            } else {
              result =
                word.substring(0, 1).toUpperCase() +
                word.substring(1).toLowerCase() +
                ' ';
            }
          }
          return result.trim();
        } else {
          return null;
        }
      }
    }
    public SOPMoney amount;
    public String amountType;
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
    model.organizeExpenseNodes();
    if (model.assetsSummary != null) {
      model.assetsSummary.assets.sort();
    }
    if (model.incomesSummary.incomes != null) {
      model.incomesSummary.incomes.sort();
    }
    return model;
  }
}
