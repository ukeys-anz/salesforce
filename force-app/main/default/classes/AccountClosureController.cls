/**
 * @author Shivam Swaraj
 * @since December 2024
 * @description Account Closure Controller for Account Closure Prechecks (Fabric Seal Callout)
 */
public with sharing class AccountClosureController {

    private static final AccountClosureRepository ACCOUNT_CLOSURE_REPOSITORY = (AccountClosureRepository) Lib_InstanceProvider.forType(
        AccountClosureRepository.class
        );
    
    private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
        DmlRepository.class
        );
    private static final String ESCALATED = 'Escalated';
    
    /**
     * @description Fetch Eligible Cases for Fabric Seal Precheck
     * @param parentCaseId Input Date from LWC
     * @return List<Case> eligible case list 
     */
    @AuraEnabled(cacheable=true)
    public static List<Case> fetchEligibleCasesForPrecheck(Id parentCaseId){
        try {
            return ACCOUNT_CLOSURE_REPOSITORY.queryEligibleChildCaseRecords(new Set<Id> {parentCaseId});
        } catch (Exception objException) {
            throw CommonUtil.logException(objException);
        }
    }

   /**
     * @description Initiate Account Closure Prechecks by making callout to Fabric Seal and perform after actions based on response for each case
     * @param parentCaseId Parent Case Id for which Precheck Initiated
     * @param eligibleCasesForPrecheck Cases to be sent to Fabric Seal for Precheck
     * @return List<FabricSealResponseModel> fabric seal response for each case
     */
    @AuraEnabled
    public static List<Case> initiateAccountClosurePrecheck(Id parentCaseId, List<Case> eligibleCasesForPrecheck){
        Case parentCaseRecord = ACCOUNT_CLOSURE_REPOSITORY.queryCaseDetails(parentCaseId);
        try { 
            AccountClosureApiRepository fabricSealApi = new AccountClosureApiRepository();
            List<FabricSealResponseModel> fabricSealResponse = fabricSealApi.initiateAccountClosurePreChecks(
            parentCaseRecord.Account.OCV_ID__c,
            eligibleCasesForPrecheck);
    
            //Process Response
            Map<String,String> successCases = new Map<String,String>(); 
            Map<String, Set<String>> failedCases = new Map<String, Set<String>>(); 
            processResponses(fabricSealResponse, successCases, failedCases);
    
            //Preparing Cases for update
            Map<String,Id> caseNumberToIdMap = createCaseNumberToIdMap(eligibleCasesForPrecheck); 
            List<Case> casesToUpdate = prepareCasesForUpdate(successCases, failedCases, caseNumberToIdMap);

            if(!casesToUpdate.isEmpty())
            {
                DML_REPOSITORY.doUpdate(casesToUpdate);
            }

            return ACCOUNT_CLOSURE_REPOSITORY.queryChildCasesDetailsPostPrecheck(new Map<Id,Case>(casesToUpdate));
        } 
        catch (Exception objException) {
            throw CommonUtil.logException(objException);
        }  
    }

    /**
    * @description method to process response and segregrate success and failure cases
    * @param fabricSealResponse response received from fabric seal api
    * @param successCases pass by reference to store success cases
    * @param failedCases pass by reference to store failure cases
    */
    private static void processResponses(List<FabricSealResponseModel> fabricSealResponse, Map<String, String> successCases, Map<String, Set<String>> failedCases)
    {
        for(FabricSealResponseModel response : fabricSealResponse)
        {
            if(response?.acceptance == 'ACCEPTANCE_ACCEPTED')
            {
                successCases.put(response.salesforceCaseNumber, response.businessProcessId);
            }
            else if(response?.acceptance == 'ACCEPTANCE_REJECTED')
            {
                Set<String> failedReasons = createFailedReasonsSet(response.unsatisfiedPreconditions);
                if(!failedReasons.isEmpty())
                {
                    failedCases.put(response.salesforceCaseNumber,failedReasons);
                }
            }
            else if(response?.acceptance == NULL && response?.message != NULL)
            {
                failedCases.put(response.salesforceCaseNumber,new Set<String> {'techError'});
            }
        }
    }

    /**
     * @description method to create set of failed reasons whose eligibility is ineligible
    * @param reasons instance of FabricSealResponseModel.UnsatisfiedPreconditions
    * @return Set<String> set of reasons which are ineligible
    */
    private static Set<String> createFailedReasonsSet(FabricSealResponseModel.UnsatisfiedPreconditions reasons){
        Set<String> failedReasons = new Set<String>();
        if (reasons == null)
        {
            return failedReasons;
        }

        Map<String, Object> failedReasonsMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(reasons));

        for(String reason : failedReasonsMap.keySet())
        {
            Object reasonValue = failedReasonsMap.get(reason);
            if(reasonValue instanceof Map<String, Object>)
            {
                Map<String, Object> reasonDetails = (Map<String, Object>) reasonValue;
                if((String)reasonDetails.get('eligibility') == 'ELIGIBILITY_INELIGIBLE')
                {
                    failedReasons.add(reason);
                }
            }
        }
        return failedReasons;
    }

    /**
     * @description method to create set of failed reasons whose eligibility is ineligible
    * @param cases List of Eligible Cases for Precheck
    * @return Map<String, Id> map of case number and case id
    */
    private static Map<String, Id> createCaseNumberToIdMap(List<Case> cases)
    {
        Map<String, Id> caseNumberToIdMap = new Map<String, Id>();
        for(Case caseRec : cases)
        {
            caseNumberToIdMap.put(caseRec.CaseNumber, caseRec.Id);
        }
        return caseNumberToIdMap;
    }

    /**
    * @description method to prepare list of cases to update
    * @param successCases map of successfull cases and their business process id
    * @param failedCases map of failed cases and their failed reasons
    * @param caseNumberToIdMap map of case number and case id
    * @return List of cases to be updated
    */
    private static List<Case> prepareCasesForUpdate(
        Map<String, String> successCases,
        Map<String, Set<String>> failedCases,
        Map<String, Id> caseNumberToIdMap)
    {
        List<Case> casesToUpdate = new List<Case>();

        for(String caseNumber : successCases.keySet())
        {
            casesToUpdate.add(new Case (
                Id = caseNumberToIdMap.get(caseNumber),
                Status = ESCALATED,
                Sub_Status__c = 'Success',
                Process_ID__c = successCases.get(caseNumber)
            ));
        }

        for(String caseNumber : failedCases.keySet())
        {
        Case failedCase = new Case (
            Id = caseNumberToIdMap.get(caseNumber),
            Status = ESCALATED,
            Sub_Status__c = 'Failed'
        );
            
        AccountClosureActionNotifier.postFailureMessage(caseNumberToIdMap.get(caseNumber),failedCases.get(caseNumber));

        casesToUpdate.add(failedCase);
        }
        return casesToUpdate;
    }

    /**
    * @description Queries all the related cases (child cases) to the parent case having status as Escalated and Substatus as Success
    * @param parentCaseId set of Case Group (Parent Case) Id
    * @return List<Case> List of child cases associated to the parent case.
    */
    @AuraEnabled(cacheable=true)
    public static List<Case> fetchChildCasesForClosure(Id parentCaseId){
        try {
            Set<Id> parentCaseIds = new Set<Id>();
            parentCaseIds.add(parentCaseId);
            return ACCOUNT_CLOSURE_REPOSITORY.queryChildCasesForClosure(parentCaseIds);
        }
        catch (Exception objException) {
            throw CommonUtil.logException(objException);
        }   
    }
}