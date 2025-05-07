/**
 * @description controller class for sop page
 * @author @fangl6
 * @since 09/2024
 */
public with sharing class SOPController {
  public static string currentSopId;
  private static final ResidentialLoanApplicationRepository RLA_SOQL_REPOSITORY = (ResidentialLoanApplicationRepository) Lib_InstanceProvider.forType(
    ResidentialLoanApplicationRepository.class
  );
  private static final ResidentialLoanApplicationAPIRepository RLA_API_REPOSITORY = (ResidentialLoanApplicationAPIRepository) Lib_InstanceProvider.forType(
    ResidentialLoanApplicationAPIRepository.class
  );

  private static final String ERROR_MSG = 'Failed to retrieve finance details. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  private static final String BELONGS_TO_ERROR_MSG = 'Failed to retrieve belongs to details. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  public static final String ADD_DEBT_ERROR = 'The new debt couldn\'t be added. Please review and try again. Raise a fault through TechAssist if the problem persists.';
  public static final String EDIT_DEBT_ERROR = 'All the changes to this debt didn\'t save. Please review and try again. Raise a fault through TechAssist if the problem persists.';
  public static final String DELETE_DEBT_ERROR = 'This debt couldn\'t be deleted. Please try again. Raise a fault through TechAssist if the problem persists.';
  private static final String INCOME_VERIFY_ERROR = 'The income verified value was not saved. Please review and try again. Raise a fault through TechAssist if the problem persists.';
  private static final String ADD_INCOME_ERROR = 'The income record couldn\'t be added. Please review and try again. Raise a fault through TechAssist if the problem persists.';
  private static final String EDIT_INCOME_ERROR = 'The income record didn\'t save all the changes. Please review and try again. Raise a fault through TechAssist if the problem persists.';
  private static final String DELETE_INCOME_ERROR = 'The income record couldn\'t be deleted. Please review and try again. Raise a fault through TechAssist if the problem persists.';
  private static final String EDIT_EXPENSE_ERROR = 'The changes to the spend category didn\'t save. Please review and try again.';
  private static final String LIST_EXPENSE_ERROR = 'The monthly spend total didn\'t update. Click \'Refresh All Amounts\' or refresh the page to see the updated total.';

  /**
   * @description call getConsolidatedSOP API, query related records in salesforce, return the get consolidated sop view model
   * @param loanId loan record salesforce id
   * @return  `SOPGetConsolidatedViewModel` view model for finance tab in RLA
   * @exception
   */
  @AuraEnabled
  public static SOPGetConsolidatedViewModel getConsolidatedSOP(String loanId) {
    try {
      ResidentialLoanApplication loanRec = RLA_SOQL_REPOSITORY.queryRLAById(
        loanId
      );
      if (loanRec == null) {
        throw new IllegalArgumentException('Valid Loan Record not found');
      }
      SOPGetConsolidatedModel sopMessage = RLA_API_REPOSITORY.getConsolidatedSOP(
        loanRec.Account?.OCV_ID__c,
        loanRec.SOP_Id__c
      );
      currentSopId = sopMessage.sop.name;

      return new SOPGetConsolidatedViewModel(
        sopMessage,
        SOPHelper.initPartyIdToFirstNameMap(sopMessage.sop.parties),
        loanId
      );
    } catch (Exception e) {
      Logger.error('Failure on SOP Get Consolidated', e);
      Logger.saveLog();

      AuraHandledException err = new AuraHandledException(ERROR_MSG);
      err.setMessage(ERROR_MSG);
      throw err;
    }
  }

  /**
   * @description call the sop API to add new income record
   * @param loanId residential loan application id
   * @param incomeDetails income details to be added
   * @return  `String` message to lwc
   * @exception api call failure
   */
  @AuraEnabled
  public static String addIncome(
    String loanId,
    SOPAddEditIncomeModel incomeDetails
  ) {
    try {
      ResidentialLoanApplication loanRec = RLA_SOQL_REPOSITORY.queryRLAById(
        loanId
      );

      if (loanRec == null) {
        throw new IllegalArgumentException('Valid Loan Record not found');
      }

      String requestBody = JSON.serialize(incomeDetails, true);
      RLA_API_REPOSITORY.createIncome(
        loanRec.Account?.OCV_ID__c,
        incomeDetails.incomeVerified ? 'Yes' : 'No',
        requestBody,
        loanId
      );
      SOPHelper.publishRLARecordMonitoringToast(loanRec);
      return 'Success';
    } catch (Exception e) {
      Logger.error('Failed to add new income', e.getMessage());
      Logger.saveLog();
      if (e.getMessage().contains('verifyIncome:HTTP POST')) {
        throw new AuraHandledException(INCOME_VERIFY_ERROR);
      } else {
        throw new AuraHandledException(ADD_INCOME_ERROR);
      }
    }
  }
  /**
   * @description call the sop API to edit income record
   * @param loanId residential loan application id
   * @param incomeDetails income details to be updated
   * @return  `String` meesage to lwc
   * @exception call failure
   */
  @AuraEnabled
  public static String editIncome(
    String loanId,
    SOPAddEditIncomeModel incomeDetails
  ) {
    try {
      ResidentialLoanApplication loanRec = RLA_SOQL_REPOSITORY.queryRLAById(
        loanId
      );

      if (loanRec == null) {
        throw new IllegalArgumentException('Valid Loan Record not found');
      }

      String requestBody = JSON.serialize(incomeDetails, true);
      RLA_API_REPOSITORY.updateIncome(
        new Map<String, String>{
          'ocvId' => loanRec.Account?.OCV_ID__c,
          'verification' => incomeDetails.incomeVerified ? 'Yes' : 'No',
          'incomeBody' => requestBody,
          'loanId' => loanId
        },
        incomeDetails.incomeVerifiedChanged
      );
      SOPHelper.publishRLARecordMonitoringToast(loanRec);
      return 'Success';
    } catch (Exception e) {
      Logger.error('Failed to add new income', e.getMessage());
      Logger.saveLog();
      if (e.getMessage().contains('verifyIncome:HTTP POST')) {
        throw new AuraHandledException(INCOME_VERIFY_ERROR);
      } else {
        throw new AuraHandledException(EDIT_INCOME_ERROR);
      }
    }
  }

  /**
   * @description call editExpense API, query related records in salesforce, set flag to publish toast.
   * @param loanId loan record salesforce id
   * @param sopExpenseEditModel api model for editing expenses
   */
  @AuraEnabled
  public static void editExpense(
    String loanId,
    SOPExpenseEditModel sopExpenseEditModel
  ) {
    try {
      ResidentialLoanApplication loanRec = RLA_SOQL_REPOSITORY.queryRLAById(
        loanId
      );

      if (loanRec == null) {
        throw new IllegalArgumentException('Valid Loan Record not found');
      }

      String sopExpenseEditModelJson = JSON.serialize(
        sopExpenseEditModel,
        true
      );

      RLA_API_REPOSITORY.editExpense(
        loanRec.Account?.OCV_ID__c,
        sopExpenseEditModelJson,
        loanId
      );

      SOPHelper.publishRLARecordMonitoringToast(loanRec);
    } catch (Exception e) {
      Logger.error('Failure on edit expenses', e);
      Logger.saveLog();

      if (e.getMessage().contains('listExpense')) {
        throw new AuraHandledException(LIST_EXPENSE_ERROR);
      } else {
        throw new AuraHandledException(EDIT_EXPENSE_ERROR);
      }
    }
  }

  /**
   * @description call deleteIncome API, query related records in salesforce, set flag to publish toast.
   * @param loanId loan record salesforce id
   * @param incomeName income name to be used in the model
   * @param etag etag to be used in the model
   * @return  `Boolean` return success of call
   */
  @AuraEnabled
  public static Boolean deleteIncome(
    String loanId,
    String incomeName,
    String etag
  ) {
    try {
      ResidentialLoanApplication loanRec = RLA_SOQL_REPOSITORY.queryRLAById(
        loanId
      );

      if (loanRec == null) {
        throw new IllegalArgumentException('Valid Loan Record not found');
      }

      SOPDeleteModel model = new SOPDeleteModel();
      model.name = incomeName;
      model.etag = etag;

      RLA_API_REPOSITORY.deleteIncome(
        loanRec.SOP_Id__c,
        loanRec.Account?.OCV_ID__c,
        JSON.serialize(model),
        loanId
      );
      SOPHelper.publishRLARecordMonitoringToast(loanRec);
    } catch (Exception e) {
      Logger.error('Failure on delete income', e);
      Logger.saveLog();

      throw new AuraHandledException(DELETE_INCOME_ERROR);
    }

    return true;
  }

  /**
   * @description call deleteDebt API, query related records in salesforce, set flag to publish toast.
   * @param loanId loan record salesforce id
   * @param debtName debt name to be used in the model
   * @param etag etag to be used in the model
   * @return  `Boolean` return success of call
   */
  @AuraEnabled
  public static Boolean deleteDebt(
    String loanId,
    String debtName,
    String etag
  ) {
    try {
      ResidentialLoanApplication loanRec = RLA_SOQL_REPOSITORY.queryRLAById(
        loanId
      );

      if (loanRec == null) {
        throw new IllegalArgumentException('Valid Loan Record not found');
      }

      SOPDeleteModel model = new SOPDeleteModel();
      model.name = debtName;
      model.etag = etag;

      RLA_API_REPOSITORY.deleteDebt(
        loanRec.SOP_Id__c,
        loanRec.Account?.OCV_ID__c,
        JSON.serialize(model)
      );
      SOPHelper.publishRLARecordMonitoringToast(loanRec);
    } catch (Exception e) {
      Logger.error('Failure on delete debt', e);
      Logger.saveLog();

      throw new AuraHandledException(DELETE_DEBT_ERROR);
    }

    return true;
  }

  /**
   * @description retrieves options for belongs to for adding debt
   * @param parties list of parties from SOP payload
   * @param loanAppId loan application id
   * @return List<Map<String, String>> option list of belongs to
   */
  @AuraEnabled
  public static List<Map<String, String>> getBelongsToOptions(
    List<Map<String, String>> parties,
    Id loanAppId
  ) {
    List<Map<String, String>> uiOptions = new List<Map<String, String>>();
    try {
      List<String> ocvIds = new List<String>();
      Map<String, String> partyIdMap = new Map<String, String>();
      for (Integer i = 0; i < parties.size(); i++) {
        //Create list of OCVids to query for
        ocvIds.add(parties[i].get('ocvId'));
        //Create party map to fetch based on ocv
        partyIdMap.put(parties[i].get('ocvId'), parties[i].get('partyId'));
      }

      //Create generic select options
      Map<String, String> clearMap = new Map<String, String>();
      clearMap.put('label', '--Please Select--');
      clearMap.put('value', '');
      clearMap.put('disabled', 'true');
      uiOptions.add(clearMap);

      List<LoanApplicant> applicantList = RLA_SOQL_REPOSITORY.getLoanApplicants(
        ocvIds,
        loanAppId
      );

      for (LoanApplicant applicant : applicantList) {
        Map<String, String> tempMap = new Map<String, String>();
        tempMap.put('label', applicant.Account__r.Name);
        tempMap.put('partyId', partyIdMap.get(applicant.Party_ID__c));
        uiOptions.add(tempMap);
      }
    } catch (Exception e) {
      Logger.error('Failed to generate belongs to', e.getMessage());
      Logger.saveLog();
      AuraHandledException err = new AuraHandledException(BELONGS_TO_ERROR_MSG);
      err.setMessage(BELONGS_TO_ERROR_MSG);
      throw err;
    }

    return uiOptions;
  }

  /**
   * @description Add or edit a debt
   * @param loanId loan record salesforce id
   * @param debtDetails data for debt to add or edit
   * @param action type of action to perform, edit or add
   * @return  `Boolean` return success of call
   * @exception
   */
  @AuraEnabled
  public static Boolean addEditDebt(
    String loanId,
    SOPAddEditDebtModel debtDetails,
    String action
  ) {
    try {
      ResidentialLoanApplication rla = RLA_SOQL_REPOSITORY.queryRLAById(loanId);

      if (rla == null) {
        throw new IllegalArgumentException('Valid Loan Record not found');
      }

      if (action == 'Add') {
        debtDetails.parent = 'sops/' + rla.SOP_Id__c;
      }

      Map<String, Object> debtDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(
        JSON.serialize(debtDetails, true)
      );

      // Check if studentLoan is null and remove it if necessary
      if (debtDetailsMap.containsKey('liability')) {
        Map<String, Object> liabilityMap = (Map<String, Object>) debtDetailsMap.get(
          'liability'
        );
        if (
          liabilityMap.containsKey('studentLoan') &&
          liabilityMap.get('studentLoan') == null
        ) {
          liabilityMap.remove('studentLoan');
        }
      }

      String payload;
      //Edit only needs liability node
      if (action == 'Add') {
        //Replace empty objects with null
        payload = JSON.serialize(debtDetailsMap, true)
          .replaceAll('\\{\\s*\\}', 'null');
      } else {
        payload = JSON.serialize(debtDetailsMap.get('liability'), true)
          .replaceAll('\\{\\s*\\}', 'null');
      }
      //deserialize and serialize again to remove the null values and replace limitAmount with correct API value
      payload = JSON.serialize(JSON.deserializeUntyped(payload), true)
        .replaceAll('"limitAmount"(\\ )*:', '"limit":');

      if (action == 'Add') {
        RLA_API_REPOSITORY.createDebt(rla.Account?.OCV_ID__c, payload, loanId);
      } else {
        RLA_API_REPOSITORY.editDebt(rla.Account?.OCV_ID__c, payload, loanId);
      }

      SOPHelper.publishRLARecordMonitoringToast(rla);
    } catch (Exception e) {
      Logger.error(
        'Failed to handle debt with action ' + action,
        e.getMessage()
      );
      Logger.saveLog();
      if (action == 'Add') {
        throw new AuraHandledException(ADD_DEBT_ERROR);
      } else {
        throw new AuraHandledException(EDIT_DEBT_ERROR);
      }
    }
    return true;
  }
}
