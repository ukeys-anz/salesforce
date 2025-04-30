/**
 *@author CMOS
 * @since 04/2025
 * @description  ComplaintResolutionController is the controller class for ComplaintResolutionRelatedList LWC.
 */

public class ComplaintResolutionController {
    private static final ComplaintResolutionControllerRepo COMPLAINTRES_REPOSITORY = (ComplaintResolutionControllerRepo) Lib_InstanceProvider.forType(
        ComplaintResolutionControllerRepo.class);
    /** 
     * @description Controller method to call Complaint Resolution Repository class
     * @param accountId ID of the Customer
     * @return list<Case>
     */
    @AuraEnabled(cacheable= true)
    public static List<Case> getComplaintResolution(String accountId) {
        
        return COMPLAINTRES_REPOSITORY.getCustomerCases(accountId);
        
    }
    
}
