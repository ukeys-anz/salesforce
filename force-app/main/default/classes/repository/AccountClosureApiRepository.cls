/**
 * @author Shivam Swaraj
 * @since December 2024
 * @description Account Closure Api Repository for all the callouts to Fabric Seal via Mulesoft and GCP
 */
public with sharing class AccountClosureApiRepository {

    private static final String REQUIRED_FIELDS_MISSING_ERROR = 'Parent Case And Eligible Cases Required';

    /**
     * @param ocvId ocvId of the customer
     * @param eligibleCaseList card number to be detokenzed
     * @return List<FabricSealResponseModel> fabric seal responses for each cases
     * @description initiate Fabric Seal Prechecks for eligible cases
     */
    public List<FabricSealResponseModel> initiateAccountClosurePreChecks(
    String ocvId,
    List<Case> eligibleCaseList
    ) {
        if(ocvId == null || eligibleCaseList.isEmpty())
        {
          throw CommonUtil.logException(
            new RequiredFieldMissingException(
              REQUIRED_FIELDS_MISSING_ERROR
            )
          );
        }
        AccountClosureService serviceInstance = (AccountClosureService) ServiceProvider.getService(
            AccountClosureService.class
        );
        List<FabricSealRequestModel> contextReq = generateFabricSealInputRequest(eligibleCaseList);
        
        HttpCalloutResponse response = serviceInstance.initiateAccountClosurePreChecks(
            ocvId,
            contextReq
        );

        if (!response.successful) {
            throw CommonUtil.logException(response);
        }

        return FabricSealResponseModel.parse(response.body);
    }


    /**
     * @description Generate Json Request to be sent to Mulesoft
     * @param eligibleCaseList contains list of eligible cases for sending to Fabric Seal for prechecks
     * @return FabricSealRequestModel to be sent to Mulesoft
     */
    @testVisible
    private List<FabricSealRequestModel> generateFabricSealInputRequest(List<Case> eligibleCaseList)
    {
        List<FabricSealRequestModel> fabricSealRequestList = new List<FabricSealRequestModel>();
        for(Case eligibleCase: eligibleCaseList)
        {
            FabricSealRequestModel fabSealInput = new FabricSealRequestModel(
                'accounts/' + (eligibleCase.FinServ__FinancialAccount__r?.FinServ__FinancialAccountNumber__c ?? ''),
                eligibleCase.CaseNumber,
                new FabricSealRequestModel.ForwardingAccount(
                    eligibleCase?.Intended_Account_Number__c ?? '',
                    eligibleCase?.Intended_Account_Name__c ?? '',
                    eligibleCase?.Intended_Account_BSB__c ?? ''
                )
            );
            fabricSealRequestList.add(fabSealInput);
        }

        return fabricSealRequestList;

    }

    /**
     * @author Shivam Swaraj
     * @since December 2024
     * @description no failed reason record found in the metadata for provided failed reason
     */
    public class NoFailedReasonFoundException extends Exception {
    }

    /**
     * @author Shivam Swaraj
     * @since December 2024
     * @description no eligible cases found
     */
    public class NoEligibleCasesFoundException extends Exception {
    }

       /**
     * @author Shivam Swaraj
     * @since December 2024
     * @description required field missing excpetion
     */
    public class RequiredFieldMissingException extends Exception {
    }
}