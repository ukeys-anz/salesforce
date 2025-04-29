/**
 * @author Hrushikesh
 * @since February 2025
 * @description Provider class that instantiates controller classes based on issue type.
 */
public with sharing class CaseGroupController {
  private static final AccountClosureRepository ACCOUNT_CLOSURE_REPOSITORY = (AccountClosureRepository) Lib_InstanceProvider.forType(
    AccountClosureRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final Map<String, String> ISSUE_TYPE_CONTROLLER = new Map<String, String>{
    'Account Closure' => 'AccountClosureWizardController',
    'Confirmation of Payee Opt-In' => 'ConfirmationOfPayeeController',
    'Confirmation of Payee Opt-Out' => 'ConfirmationOfPayeeController'
  };

  /**
   * @description Retrieves financial account records based on provided parameters.
   * @param params A map of request parameters.
   * @return A list of financial account models to be displayed in the data table.
   */
  @AuraEnabled
  public static List<CaseGroupFinancialAccountModel> getDataForDatatable(
    Map<String, String> params
  ) {
    try {
      Type controllerType = Type.forName(
        ISSUE_TYPE_CONTROLLER.get(params.get('issueType'))
      );
      CaseGroupWizard controller = (CaseGroupWizard) Lib_InstanceProvider.forType(
        controllerType
      );
      return controller.getData(params);
    } catch (Exception e) {
      throw new AuraHandledException(
        'Something went wrong. Please contact the system administrator.' +
        e.getMessage()
      );
    }
  }

  /**
   * @description Creates or updates child cases linked to financial accounts.
   * @param parentCaseId The ID of the parent case.
   * @param childCaseInputs A list of case data from the wizard.
   * @return A list of inserted or updated case records.
   */
  @AuraEnabled
  public static List<Case> createChildCasesForFinAccounts(
    Id parentCaseId,
    List<CaseInputWrapper> childCaseInputs
  ) {
    if (String.isBlank(parentCaseId) || childCaseInputs.isEmpty()) {
      return new List<Case>();
    }

    List<Case> existingUnusedCases = ACCOUNT_CLOSURE_REPOSITORY.getUnusedChildCasesByParentId(
      parentCaseId
    );

    List<Case> casesToUpsert = processCaseInputs(
      childCaseInputs,
      existingUnusedCases
    );

    //Reason for System Mode: No create access provided to users it will be just read and edit and for this reason we are using without sharing mode
    DML_REPOSITORY.doUpsert(casesToUpsert, new DmlConfig().withoutSharing());
    Set<Id> caseIds = new Set<Id>();
    caseIds.addAll(ListUtil.getIds(casesToUpsert, Case.Id));
    return ACCOUNT_CLOSURE_REPOSITORY.getInsertedOrUpdatedCaseDetails(caseIds);
  }

  /**
   * @description Processes case input data to determine whether to update existing cases or insert new ones.
   * @param childCaseInputs A list of case input wrappers from the wizard.
   * @param existingUnusedCases A list of unused case records to be updated.
   * @return List<Case>  list of case records
   */
  private static List<Case> processCaseInputs(
    List<CaseInputWrapper> childCaseInputs,
    List<Case> existingUnusedCases
  ) {
    List<Case> casesToUpsert = new List<Case>();
    for (CaseInputWrapper input : childCaseInputs) {
      if (!existingUnusedCases.isEmpty()) {
        Case existingCase = existingUnusedCases.remove(0);
        mapCaseFields(existingCase, input);
        casesToUpsert.add(existingCase);
      } else {
        Case newCase = new Case();
        mapCaseFields(newCase, input);
        casesToUpsert.add(newCase);
      }
    }
    return casesToUpsert;
  }

  /**
   * @description Maps fields from a CaseInputWrapper object to a Case object.
   * @param caseObj The case object to be inserted or updated.
   * @param caseInput The input data from LWC (Lightning Web Component).
   */
  private static void mapCaseFields(Case caseObj, CaseInputWrapper caseInput) {
    caseObj.Intended_Account_Name__c = caseInput.intendedAccountName;
    caseObj.Intended_Account_BSB__c = caseInput.intendedAccountBsb;
    caseObj.Intended_Account_Number__c = caseInput.intendedAccountNumber;
    caseObj.Closure_Reason__c = caseInput.closureReason;
    caseObj.Account_Type__c = caseInput.accountType;
    caseObj.AccountId = caseInput.accountId;
    caseObj.FinServ__FinancialAccount__c = caseInput.financialAccountId;
    caseObj.ProductId = caseInput.productId;
    caseObj.RecordTypeId = caseInput.recordTypeId;
    caseObj.Opt_Out_Reason__c = caseInput.copReason;
    caseObj.ParentId = caseInput.parentCaseId;
    caseObj.SI_PSI_Source_Other__c = caseInput.accountingSystem;
    caseObj.Sub_Status__c = caseInput.copStatus;
  }
}
