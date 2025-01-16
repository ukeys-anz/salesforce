
/**
 * @author Shivam Swaraj
 * @since December 2024
 * @description Helper Class for AccountClosureController for Account Closure Prechecks
 */
public with sharing class AccountClosureControllerHelper {
    private static final AccountClosureRepository ACCOUNT_CLOSURE_REPOSITORY = (AccountClosureRepository) Lib_InstanceProvider.forType(
        AccountClosureRepository.class
      );
    
    private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
        DmlRepository.class
      );

    /**
     * @description method to process response and segregrate success and failure cases and update
     * @param fabricSealResponseList response received from fabric seal api
     * @param eligibleCasesForPrecheck eligibleCasesForPrecheck
     * @return List<Case> list of cases updated successfully
     */
    public static List<Case> processResponsesAndUpdateCases(List<Object> fabricSealResponseList,
    List<Case> eligibleCasesForPrecheck) {
      Map<String, String> successCases = new Map<String, String>();
      Map<String, Set<String>> failedCases = new Map<String, Set<String>>();
    
      segregrateResponses(successCases,failedCases,fabricSealResponseList);
    
      Map<String, Id> caseNumberToIdMap = createCaseNumberToIdMap(
          eligibleCasesForPrecheck
      );

      List<Case> casesToUpdate = prepareCasesForUpdate(
          successCases,
          failedCases,
          caseNumberToIdMap
      );

      if (casesToUpdate.isEmpty()) {
          return new List<Case>();
      }

      DML_REPOSITORY.doUpdate(casesToUpdate, new DmlConfig().allowPartial());

      return ACCOUNT_CLOSURE_REPOSITORY.queryChildCasesDetailsPostPrecheck(
          new Map<Id, Case>(casesToUpdate)
        );
    }


   /**
     * @description method to prepare map of successful cases and failed cases
     * @param successCases pass by reference for map of successfull cases and their business process id
     * @param failedCases  pass by reference for map of failed cases and their failed reasons
     * @param fabricSealResponseList consolidated fabric seal response
     */
    private static void segregrateResponses(Map<String, String> successCases,
    Map<String, Set<String>> failedCases,
    List<Object> fabricSealResponseList){

        for (Object eachResponse : fabricSealResponseList) {
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(
              JSON.serialize(eachResponse)
              );
            if ( (String)response.get('acceptance') == 'ACCEPTANCE_ACCEPTED') {
              successCases.put(
                (String)response.get('salesforceCaseNumber'),
                (String)response.get('businessProcessId')
              );
            } else if ( (String) response.get('acceptance') == 'ACCEPTANCE_REJECTED') {
              Set<String> failedReasons = createFailedReasonsSet(
                  response.get('unsatisfiedPreconditions')
              );
              if (!failedReasons.isEmpty()) {
                failedCases.put( (String)response.get('salesforceCaseNumber'), failedReasons);
              }
            } else if ( (String)response.get('acceptance') == null &&  (String)response.get('message') != null) {
              failedCases.put(
                (String)response.get('salesforceCaseNumber'),
                new Set<String>{ 'techError' }
              );
            }
        }
    }   
    /**
     * @description method to create set of failed reasons whose eligibility is ineligible
     * @param reasons instance of FabricSealResponseModel.UnsatisfiedPreconditions
     * @return Set<String> set of reasons which are ineligible
     */
    private static Set<String> createFailedReasonsSet(
        Object reasons
    ) {
        Set<String> failedReasons = new Set<String>();
        if (reasons == null) {
            return failedReasons;
        }

        Map<String, Object> failedReasonsMap = (Map<String, Object>) reasons;

        for (String reason : failedReasonsMap.keySet()) {
            Object reasonValue = failedReasonsMap.get(reason);
            if (reasonValue instanceof Map<String, Object>) {
                Map<String, Object> reasonDetails = (Map<String, Object>) reasonValue;
                if (
                (String) reasonDetails.get('eligibility') == 'ELIGIBILITY_INELIGIBLE'
                ) {
                failedReasons.add(reason);
                }
            }
        }
        return failedReasons;
    }

    /**
     * @description method to create set of failed reasons whose eligibility is ineligible
     * @param cases List of Eligible Cases for Precheck
     * @return Map<String, Id> map of CaseNumber and Id
     */
    private static Map<String, Id> createCaseNumberToIdMap(List<Case> cases) {
        Map<String, Id> caseNumberToIdMap = new Map<String, Id>();
        for (Case caseRec : cases) {
        caseNumberToIdMap.put(caseRec.CaseNumber, caseRec.Id);
        }
        return caseNumberToIdMap;
    }

    /**
     * @description method to prepare list of cases to update
     * @param successCases map of successfull cases and their business process id
     * @param failedCases map of failed cases and their failed reasons
     * @param caseNumberToIdMap Map<String, Id>
     * @return List of cases to be updated
     */
    private static List<Case> prepareCasesForUpdate(
        Map<String, String> successCases,
        Map<String, Set<String>> failedCases,
        Map<String, Id> caseNumberToIdMap
    ) {
        List<Case> casesToUpdate = new List<Case>();

        if(!successCases.isEmpty())
        {
            for (String caseNumber : successCases.keySet()) {
                casesToUpdate.add(
                new Case(
                    Id = caseNumberToIdMap.get(caseNumber),
                    Status = GetHelpConstants.ESCALATED_STATUS,
                    Sub_Status__c = 'Success',
                    Process_ID__c = successCases.get(caseNumber)
                )
                );
            }
        }
        
        if(!failedCases.isEmpty())
        {
            for (String caseNumber : failedCases.keySet()) {
                Case failedCase = new Case(
                Id = caseNumberToIdMap.get(caseNumber),
                Status = GetHelpConstants.ESCALATED_STATUS,
                Sub_Status__c = 'Failed'
                );
        
                AccountClosureActionNotifier.postFailureMessage(
                caseNumberToIdMap.get(caseNumber),
                failedCases.get(caseNumber)
                );
                casesToUpdate.add(failedCase);
            }
        }
        
        return casesToUpdate;
    }
}