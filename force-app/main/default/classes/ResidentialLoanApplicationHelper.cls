/**
 * @description helper class for Residential Loan Application
 * @author @fangl6
 * @since 24/06/2024
 */
public with sharing class ResidentialLoanApplicationHelper {
  private static final ResidentialLoanApplicationRepository LOAN_APPLICATION_REPOSITORY = (ResidentialLoanApplicationRepository) Lib_InstanceProvider.forType(
    ResidentialLoanApplicationRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description overwrite property address and value from sop with SF property record values
   * @param loanId residential loan application id
   * @param assets list of assets in SOP data
   * @return  `List<SOPAsset>` list of assets with updated property data
   */
  public static List<SOPAsset> overwritePropertyAssetData(
    Id loanId,
    List<SOPAsset> assets
  ) {
    Map<String, SOPAsset> propertyIdMap = getPropertyIdMap(assets);
    List<LoanApplicationProperty> properties = LOAN_APPLICATION_REPOSITORY.queryRelatedProperties(
      loanId,
      propertyIdMap.keySet()
    );
    if (properties.isEmpty()) {
      return assets;
    }
    List<SOPAsset> updatedAssets = updateTheAssets(properties, assets);
    return updatedAssets;
  }
  /**
   * @description put the property asset into map with property id as key
   * @param assets list of assets in SOP data
   * @return  `Map<Id, SOPAsset>` property id map
   */
  public static Map<String, SOPAsset> getPropertyIdMap(List<SOPAsset> assets) {
    Map<String, SOPAsset> propertyIdMap = new Map<String, SOPAsset>();
    for (SOPAsset asset : assets) {
      if (asset.type != 'ASSET_TYPE_PROPERTY') {
        continue;
      }
      propertyIdMap.put(asset.propertyId, asset);
    }
    return propertyIdMap;
  }
  /**
   * @description
   * @param properties update the property address and  property value for property assets with salesforce data
   * @param assets original list of Assets from sop
   * @return  `List<SOPAsset>` updated assets
   */
  public static List<SOPAsset> updateTheAssets(
    List<LoanApplicationProperty> properties,
    List<SOPAsset> assets
  ) {
    Map<String, LoanApplicationProperty> propertyMap = new Map<String, LoanApplicationProperty>();
    for (LoanApplicationProperty lap : properties) {
      propertyMap.put(lap.Property_ID__c, lap);
    }

    for (SOPAsset asset : assets) {
      if (asset.type == 'ASSET_TYPE_PROPERTY') {
        asset.propertyAddress = propertyMap.get(asset.propertyId).Name;
        asset.propertyValue = propertyMap.get(asset.propertyId).PropertyValue;
      }
    }
    return assets;
  }

  /**
   * @description update fields on residential loan application cancellation
   * @param fieldInfo map of fields to update
   * @return `loanApplication` Residential Loan Application
   */
  public static ResidentialLoanApplication updateFieldsOnLoanCancellation(
    Map<String, String> fieldInfo
  ) {
    ResidentialLoanApplication loanApplication = new ResidentialLoanApplication();
    loanApplication.Id = fieldInfo.get('recordId');
    loanApplication.Cancellation_Reason__c = fieldInfo.get(
      'Cancellation_Reason__c'
    );
    loanApplication.Other_Cancellation_Reason__c = fieldInfo.get(
      'Other_Cancellation_Reason__c'
    );
    return loanApplication;
  }

  /**
   * @description postNotesToChatter post notes to chatter
   * @param fieldInfo map of fields to update
   * @return `postContent` Chatter post content
   */
  public static String postNotesToChatter(Map<String, String> fieldInfo) {
    String postContent =
      '<p><b>Subject: </b> Application Withdrawn</p>' +
      '<p><b>Reason: </b>' +
      fieldInfo.get('Cancellation_Reason__c') +
      '</p>' +
      '<p><b>Other Reason: </b>' +
      fieldInfo.get('Other_Cancellation_Reason__c') +
      '</p>' +
      '<p><b>Notes: </b>' +
      fieldInfo.get('Notes') +
      '</p>';
    if (String.isBlank(fieldInfo.get('Other_Cancellation_Reason__c'))) {
      postContent = postContent.replace('<p><b>Other Reason: </b>null</p>', '');
    }
    if (String.isBlank(fieldInfo.get('Notes'))) {
      postContent = postContent.replace('<p><b>Notes: </b>null</p>', '');
    }
    return postContent;
  }

  /**
   * @description postNotesToChatterWhenCancelled post notes to chatter when RLA status changed to Cancelled
   * @param oldStatus oldStatus previous status of RLA
   * @return Chatter post content
   */
  public static String postNotesToChatterWhenCancelled(String oldStatus) {
    String status = CommonUtil.getSinglePicklistLabel(
      ResidentialLoanApplication.Status,
      oldStatus
    );
    return 'Application Status updated' +
      '<p><b>Status: </b>' +
      status +
      ' to Cancelled</p>';
  }
}
