/**
 * @author @fangl6(Lei Fang)
 * @description controller class for flexcard to show SOP
 * @since April 2023
 */
global with sharing class ResidentialLoanApplicationController implements omnistudio.VlocityOpenInterface, Callable {
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
    SOPCreateIncomeModel model = generateCreateIncomeModel(inputMap);

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
    SOPUpdateIncomeModel model = generateUpdateIncomeModel(inputMap);

    try {
      ResidentialLoanApplicationAPIRepository rlaRepo = new ResidentialLoanApplicationAPIRepository();
      String loanId = (String) inputMap.get('loanId');
      String incomeVerified = (String) inputMap.get('incomeVerified');

      List<ResidentialLoanApplication> loanRec = BOHService.getLoanRecord(
        loanId
      );
      publishRLARecordMonitoringToast(loanRec[0]);

      rlaRepo.updateIncome(
        loanRec[0]?.Account?.OCV_ID__c,
        incomeVerified,
        JSON.serialize(model),
        loanId
      );

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
      publishRLARecordMonitoringToast(loanRec[0]);

      rlaRepo.editExpense(
        loanRec[0]?.Account?.OCV_ID__c,
        JSON.serialize(expenseModel),
        loanId
      );

      return true;
    } catch (Exception e) {
      /** REVIEWER DISCLOSER: please leave for temporary debugging purpose */
      System.debug('$$$ editExpense Exception : ' + e.getMessage());
      System.debug('$$$ editExpense Exception : ' + e.getLineNumber());
      System.debug('$$$ editExpense Exception : ' + e.getStackTraceString());

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
    String startDateStr = (String) inputMap.get('startDate');
    List<String> dateParts = startDateStr.split('-');
    model.income.employment.startDate.month = Integer.valueOf(dateParts[0]);
    model.income.employment.startDate.day = Integer.valueOf(dateParts[1]);
    model.income.employment.startDate.year = Integer.valueOf(dateParts[2]);
    model.income.employment.type = 'EMPLOYMENT_TYPE_PAYG';

    SOPCreateIncomeModel.SOPIncomeEditType baseSalary = new SOPCreateIncomeModel.SOPIncomeEditType();
    baseSalary.type = 'INCOME_TYPE_BASE_SALARY';
    baseSalary.frequency = (String) inputMap.get('baseSalaryFrequency');
    baseSalary.amount = stringToMoney((String) inputMap.get('salaryAmount'));
    baseSalary.amountType = (String) inputMap.get('salaryTax');
    model.income.details.add(baseSalary);

    String showOvertime = (String) inputMap.get('showOvertime');
    if (showOvertime == 'true') {
      SOPCreateIncomeModel.SOPIncomeEditType overtime = new SOPCreateIncomeModel.SOPIncomeEditType();
      overtime.type = 'INCOME_TYPE_OVERTIME';
      overtime.frequency = (String) inputMap.get('overtimeFrequency');
      overtime.amount = stringToMoney((String) inputMap.get('overtimeAmount'));
      overtime.amountType = (String) inputMap.get('overtimeTax');
      model.income.details.add(overtime);
    }

    String showBonus = (String) inputMap.get('showBonus');
    if (showBonus == 'true') {
      SOPCreateIncomeModel.SOPIncomeEditType bonus = new SOPCreateIncomeModel.SOPIncomeEditType();
      bonus.type = 'INCOME_TYPE_BONUS';
      bonus.amount = stringToMoney((String) inputMap.get('bonusAmount'));
      bonus.amountType = (String) inputMap.get('bonusTax');
      String paymentsStr = (String) inputMap.get('bonusPayments');
      bonus.bonusPayments = Integer.valueOf(paymentsStr);
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
      model.income.details.add(commission);
    }

    return model;
  }

  private SOPUpdateIncomeModel generateUpdateIncomeModel(
    Map<String, Object> inputMap
  ) {
    SOPUpdateIncomeModel model = new SOPUpdateIncomeModel();
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
    String startDateStr = (String) inputMap.get('startDate');
    List<String> dateParts = startDateStr.split('-');
    model.employment.startDate.month = Integer.valueOf(dateParts[0]);
    model.employment.startDate.day = Integer.valueOf(dateParts[1]);
    model.employment.startDate.year = Integer.valueOf(dateParts[2]);
    model.employment.type = 'EMPLOYMENT_TYPE_PAYG';

    SOPCreateIncomeModel.SOPIncomeEditType baseSalary = new SOPCreateIncomeModel.SOPIncomeEditType();
    baseSalary.type = 'INCOME_TYPE_BASE_SALARY';
    baseSalary.frequency = (String) inputMap.get('baseSalaryFrequency');
    baseSalary.amount = stringToMoney((String) inputMap.get('salaryAmount'));
    baseSalary.amountType = (String) inputMap.get('salaryTax');
    model.details.add(baseSalary);

    String showOvertime = (String) inputMap.get('showOvertime');
    if (showOvertime == 'true') {
      SOPCreateIncomeModel.SOPIncomeEditType overtime = new SOPCreateIncomeModel.SOPIncomeEditType();
      overtime.type = 'INCOME_TYPE_OVERTIME';
      overtime.frequency = (String) inputMap.get('overtimeFrequency');
      overtime.amount = stringToMoney((String) inputMap.get('overtimeAmount'));
      overtime.amountType = (String) inputMap.get('overtimeTax');
      model.details.add(overtime);
    }

    String showBonus = (String) inputMap.get('showBonus');
    if (showBonus == 'true') {
      SOPCreateIncomeModel.SOPIncomeEditType bonus = new SOPCreateIncomeModel.SOPIncomeEditType();
      bonus.type = 'INCOME_TYPE_BONUS';
      bonus.amount = stringToMoney((String) inputMap.get('bonusAmount'));
      bonus.amountType = (String) inputMap.get('bonusTax');
      String paymentsStr = (String) inputMap.get('bonusPayments');
      bonus.bonusPayments = Integer.valueOf(paymentsStr);
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
      model.details.add(commission);
    }

    return model;
  }

  private SOPMoney stringToMoney(String amountStr) {
    SOPMoney amount = new SOPMoney();
    amount.currencyCode = 'AUD';

    List<String> parts = amountStr.split('\\.');
    amount.units = parts[0];
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

    SOPEditExpenseModel.MonthlyExpense monthlyExpense = new SOPEditExpenseModel.MonthlyExpense();
    monthlyExpense.name = (String) inputMap.get('name');
    monthlyExpense.uid = (String) inputMap.get('uid');
    monthlyExpense.categoryId = (String) inputMap.get('categoryId');
    monthlyExpense.expenseParent = (String) inputMap.get('expenseParent');
    monthlyExpense.categoryName = (String) inputMap.get('categoryName');
    monthlyExpense.control = (String) inputMap.get('control');
    monthlyExpense.review = (String) inputMap.get('review');
    monthlyExpense.statedMonthlyAverageAmount = stringToMoney(
      (String) inputMap.get('statedMonthlyAverageAmount')
    );
    monthlyExpense.leafNode = Boolean.valueOf(
      (String) inputMap.get('leafNode')
    );
    monthlyExpense.etag = (String) inputMap.get('etag');
    monthlyExpense.hemState = (String) inputMap.get('hemState');
    monthlyExpenses.add(monthlyExpense);

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
}
