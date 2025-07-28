/**
 * @author Ayushi Gupta
 * @since  07/2025
 * @description Controller class of acceptReferral LWC
 */
public with sharing class AcceptReferralController {
  private static final AcceptReferralRepository ACCEPTREFERRAL_REPO = (AcceptReferralRepository) Lib_InstanceProvider.forType(
    AcceptReferralRepository.class
  );

  /**
   * @description This method is for checking campign member if it exists otherwise, it creates a new one.
   * @param leadId leadId
   */
  @AuraEnabled
  public static void checkCampaignMember(Id leadId) {
    List<CampaignMember> members = ACCEPTREFERRAL_REPO.getCampaignMember(
      leadId
    );
    if (members.size() > 0) {
      return;
    }
    Lead leadRec = ACCEPTREFERRAL_REPO.getLeadRecord(leadId);
    try {
      LeadManagementActions.createCampaignMember(new List<Lead>{ leadRec });
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error in creating campaign member for the lead.'
      );
    }
  }
}
