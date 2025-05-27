/**
 *@author CMOS
 * @since 04/2025
 * @description  ComplaintResolutionController is the controller class for ComplaintResolutionRelatedList LWC.
 */

public with sharing class ComplaintResolutionController {
    
    private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
    );
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
    
    /**
     * @description Controller method to check if User has IDR Data Analyst Permissions
     * @return Boolean
     */
    @AuraEnabled(cacheable= true)
    public static Boolean hasPermissionSet() {
        
        return USER_INFO.checkPermission('IDR_Data_Analyst');
    }
    
}