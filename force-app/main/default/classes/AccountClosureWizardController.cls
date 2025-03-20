/**
 * @author Nilesh Kalal
 * @since Fri Dec 6 2024
 * @description Controller for Account Closure Wizard
 */

public with sharing class AccountClosureWizardController implements CaseGroupWizard {
  private static final AccountClosureRepository ACCOUNT_CLOSURE_REPOSITORY = (AccountClosureRepository) Lib_InstanceProvider.forType(
    AccountClosureRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final Map<String, String> FIN_ACCOUNT_TYPE = new Map<String, String>{
    'Single' => 'Individual',
    'Multi-Party' => 'Joint'
  };
  private static final Map<String, String> FIN_ACCOUNT_TYPE_FOR_UI = new Map<String, String>{
    'Single' => 'Sole',
    'Multi-Party' => 'Joint'
  };
  /**
   * @description The Financial Account component uses this to fetch the records to display.
   * This makes the callout to fabric to fetch data
   * @param params the params to fetch the records
   * @return List<CaseGroupFinancialAccountModel>
   */
  public List<CaseGroupFinancialAccountModel> getData(
    Map<String, String> params
  ) {
    List<UnifiedFinancialAccountModel.AccountList> financialAccountsList = FinancialAccountController.getFinancialAccountsFromFabric(
      params.get('ocvId'),
      new List<String>()
    );

    List<Id> finAccountId = (List<Id>) ListUtil.getValues(
      financialAccountsList,
      'id',
      String.class
    );

    Set<Id> finAccountIds = new Set<Id>(finAccountId);

    List<Case> existingCasesForFinancialAccounts = ACCOUNT_CLOSURE_REPOSITORY.getCasesByFinancialAccountIds(
      finAccountIds
    );

    finAccountIds.removeAll(
      ListUtil.getIds(
        existingCasesForFinancialAccounts,
        Case.FinServ__FinancialAccount__c
      )
    );

    List<FinServ__FinancialAccount__c> listOfFinancialAccounts = ACCOUNT_CLOSURE_REPOSITORY.fetchFilteredFinancialAccountsDetails(
      finAccountIds
    );
    return prepareCaseGroupFinancialAccountModel(listOfFinancialAccounts);
  }

  /**
   * @description prepares CaseGroupFinancialAccountModel in order to show data on UI
   * @param listOfFinancialAccounts list of Financial Accounts
   * @return List<CaseGroupFinancialAccountModel>
   */

  private static List<CaseGroupFinancialAccountModel> prepareCaseGroupFinancialAccountModel(
    List<FinServ__FinancialAccount__c> listOfFinancialAccounts
  ) {
    List<CaseGroupFinancialAccountModel> listOfCaseGroupFinAccountModel = new List<CaseGroupFinancialAccountModel>();
    for (
      FinServ__FinancialAccount__c eachFinAccount : listOfFinancialAccounts
    ) {
      CaseGroupFinancialAccountModel caseGroupFinAccountModel = new CaseGroupFinancialAccountModel();
      caseGroupFinAccountModel.id = eachFinAccount.Id;
      caseGroupFinAccountModel.productId = eachFinAccount.FinServ__ProductName__c;
      caseGroupFinAccountModel.productName = eachFinAccount.FinServ__ProductName__r.Name;
      caseGroupFinAccountModel.accountNumber = eachFinAccount.FinServ__FinancialAccountNumber__c;
      caseGroupFinAccountModel.finAccountType = FIN_ACCOUNT_TYPE_FOR_UI.get(
        eachFinAccount.Ownership__c
      );
      caseGroupFinAccountModel.signingAuthority = (eachFinAccount.Ownership__c ==
        'Multi-party' &&
        eachFinAccount.Number_Of_Signatures__c == 'All to sign')
        ? eachFinAccount.Number_Of_Signatures__c
        : '';
      caseGroupFinAccountModel.balance = eachFinAccount.FinServ__Balance__c;
      caseGroupFinAccountModel.apiFinAccountType = FIN_ACCOUNT_TYPE.get(
        eachFinAccount.Ownership__c
      );
      listOfCaseGroupFinAccountModel.add(caseGroupFinAccountModel);
    }
    return listOfCaseGroupFinAccountModel;
  }
}
