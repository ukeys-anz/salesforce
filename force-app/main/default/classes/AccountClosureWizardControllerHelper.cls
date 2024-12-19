/**
 * @author Nilesh Kalal
 * @since Wed Dec 18 2024
 * @description Helper for Account Closure Wizard Controller
 */
public with sharing class AccountClosureWizardControllerHelper {
  private static final AccountClosureRepository ACCOUNT_CLOSURE_REPOSITORY = (AccountClosureRepository) Lib_InstanceProvider.forType(
    AccountClosureRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Process dummy cases if found and map user input from lwc to case records
   * @param inputs List of CaseInput
   * @param listOfExistingDummyCases List of Cases
   * @return Set<Id>
   */

  public static Set<Id> processCases(
    List<CaseInput> inputs,
    List<Case> listOfExistingDummyCases
  ) {
    List<Case> casesToUpdate = new List<Case>();
    List<Case> casesToInsert = new List<Case>();
    List<Case> masterList = new List<Case>();
    Set<Id> setOfCaseIds = new Set<Id>();
    Integer index = 0;
    for (CaseInput input : inputs) {
      if (index < listOfExistingDummyCases.size()) {
        Case existingCase = listOfExistingDummyCases[index];
        mapCaseFields(existingCase, input);
        casesToUpdate.add(existingCase);
        index++;
      } else {
        // Create a new case if no existing case is available
        Case newCase = new Case();
        mapCaseFields(newCase, input);
        casesToInsert.add(newCase);
      }
    }
    if (!casesToUpdate.isEmpty()) {
      DML_REPOSITORY.doUpdate(casesToUpdate);
    }
    if (!casesToInsert.isEmpty()) {
      DML_REPOSITORY.doInsert(casesToInsert);
    }
    masterList.addAll(casesToUpdate);
    masterList.addAll(casesToInsert);
    setOfCaseIds = ListUtil.getIds(masterList, Case.Id);
    return setOfCaseIds;
  }

  /**
   * @description
   * @param caseObj case object record to be inserted or updated
   * @param caseInput from LWC
   */
  private static void mapCaseFields(Case caseObj, CaseInput caseInput) {
    caseObj.Status = caseInput.status;
    caseObj.Intended_Account_Name__c = caseInput.intendedAccountName;
    caseObj.Intended_Account_BSB__c = caseInput.intendedAccountBsb;
    caseObj.Intended_Account_Number__c = caseInput.intendedAccountNumber;
    caseObj.Closure_Reason__c = caseInput.closureReason;
    caseObj.Account_Type__c = caseInput.accountType;
    caseObj.AccountId = caseInput.accountId;
    caseObj.FinServ__FinancialAccount__c = caseInput.finiancialAccountId;
    caseObj.ProductId = caseInput.productId; // lookup to product table
    caseObj.RecordTypeId = RTCase.accountClosure;
  }

  /**
   * @description Extracts the Account Ids from the Case records
   * @param acccountIds set of case Ids to query
   * @return Set<Id> list of case records
   */
  public static Set<Id> getAccountsWithChildCases(Set<Id> acccountIds) {
    List<Case> childCases = ACCOUNT_CLOSURE_REPOSITORY.fetchChildCases(
      acccountIds
    );
    Set<Id> setOfFinAccountIds = ListUtil.getIds(
      childCases,
      Case.FinServ__FinancialAccount__c
    );
    return setOfFinAccountIds;
  }

  /**
   * @description Extracts the Account Ids from the Case records
   * @param fabricAccounts list of financial account records
   * @param dbAccounts map of financial account Ids to query
   * @return List<FinancialAccountsResponse> list of Financial Account response
   */

  public static List<FinancialAccountsResponse> prepareFinancialAccountsResponse(
    List<FinServ__FinancialAccount__c> fabricAccounts,
    Map<Id, FinServ__FinancialAccount__c> dbAccounts
  ) {
    List<FinancialAccountsResponse> listOfFinancialAccountResponse = new List<FinancialAccountsResponse>();
    for (FinServ__FinancialAccount__c eachAccount : fabricAccounts) {
      if (dbAccounts.containsKey(eachAccount.Id)) {
        FinServ__FinancialAccount__c dbAcc = dbAccounts.get(eachAccount.Id);

        // Use the Builder pattern to create the FinancialAccountsResponse object
        FinancialAccountsResponse response = new FinancialAccountsResponse.Builder()
          .setId(dbAcc.Id)
          .setAccountNumber(dbAcc.FinServ__FinancialAccountNumber__c)
          .setProductName(dbAcc.FinServ__ProductName__r.Name)
          .setProductId(dbAcc.FinServ__ProductName__c) // Product Id (lookup field)
          .setBalance(dbAcc.FinServ__Balance__c)
          .setOwnership(dbAcc.FinServ__Ownership__c)
          .setMarketingCode(dbAcc.Marketing_Code__c)
          .setStatus(dbAcc.FinServ__Status__c)
          .setRecodTypeName(dbAcc.RecordType.DeveloperName)
          .build();

        // Add the response to the list
        listOfFinancialAccountResponse.add(response);
      }
    }
    return listOfFinancialAccountResponse;
  }
}
