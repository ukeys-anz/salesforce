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
    private static final ComplaintsRepository COMPLAINTS_REPOSITORY = (ComplaintsRepository) Lib_InstanceProvider.forType(
        ComplaintsRepository.class
    );
    private static final String COMPLAINTS_MANAGEMENT_APP = 'Complaint Mgt';

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

    /**
     * @description Controller method to check if User is currently using CMOS Application in Repository method
     * @return Boolean
     */
    @AuraEnabled(cacheable= true)
    public static Boolean loggedInApplication() {

        UserAppInfo userAppInfo = COMPLAINTS_REPOSITORY.getUserAppInfoForUser(UserInfo.getUserId());
        AppDefinition appDefinition = QueryAppDefinition.getByDurableId(
          userAppInfo?.AppDefinitionId);
          if (appDefinition?.Label == COMPLAINTS_MANAGEMENT_APP) {
          return true;
        }
        return false;
  }
    
}