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
      Boolean allowDeleteIncome = false;
      Boolean showAddEditIncomeBtn = false;
      String loanId = (String) inputMap.get('loanId');

      List<ResidentialLoanApplication> loanRec = BOHService.getLoanRecord(
        loanId
      );
      ResidentialLoanApplicationModel sopAssets = rlaRepo.getListAssets(
        loanRec[0]?.Account?.OCV_ID__c,
        loanRec[0]?.SOP_Id__c
      );
      if (loanRec[0]?.Status == 'STATE_REFERRED' && editIncomeExpenseRole()) {
        showAddEditIncomeBtn = true;
        sopAssets.showEditExpenseBtn = true;
      }
      if (sopAssets.incomesSummary.incomes.size() > 1) {
        allowDeleteIncome = true;
      }
      sopAssets.showAddIncomeBtn = showAddEditIncomeBtn;
      for (
        ResidentialLoanApplicationModel.SOPIncome income : sopAssets
          ?.incomesSummary
          ?.incomes
      ) {
        income.showEditIncomeBtn = showAddEditIncomeBtn;
        income.allowdelete = allowDeleteIncome;
      }

      //Remove Closed status values from assets and debts.
      //Need to loop backwards so next item isn't missed
      for (Integer i = sopAssets.assetsSummary.assets.size() - 1; i >= 0; i--) {
        if (
          sopAssets.assetsSummary.assets[i]?.account?.status ==
          'ACCOUNT_STATE_CLOSED'
        ) {
          sopAssets.assetsSummary.assets.remove(i);
        }
      }

      for (
        Integer i = sopAssets.liabilitiesSummary.liabilities.size() - 1;
        i >= 0;
        i--
      ) {
        if (
          sopAssets.liabilitiesSummary.liabilities[i]?.account?.status ==
          'ACCOUNT_STATE_CLOSED'
        ) {
          sopAssets.liabilitiesSummary.liabilities.remove(i);
        }
      }

      SOPModelHelper.initPartyLiability(sopAssets);
      SOPModelHelper.enrichSourcesOwnerName(sopAssets);

      outMap.put('object', JSON.deserializeUntyped(JSON.serialize(sopAssets)));
      return true;
    } catch (Exception e) {
      return false;
    }
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
    ResidentialLoanApplicationAPIRepository rlaRepo = new ResidentialLoanApplicationAPIRepository();
    String loanId = (String) inputMap.get('loanId');
    List<ResidentialLoanApplication> loanRec = BOHService.getLoanRecord(loanId);

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
      String incomeVerified = (String) inputMap.get('incomeVerified');

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
      outMap.put('toast', 'Error');
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
      String incomeVerified = (String) inputMap.get('incomeVerified');

      List<ResidentialLoanApplication> loanRec = BOHService.getLoanRecord(
        loanId
      );

      rlaRepo.updateIncome(
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
      outMap.put('toast', 'Error');
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
    SOPDeleteIncomeModel model = new SOPDeleteIncomeModel();
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
      SOPEditExpenseModel expenseModel = createEditExpensesModel(inputMap);

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
      incomeType.amount.units == 'null' || String.isBlank(incomeType.amountType)
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
}
