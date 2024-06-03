/**
 * @author @fangl6(Lei Fang)
 * @description controller class for flexcard to show SOP
 * @since April 2023
 */

@SuppressWarnings('PMD.CyclomaticComplexity, PMD.NcssMethodCount')
global with sharing class ResidentialLoanApplicationController implements omnistudio.VlocityOpenInterface, Callable {
  private Boolean hasValidationError = false;
  private String validationError = '';
  private Set<String> errorMsg = new Set<String>();
  /**
   * @param action String value of local method to invoke
   * @param args arg map that will contain input, output and options map
   * @return `Object`
   * @description flex card invokeable method overridden by callable interface
   */
  public Object call(String action, Map<String, Object> args) {
    Map<String, Object> input = (Map<String, Object>) args.get('input');
    Map<String, Object> output = (Map<String, Object>) args.get('output');
    Map<String, Object> options = (Map<String, Object>) args.get('options');
    return invokeMethod(action, input, output, options);
  }

  /**
   * @description method to invoke controller methods
   * @param methodName
   * @param inputMap
   * @param outMap
   * @param options
   * @return Boolean for successful exection
   */
  global Boolean invokeMethod(
    String methodName,
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    // check methodName
    if (methodName == 'getListAssets') {
      return getListAssets(inputMap, outMap, options);
    } else if (methodName == 'getSOP') {
      return getSOP(inputMap, outMap, options);
    } else if (methodName == 'addIncome') {
      return addIncome(inputMap, outMap, options);
    } else if (methodName == 'deleteIncome') {
      return deleteIncome(inputMap, outMap, options);
    } else if (methodName == 'editIncome') {
      return editIncome(inputMap, outMap, options);
    } else if (methodName == 'editExpense') {
      return editExpense(inputMap, outMap, options);
    } else if (methodName == 'addDebt') {
      return addDebt(inputMap, outMap, options);
    } else if (methodName == 'editDebt') {
      return editDebt(inputMap, outMap, options);
    } else if (methodName == 'deleteDebt') {
      return deleteDebt(inputMap, outMap, options);
    } else if (methodName == 'getBelongsToOptions') {
      return getBelongsToOptions(inputMap, outMap, options);
    }
    return false;
  }

  /**
   * @description method to invoke getListAssets method
   * @param inputMap
   * @param outMap
   * @param options
   * @return Boolean for successful getListAssets exection
   */
  private Boolean getListAssets(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    try {
      ResidentialLoanApplicationAPIRepository rlaRepo = new ResidentialLoanApplicationAPIRepository();
      String loanId = (String) inputMap.get('loanId');

      List<ResidentialLoanApplication> loanRec = BOHService.getLoanRecord(
        loanId
      );
      ResidentialLoanApplicationModel sopAssets = rlaRepo.getListAssets(
        loanRec[0]?.Account?.OCV_ID__c,
        loanRec[0]?.SOP_Id__c
      );

      sopAssets.assetsSummary.assets = filterAssets(sopAssets);
      sopAssets.liabilitiesSummary.liabilities = filterLiabilities(sopAssets);

      setUamForBtns(sopAssets, loanRec);
      setRefinanceSettings(sopAssets, loanId);

      SOPModelHelper.initPartyLiability(sopAssets);
      SOPModelHelper.enrichSourcesOwnerName(sopAssets);

      outMap.put('object', JSON.deserializeUntyped(JSON.serialize(sopAssets)));
      return true;
    } catch (Exception e) {
      Map<String, Object> errorResponseMap = new Map<String, Object>{
        'hasError' => true
      };
      outMap.put('object', errorResponseMap);
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
      return false;
    }
  }

  @Testvisible
  private static Boolean allowUpsertIncomeAndDebt(String applicationStatus) {
    if (applicationStatus == 'STATE_REFERRED' && editIncomeExpenseRole()) {
      return true;
    }
    return false;
  }

  @Testvisible
  private static Boolean allowDeleteIncome(Integer incomeSize) {
    if (incomeSize > 1) {
      return true;
    }
    return false;
  }

  @TestVisible
  private static void setUamForBtns(
    ResidentialLoanApplicationModel sopAssets,
    List<ResidentialLoanApplication> loanRec
  ) {
    Boolean showAddEditBtn = allowUpsertIncomeAndDebt(loanRec[0]?.Status);
    Boolean allowDeleteIncome = allowDeleteIncome(
      sopAssets?.incomesSummary?.incomes?.size()
    );

    sopAssets.showEditExpenseBtn = showAddEditBtn;
    sopAssets.showAddIncomeBtn = showAddEditBtn;

    for (
      ResidentialLoanApplicationModel.SOPIncome income : sopAssets
        ?.incomesSummary
        ?.incomes
    ) {
      income.showEditIncomeBtn = showAddEditBtn;
      income.allowdelete = allowDeleteIncome;
    }

    for (SOPDebt debt : sopAssets?.liabilitiesSummary?.liabilities) {
      debt.showEditDebtBtn = showAddEditBtn;
      debt.showDeleteDebtBtn = false;
      if (showAddEditBtn && debt.sourceType == 'Manual') {
        debt.showDeleteDebtBtn = true;
      }
    }
  }

  @TestVisible
  private static void setRefinanceSettings(
    ResidentialLoanApplicationModel sopAssets,
    String loanId
  ) {
    List<LoanApplicationLiability> refinanceList = [
      SELECT Id, Name
      FROM LoanApplicationLiability
      WHERE LoanApplicationId = :loanId
    ];
    // a safe assumption here is a refinance homeloan always have one LoanApplicationLiability record
    for (SOPDebt debt : sopAssets?.liabilitiesSummary?.liabilities) {
      if (
        refinanceList.size() > 0 &&
        refinanceList[0].Name == debt.name &&
        debt.type == ResidentialLoanApplicationModel.HOME_LOAN
      ) {
        debt.hasRefinance = true;
      }
    }
  }

  /**
   * @description Remove Closed status values from assets
   * @param sopAssets sop data from API
   * @return  `List<SOPAsset>` filtered assets
   */
  @TestVisible
  private static List<SOPAsset> filterAssets(
    ResidentialLoanApplicationModel sopAssets
  ) {
    List<SOPAsset> filteredAssests = new List<SOPAsset>();
    for (SOPAsset asset : sopAssets.assetsSummary.assets) {
      if (asset?.account == null) {
        continue;
      }
      if (asset.account.status == 'ACCOUNT_STATE_CLOSED') {
        continue;
      }
      filteredAssests.add(asset);
    }
    return filteredAssests;
  }

  /**
   * @description Remove Closed status values from debts
   * @param sopAssets sop data from API
   * @return  `List<SOPDebt>` filtered liabilities
   */
  @TestVisible
  private static List<SOPDebt> filterLiabilities(
    ResidentialLoanApplicationModel sopAssets
  ) {
    List<SOPDebt> filteredALiabilities = new List<SOPDebt>();
    for (SOPDebt debt : sopAssets.liabilitiesSummary.liabilities) {
      if (debt?.account == null) {
        continue;
      }
      if (debt.account.status == 'ACCOUNT_STATE_CLOSED') {
        continue;
      }
      filteredALiabilities.add(debt);
    }
    return filteredALiabilities;
  }

  /**
   * @description method to invoke getSOP method
   * @param inputMap
   * @param outMap
   * @param options
   * @return Boolean for successful getSOP exection
   */
  private Boolean getSOP(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    try {
      ResidentialLoanApplicationAPIRepository rlaRepo = new ResidentialLoanApplicationAPIRepository();
      String loanId = (String) inputMap.get('loanId');
      List<ResidentialLoanApplication> loanRec = BOHService.getLoanRecord(
        loanId
      );
      SOPModel response = rlaRepo.getSOP(
        loanRec[0]?.Account?.OCV_ID__c,
        loanRec[0]?.SOP_Id__c
      );
      SOPModel.Parties[] transformedParties = new List<SOPModel.Parties>();
      SOPModelHelper.enrichOwnerName(response);

      if (response == null) {
        return false;
      }
      for (Object row : response.parties) {
        Map<String, Object> obj = (Map<String, Object>) JSON.deserializeUntyped(
          JSON.serialize(row)
        );
        obj.put('partyDependantsCount', response.dependantsCount);

        transformedParties.add(
          (SOPModel.Parties) System.JSON.deserialize(
            JSON.serialize(obj),
            SOPModel.Parties.class
          )
        );
      }
      response.parties = transformedParties;
      outMap.put('object', JSON.deserializeUntyped(JSON.serialize(response)));
      return true;
    } catch (Exception e) {
      outMap.put('toast', 'getSOPError');
      return false;
    }
  }

  private Boolean addIncome(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    outMap.clear();
    SOPCreateIncomeModel model = generateCreateIncomeModel(inputMap);

    if (this.hasValidationError) {
      outMap.put('hasValidationError', true);
      this.validationError = String.join(this.errorMsg, '<br \\\\>');
      outMap.put('validationError', this.validationError);
      return false;
    }

    try {
      ResidentialLoanApplicationAPIRepository rlaRepo = new ResidentialLoanApplicationAPIRepository();
      String loanId = (String) inputMap.get('loanId');
      String incomeVerified = Boolean.valueOf(inputMap.get('incomeVerified'))
        ? 'Yes'
        : 'No';

      List<ResidentialLoanApplication> loanRec = BOHService.getLoanRecord(
        loanId
      );
      rlaRepo.createIncome(
        loanRec[0]?.Account?.OCV_ID__c,
        incomeVerified,
        JSON.serialize(model),
        loanId
      );
      publishRLARecordMonitoringToast(loanRec[0]);

      outMap.put('hasValidationError', false);
      outMap.put('toast', 'Success');

      return true;
    } catch (Exception e) {
      if (e.getMessage().contains('verifyIncome:HTTP POST')) {
        outMap.put('toast', 'verifyError');
      } else {
        outMap.put('toast', 'Error');
      }
      return false;
    }
  }

  private Boolean editIncome(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    outMap.clear();
    SOPUpdateIncomeModel model = generateUpdateIncomeModel(inputMap);
    if (this.hasValidationError) {
      outMap.put('hasValidationError', true);
      this.validationError = String.join(this.errorMsg, '<br \\\\>');
      outMap.put('validationError', this.validationError);
      return false;
    }

    try {
      ResidentialLoanApplicationAPIRepository rlaRepo = new ResidentialLoanApplicationAPIRepository();
      String loanId = (String) inputMap.get('loanId');
      String incomeVerified = Boolean.valueOf(inputMap.get('incomeVerified'))
        ? 'Yes'
        : 'No';
      String staticIncomeVerified = (String) inputMap.get(
        'staticIncomeVerified'
      );
      Boolean incomeVerifiedChanged = staticIncomeVerified != incomeVerified;

      List<ResidentialLoanApplication> loanRec = BOHService.getLoanRecord(
        loanId
      );

      rlaRepo.updateIncome(
        loanRec[0]?.Account?.OCV_ID__c,
        incomeVerified,
        JSON.serialize(model),
        loanId,
        incomeVerifiedChanged
      );
      publishRLARecordMonitoringToast(loanRec[0]);
      outMap.put('hasValidationError', false);
      outMap.put('toast', 'Success');
      return true;
    } catch (Exception e) {
      if (e.getMessage().contains('verifyIncome:HTTP POST')) {
        outMap.put('toast', 'verifyError');
      } else {
        outMap.put('toast', 'Error');
      }
      return false;
    }
  }

  /**
   * @description method to delete income from sop
   * @param inputMap
   * @param outMap
   * @param options
   * @return Boolean for successful delete income
   */
  private Boolean deleteIncome(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    SOPDeleteModel model = new SOPDeleteModel();
    model.name = (String) inputMap.get('name');
    model.etag = (String) inputMap.get('etag');
    try {
      ResidentialLoanApplicationAPIRepository rlaRepo = new ResidentialLoanApplicationAPIRepository();
      String loanId = (String) inputMap.get('loanId');
      List<ResidentialLoanApplication> loanRec = BOHService.getLoanRecord(
        loanId
      );
      Boolean deleteIncomeResponse = rlaRepo.deleteIncome(
        loanRec[0]?.SOP_Id__c,
        loanRec[0]?.Account?.OCV_ID__c,
        JSON.serialize(model),
        loanId
      );
      publishRLARecordMonitoringToast(loanRec[0]);

      outMap.put(
        'object',
        JSON.deserializeUntyped(JSON.serialize(deleteIncomeResponse))
      );
      outMap.put('toast', 'Success');
      return true;
    } catch (Exception e) {
      outMap.put('toast', 'Error');
      return false;
    }
  }

  /**
   * @description method used by omni to get options
   * @param inputMap
   * @param outMap
   * @param options
   * @return Boolean for successful delete income
   */
  private Boolean getBelongsToOptions(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    try {
      List<Map<String, String>> uIoptions = new List<Map<String, String>>();

      Map<String, String> clearMap = new Map<String, String>();
      clearMap.put('label', '--Clear--');
      clearMap.put('value', '');
      uIoptions.add(clearMap);
      for (String s : inputMap.keySet()) {
        Map<String, String> dynamicOptions = new Map<String, String>();
        dynamicOptions.put('label', s);
        dynamicOptions.put('value', String.valueOf(inputMap.get(s)));
        uIoptions.add(dynamicOptions);
      }

      outMap.put('options', uIoptions);
    } catch (Exception e) {
      Logger.error('Failed to generate belongs to', e.getMessage());
      Logger.saveLog();
      return false;
    }
    return true;
  }

  private void setValidationError(String errorMsg) {
    this.hasValidationError = true;
    this.errorMsg.add(errorMsg);
  }

  private Boolean editExpense(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    try {
      Map<String, Object> expenseModel = (Map<String, Object>) JSON.deserializeUntyped(
        JSON.serialize(createEditExpensesModel(inputMap))
      );
      for (
        Object expense : (List<Object>) expenseModel.get('monthlyExpenses')
      ) {
        Map<String, Object> expenseItem = (Map<String, Object>) expense;
        if (expenseItem.get('justificationCode') == null) {
          expenseItem.remove('justificationCode');
        }
      }

      ResidentialLoanApplicationAPIRepository rlaRepo = new ResidentialLoanApplicationAPIRepository();
      String loanId = (String) inputMap.get('loanId');
      List<ResidentialLoanApplication> loanRec = BOHService.getLoanRecord(
        loanId
      );

      rlaRepo.editExpense(
        loanRec[0]?.Account?.OCV_ID__c,
        JSON.serialize(expenseModel),
        loanId
      );

      publishRLARecordMonitoringToast(loanRec[0]);

      outMap.put('toast', 'Success');
      return true;
    } catch (Exception e) {
      outMap.put('toast', 'Error');
      return false;
    }
  }

  /**
   * @description constructs the create income model
   * @param inputMap map parameters from flexcard
   * @return SOPCreateIncomeModel
   */
  private SOPCreateIncomeModel generateCreateIncomeModel(
    Map<String, Object> inputMap
  ) {
    SOPCreateIncomeModel model = new SOPCreateIncomeModel();
    try {
      model.parent = (String) inputMap.get('sopId');
      Integer partySize = Integer.valueOf((String) inputMap.get('partySize'));
      if (partySize > 1) {
        model.income.employment.partyId = (String) inputMap.get('partyId');
      } else {
        model.income.employment.partyId = (String) inputMap.get(
          'firstUserPartyId'
        );
      }
      model.income.employment.businessName = (String) inputMap.get('employer');
      model.income.employment.basis = (String) inputMap.get('employmentType');
      model.income.employment.type = 'EMPLOYMENT_TYPE_PAYG';

      if (!validateEmploymentDetail(model.income.employment)) {
        setValidationError(BOHConstants.MANDATORY_FIELD_MISSING);
      }
      String startDateStr = (String) inputMap.get('startDate');
      setEmploymentStartDate(model.income.employment, startDateStr);

      SOPCreateIncomeModel.SOPIncomeEditType baseSalary = new SOPCreateIncomeModel.SOPIncomeEditType();
      baseSalary.type = 'INCOME_TYPE_BASE_SALARY';
      baseSalary.frequency = (String) inputMap.get('baseSalaryFrequency');
      baseSalary.amount = stringToMoney((String) inputMap.get('salaryAmount'));
      baseSalary.amountType = (String) inputMap.get('salaryTax');
      if (!validateSOPIncomeEditType(baseSalary, false)) {
        setValidationError(BOHConstants.MANDATORY_DETAIL_MISSING);
      }
      model.income.details.add(baseSalary);

      String showOvertime = (String) inputMap.get('showOvertime');
      if (showOvertime == 'true') {
        SOPCreateIncomeModel.SOPIncomeEditType overtime = new SOPCreateIncomeModel.SOPIncomeEditType();
        overtime.type = 'INCOME_TYPE_OVERTIME';
        overtime.frequency = (String) inputMap.get('overtimeFrequency');
        overtime.amount = stringToMoney(
          (String) inputMap.get('overtimeAmount')
        );
        overtime.amountType = (String) inputMap.get('overtimeTax');
        if (!validateSOPIncomeEditType(overtime, false)) {
          setValidationError(BOHConstants.MANDATORY_DETAIL_MISSING);
        }
        model.income.details.add(overtime);
      }

      String showBonus = (String) inputMap.get('showBonus');
      if (showBonus == 'true') {
        SOPCreateIncomeModel.SOPIncomeEditType bonus = new SOPCreateIncomeModel.SOPIncomeEditType();
        bonus.type = 'INCOME_TYPE_BONUS';
        bonus.amount = stringToMoney((String) inputMap.get('bonusAmount'));
        bonus.amountType = (String) inputMap.get('bonusTax');
        String paymentsStr = (String) inputMap.get('bonusPayments');
        bonus.bonusPayments = paymentsStr.isNumeric()
          ? Integer.valueOf(paymentsStr)
          : null;
        if (
          !validateSOPIncomeEditType(bonus, true) || !paymentsStr.isNumeric()
        ) {
          setValidationError(BOHConstants.MANDATORY_DETAIL_MISSING);
        }
        model.income.details.add(bonus);
      }

      String showCommision = (String) inputMap.get('showCommision');
      if (showCommision == 'true') {
        SOPCreateIncomeModel.SOPIncomeEditType commission = new SOPCreateIncomeModel.SOPIncomeEditType();
        commission.type = 'INCOME_TYPE_COMMISSION';
        commission.frequency = (String) inputMap.get('commissionFrequency');
        commission.amount = stringToMoney(
          (String) inputMap.get('commissionAmount')
        );
        commission.amountType = (String) inputMap.get('commissionTax');
        if (!validateSOPIncomeEditType(commission, false)) {
          setValidationError(BOHConstants.MANDATORY_DETAIL_MISSING);
        }
        model.income.details.add(commission);
      }
    } catch (Exception e) {
      setValidationError('Unexpected error. Please contact admin.');
    }
    return model;
  }

  private SOPUpdateIncomeModel generateUpdateIncomeModel(
    Map<String, Object> inputMap
  ) {
    SOPUpdateIncomeModel model = new SOPUpdateIncomeModel();
    try {
      model.etag = (String) inputMap.get('etag');
      model.name = (String) inputMap.get('incomeName');
      model.uid = (String) inputMap.get('uid');
      Integer partySize = Integer.valueOf((String) inputMap.get('partySize'));
      if (partySize > 1) {
        model.employment.partyId = (String) inputMap.get('partyId');
      } else {
        model.employment.partyId = (String) inputMap.get('firstUserPartyId');
      }

      model.employment.businessName = (String) inputMap.get('employer');
      model.employment.basis = (String) inputMap.get('employmentType');
      model.employment.type = 'EMPLOYMENT_TYPE_PAYG';
      if (!validateEmploymentDetail(model.employment)) {
        setValidationError(BOHConstants.MANDATORY_FIELD_MISSING);
      }
      String startDateStr = (String) inputMap.get('startDate');
      setEmploymentStartDate(model.employment, startDateStr);

      SOPCreateIncomeModel.SOPIncomeEditType baseSalary = new SOPCreateIncomeModel.SOPIncomeEditType();
      baseSalary.type = 'INCOME_TYPE_BASE_SALARY';
      baseSalary.frequency = (String) inputMap.get('baseSalaryFrequency');
      baseSalary.amount = stringToMoney((String) inputMap.get('salaryAmount'));
      baseSalary.amountType = (String) inputMap.get('salaryTax');
      if (!validateSOPIncomeEditType(baseSalary, false)) {
        setValidationError(BOHConstants.MANDATORY_DETAIL_MISSING);
      }
      model.details.add(baseSalary);

      String showOvertime = (String) inputMap.get('showOvertime');
      if (showOvertime == 'true') {
        SOPCreateIncomeModel.SOPIncomeEditType overtime = new SOPCreateIncomeModel.SOPIncomeEditType();
        overtime.type = 'INCOME_TYPE_OVERTIME';
        overtime.frequency = (String) inputMap.get('overtimeFrequency');
        overtime.amount = stringToMoney(
          (String) inputMap.get('overtimeAmount')
        );
        overtime.amountType = (String) inputMap.get('overtimeTax');
        if (!validateSOPIncomeEditType(overtime, false)) {
          setValidationError(BOHConstants.MANDATORY_DETAIL_MISSING);
        }
        model.details.add(overtime);
      }

      String showBonus = (String) inputMap.get('showBonus');
      if (showBonus == 'true') {
        SOPCreateIncomeModel.SOPIncomeEditType bonus = new SOPCreateIncomeModel.SOPIncomeEditType();
        bonus.type = 'INCOME_TYPE_BONUS';
        bonus.amount = stringToMoney((String) inputMap.get('bonusAmount'));
        bonus.amountType = (String) inputMap.get('bonusTax');
        String paymentsStr = (String) inputMap.get('bonusPayments');
        bonus.bonusPayments = paymentsStr.isNumeric()
          ? Integer.valueOf(paymentsStr)
          : null;
        if (
          !validateSOPIncomeEditType(bonus, true) || !paymentsStr.isNumeric()
        ) {
          setValidationError(BOHConstants.MANDATORY_DETAIL_MISSING);
        }
        model.details.add(bonus);
      }

      String showCommision = (String) inputMap.get('showCommision');
      if (showCommision == 'true') {
        SOPCreateIncomeModel.SOPIncomeEditType commission = new SOPCreateIncomeModel.SOPIncomeEditType();
        commission.type = 'INCOME_TYPE_COMMISSION';
        commission.frequency = (String) inputMap.get('commissionFrequency');
        commission.amount = stringToMoney(
          (String) inputMap.get('commissionAmount')
        );
        commission.amountType = (String) inputMap.get('commissionTax');
        if (!validateSOPIncomeEditType(commission, false)) {
          setValidationError(BOHConstants.MANDATORY_DETAIL_MISSING);
        }
        model.details.add(commission);
      }
    } catch (Exception e) {
      setValidationError('Unexpected error. Please contact admin.');
    }
    return model;
  }

  private SOPMoney stringToMoney(String amountStr) {
    SOPMoney amount = new SOPMoney();
    amount.currencyCode = 'AUD';

    if (!String.isBlank(amountStr)) {
      List<String> parts = amountStr.split('\\.');

      if (parts.size() > 0) {
        amount.units = parts[0];
      }
      if (parts.size() > 1) {
        // If the fractional part exists
        String fractionalPart = parts[1];

        // Fill up to 9 decimal places (nanos)
        while (fractionalPart.length() < 9) {
          fractionalPart += '0';
        }

        // Cut down to 9 decimal places (if needed)
        fractionalPart = fractionalPart.substring(0, 9);

        // Convert to integer
        amount.nanos = Integer.valueOf(fractionalPart);
      } else {
        amount.nanos = 0;
      }
    }
    return amount;
  }

  /**
   * @description constructs the expense model
   * @param inputMap map parameters from flexcard
   * @return SOPEditExpenseModel
   */
  private SOPEditExpenseModel createEditExpensesModel(
    Map<String, Object> inputMap
  ) {
    SOPEditExpenseModel expenseModel = new SOPEditExpenseModel();
    expenseModel.parent = (String) inputMap.get('sopId');

    List<SOPEditExpenseModel.MonthlyExpense> monthlyExpenses = new List<SOPEditExpenseModel.MonthlyExpense>();

    for (
      Integer i = 1;
      i <= Integer.valueOf((String) inputMap.get('categorySize'));
      i++
    ) {
      SOPEditExpenseModel.MonthlyExpense monthlyExpense = new SOPEditExpenseModel.MonthlyExpense();
      monthlyExpense.name = (String) inputMap.get('name' + i);
      monthlyExpense.uid = (String) inputMap.get('uid' + i);
      monthlyExpense.categoryId = (String) inputMap.get('categoryId' + i);
      monthlyExpense.expenseParent = (String) inputMap.get('expenseParent' + i);
      monthlyExpense.categoryName = (String) inputMap.get('categoryName' + i);
      monthlyExpense.control = (String) inputMap.get('control' + i);
      monthlyExpense.review = (String) inputMap.get('review' + i);
      if ((String) inputMap.get('statedMonthlyAverageAmount' + i) != 'null') {
        monthlyExpense.statedMonthlyAverageAmount = stringToMoney(
          (String) inputMap.get('statedMonthlyAverageAmount' + i)
        );
      } else {
        monthlyExpense.statedMonthlyAverageAmount = stringToMoney('0.0');
      }
      monthlyExpense.leafNode = Boolean.valueOf(
        (String) inputMap.get('leafNode' + i)
      );
      monthlyExpense.etag = (String) inputMap.get('etag' + i);
      monthlyExpense.hemState = (String) inputMap.get('hemState' + i);
      monthlyExpense.justificationCode = (String) inputMap.get(
        'justificationCode' + i
      );

      monthlyExpenses.add(monthlyExpense);
    }

    expenseModel.monthlyExpenses = monthlyExpenses;
    return expenseModel;
  }
  private static Boolean editIncomeExpenseRole() {
    String usrRoleName = [
      SELECT id, name, userRole.name
      FROM user
      WHERE id = :UserInfo.getUserId()
      LIMIT 1
    ]
    .UserRole.Name;
    Set<String> roleNameCanEditIncome = new Set<String>{
      'BOH Coach',
      'Credit Assessment Officer',
      'Credit Assessor Lead'
    };
    return roleNameCanEditIncome.contains(usrRoleName);
  }

  /**
   * @description publishes RLA event for reassessment toast
   * @param loan ResidentialLoanApplication
   */
  private static void publishRLARecordMonitoringToast(
    ResidentialLoanApplication loan
  ) {
    if (loan.Credit_Reassess_Required__c) {
      ToastAlertService.publishRecordMonitoringEvent(
        ToastAlertService.RLA_MESSAGE,
        new Set<ID>{ loan.Id }
      );
      return;
    }
    BOHService.setToReassessmentIsRequired(loan.Id);
  }

  /**
   * @description validate income forms
   * @param incomeType form contains information of a income type
   * @param isBonus boolean to indicate bonus payment
   * @return true if all the mandatory fields have value
   */
  private static Boolean validateSOPIncomeEditType(
    SOPCreateIncomeModel.SOPIncomeEditType incomeType,
    Boolean isBonus
  ) {
    if (
      incomeType.amount.units == 'null' ||
      String.isBlank(incomeType.amount.units) ||
      String.isBlank(incomeType.amountType)
    ) {
      return false;
    }
    if (!isBonus && String.isBlank(incomeType.frequency)) {
      return false;
    }
    if (isBonus && !(incomeType.bonusPayments > 0)) {
      return false;
    }
    return true;
  }

  /**
   * @description validate employment detail
   * @param employment `SOPCreateIncomeModel.SOPEmploymentDetail`
   * @return true if the employment detail is valid
   */
  private static Boolean validateEmploymentDetail(
    SOPCreateIncomeModel.SOPEmploymentDetail employment
  ) {
    if (
      String.isBlank(employment.partyId) ||
      String.isBlank(employment.businessName) ||
      String.isBlank(employment.basis)
    ) {
      return false;
    }
    return true;
  }
  /**
   * @description  set the emplyment start date for add/edit income
   * @param employment `SOPCreateIncomeModel.SOPEmploymentDetail
   * @param startDateStr start time of employment
   */
  private void setEmploymentStartDate(
    SOPCreateIncomeModel.SOPEmploymentDetail employment,
    String startDateStr
  ) {
    if (String.isBlank(startDateStr) || startDateStr == 'null') {
      setValidationError(BOHConstants.MANDATORY_FIELD_MISSING);
      return;
    }
    if (startDateStr != null && Date.parse(startDateStr) > Date.today()) {
      setValidationError(BOHConstants.START_DATE_ERROR);
      return;
    }
    List<String> dateParts = startDateStr.split('/');
    employment.startDate.day = Integer.valueOf(dateParts[0]);
    employment.startDate.month = Integer.valueOf(dateParts[1]);
    employment.startDate.year = Integer.valueOf(dateParts[2]);
  }

  /**
   * @description method to invoke addDebt
   * @param inputMap
   * @param outMap
   * @param options
   * @return Boolean for successful addDebt exection
   */
  private Boolean addDebt(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    try {
      Map<String, Object> debt = new Map<String, Object>{
        'parent' => (String) inputMap.get('parent'),
        'liability' => SOPDebtModel.parse(
          JSON.serialize(inputMap.get('liabilities'))
        )
      };

      ResidentialLoanApplicationAPIRepository rlaRepo = new ResidentialLoanApplicationAPIRepository();
      String loanId = (String) inputMap.get('loanId');

      List<ResidentialLoanApplication> loanRec = BOHService.getLoanRecord(
        loanId
      );
      rlaRepo.createDebt(
        loanRec[0]?.Account?.OCV_ID__c,
        JSON.serialize(debt, true)
          .replaceAll('"limitAmount"(\\ )*:', '"limit":'),
        loanId
      );
      publishRLARecordMonitoringToast(loanRec[0]);
      outMap.put('toast', 'success');
      outMap.put('toastMessage', 'The new debt was successfully added.');

      return true;
    } catch (Exception e) {
      outMap.put('object', new Map<String, Object>{ 'hasError' => true });
      Logger.error(e.getMessage(), e);
      Logger.saveLog();

      outMap.put('toast', 'error');
      outMap.put(
        'toastMessage',
        'The new debt couldn\'t be added. Please review and try again.'
      );

      return false;
    }
  }

  /**
   * @description method to invoke edit Debt
   * @param inputMap
   * @param outMap
   * @param options
   * @return Boolean for successful editDebt exection
   */
  @testVisible
  private Boolean editDebt(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    try {
      SOPDebtModel debtBody = SOPDebtModel.parse(
        JSON.serialize(inputMap.get('liabilities'))
      );

      ResidentialLoanApplicationAPIRepository rlaRepo = new ResidentialLoanApplicationAPIRepository();
      String loanId = (String) inputMap.get('loanAppId');

      List<ResidentialLoanApplication> loanRec = BOHService.getLoanRecord(
        loanId
      );
      rlaRepo.editDebt(
        loanRec[0]?.Account?.OCV_ID__c,
        JSON.serialize(debtBody, true)
          .replaceAll('"limitAmount"(\\ )*:', '"limit":'),
        loanId
      ); //Use JSON.serialize and replaceAll instead of the calloutModel one is because calloutModel will replace currency with currencyCode
      publishRLARecordMonitoringToast(loanRec[0]);
      outMap.put('toast', 'success');
      outMap.put(
        'toastMessage',
        'The changes to this debt were successfully saved.'
      );

      return true;
    } catch (Exception e) {
      outMap.put('object', new Map<String, Object>{ 'hasError' => true });
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
      outMap.put('toast', 'error');
      outMap.put(
        'toastMessage',
        'The debt couldn\'t be edited. Please review and try again.'
      );
      return false;
    }
  }

  /**
   * @description method to delete debt from sop
   * @param inputMap
   * @param outMap
   * @param options
   * @return Boolean for successful delete debt
   */
  @testVisible
  private Boolean deleteDebt(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    SOPDeleteModel model = new SOPDeleteModel();
    model.name = (String) inputMap.get('name');
    model.etag = (String) inputMap.get('etag');
    try {
      ResidentialLoanApplicationAPIRepository rlaRepo = new ResidentialLoanApplicationAPIRepository();
      String loanId = (String) inputMap.get('loanId');
      List<ResidentialLoanApplication> loanRec = BOHService.getLoanRecord(
        loanId
      );
      Boolean deleteDebtResponse = rlaRepo.deleteDebt(
        loanRec[0].SOP_Id__c,
        loanRec[0].Account.OCV_ID__c,
        JSON.serialize(model)
      );
      publishRLARecordMonitoringToast(loanRec[0]);
      outMap.put(
        'object',
        JSON.deserializeUntyped(JSON.serialize(deleteDebtResponse))
      );
      outMap.put('toast', 'Success');
      return true;
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
      outMap.put('toast', 'Error');
      return false;
    }
  }
}
