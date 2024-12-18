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
   * @return Map<String, List<Case>>
   */

  public static Map<String, List<Case>> processCases(
    List<CaseInput> inputs,
    List<Case> listOfExistingDummyCases
  ) {
    List<Case> casesToUpdate = new List<Case>();
    List<Case> casesToInsert = new List<Case>();
    Map<String, List<Case>> mapToIdentifyInsertedOrUpdatedCases = new Map<String, List<Case>>();
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
      if (!casesToUpdate.isEmpty()) {
        DML_REPOSITORY.doUpdate(casesToUpdate);
        mapToIdentifyInsertedOrUpdatedCases.put('toUpdate', casesToUpdate);
      }
      if (!casesToInsert.isEmpty()) {
        DML_REPOSITORY.doInsert(casesToInsert);
        mapToIdentifyInsertedOrUpdatedCases.put('toInsert', casesToInsert);
      }
    }
    return mapToIdentifyInsertedOrUpdatedCases;
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
   * @description Inserted or Updated Case data which is requried to show on LWC
   * @param setOfCaseIdsToQuery set of case Ids to query
   * @return List<Case> list of case records
   */
  public List<Case> queryListOfInsertedOrUpdatedCases(
    Set<Id> setOfCaseIdsToQuery
  ) {
    return [
      SELECT
        Id,
        CaseNumber,
        Product__r.Name,
        FinServ_Product_Name__c,
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
        Account_Type__c
      FROM Case
      WHERE Id IN :setOfCaseIdsToQuery
    ];
  }

  /**
   * @description Inserted or Updated Case data which is requried to show on LWC
   * @param processedCases set of case Ids to query
   * @return Set<Id> list of case records
   */
  public static Set<Id> extractCaseIds(Map<String, List<Case>> processedCases) {
    Set<Id> caseIds = new Set<Id>();
    List<Case> allCases = new List<Case>(); // Collect all Case records into one List (flatten the map)
    if (
      processedCases.containsKey('toUpdate') &&
      processedCases.get('toUpdate') != null
    ) {
      allCases.addAll(processedCases.get('toUpdate'));
    }
    if (
      processedCases.containsKey('toInsert') &&
      processedCases.get('toInsert') != null
    ) {
      allCases.addAll(processedCases.get('toInsert'));
    }
    // Add all Case IDs to the Set
    for (Case eachCase : allCases) {
      caseIds.add(eachCase.Id);
    }
    return caseIds;
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
        listOfFinancialAccountResponse.add(
          new FinancialAccountsResponse(
            dbAcc.Id,
            dbAcc.FinServ__FinancialAccountNumber__c,
            dbAcc.FinServ__ProductName__r.Name,
            dbAcc.FinServ__ProductName__c, //this is lookup to product table, hence product Id
            dbAcc.FinServ__Balance__c,
            dbAcc.FinServ__Ownership__c,
            dbAcc.Marketing_Code__c,
            dbAcc.FinServ__Status__c,
            dbAcc.RecordType.DeveloperName
          )
        );
      }
    }
    return listOfFinancialAccountResponse;
  }
}
