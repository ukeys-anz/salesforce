/**
 * @author Hrushikesh
 * @since 10/2024
 * @description DisputesCaseActions class is to handle all the actions related to disputes
 */
public with sharing class DisputesCaseActions {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Create a External Case Status when dispute is inserted.
   * @param records List of Case records from Trigger.new
   * @param statusMappingMetadataDevName metadat record dev name
   */
  public static void createExternalCaseStatuses(
    List<Case> records,
    String statusMappingMetadataDevName
  ) {
    List<External_Case_Status__c> externalCaseStatuses = new List<External_Case_Status__c>();

    External_Case_Status_Mapping__mdt statusMappingMetadata = External_Case_Status_Mapping__mdt.getInstance(
      statusMappingMetadataDevName
    );

    for (Case record : records) {
      External_Case_Status__c externalCaseStatus = GetHelpCaseActions.populateExternalCaseStatuses(
        record,
        statusMappingMetadata
      );
      externalCaseStatuses.add(externalCaseStatus);
    }

    DML_REPOSITORY.doInsert(externalCaseStatuses, new DmlConfig().systemMode());
  }
}
