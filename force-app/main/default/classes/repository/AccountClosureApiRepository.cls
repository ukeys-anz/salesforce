/**
 * @author Shivam Swaraj
 * @since December 2024
 * @description Account Closure Api Repository for all the callouts to Fabric Seal via Mulesoft and GCP
 */
public with sharing class AccountClosureApiRepository {
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
    private List<FabricSealRequestModel> generateFabricSealInputRequest(List<Case> eligibleCaseList)
    {
        List<FabricSealRequestModel> fabricSealRequestList = new List<FabricSealRequestModel>();
        for(Case eligibleCase: eligibleCaseList)
        {
            FabricSealRequestModel fabSealInput = new FabricSealRequestModel();
            fabSealInput.account = 'accounts/' + eligibleCase.FinServ__FinancialAccount__r?.FinServ__FinancialAccountNumber__c;
            fabSealInput.salesforceCaseNumber = eligibleCase.CaseNumber;
            FabricSealRequestModel.ForwardingAccount forwardingAccDetails = new FabricSealRequestModel.ForwardingAccount();
            forwardingAccDetails.accountNumber = eligibleCase?.Intended_Account_Number__c;
            forwardingAccDetails.accountName = eligibleCase?.Intended_Account_Name__c;
            forwardingAccDetails.bsb = eligibleCase?.Intended_Account_BSB__c;
            fabSealInput.forwardingAccount = forwardingAccDetails;
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
}