/**
 * @description This class extends the ProfileStagingHandler to provide specific handling for KYC Upgrade and Downgrade KYC QA cases.
 * @see ProfileStagingHandler
 * @author Batya Aisman Sufrin
 * @since 03/2026
 */
public with sharing class ProfileStagingHandlerKYCQA extends ProfileStagingHandler {
  private static final ProfileStagingRepository REPO = (ProfileStagingRepository) Lib_InstanceProvider.forType(
    ProfileStagingRepository.class
  );
  private static final Map<String, String> KYC_GRADE_SUFFIX = new Map<String, String>{
    'Downgrade' => '.Downgrade',
    'Upgrade' => '.Upgrade'
  };

  /**
   * @description Overridden to determine the event configuration based on the suffix in the CPU Name, which indicates whether it's a KYC Upgrade or Downgrade case.
   * The suffix is extracted from the CPU Name, and the corresponding event configuration is retrieved using the TriggeredFrom__c value combined with the suffix.
   * @param record The Customer_Profile_Updates__c record for which to get the event configuration.
   * @return The ProfileStagingEventConfig__mdt record that matches the TriggeredFrom__c value with the appropriate suffix.
   */
  protected override ProfileStagingEventConfig__mdt getEventConfig(
    Customer_Profile_Updates__c record
  ) {
    String name = record.Name;
    String lastWord = name != null
      ? name.substring(name.lastIndexOf(' ') + 1)
      : null;
    String suffix = KYC_GRADE_SUFFIX.get(lastWord) ?? '';
    return REPO.getEventConfig(record.TriggeredFrom__c + suffix);
  }
}
