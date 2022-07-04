/**
 * @description Class to provide access to Automated Request Metadata
 * @author Adam smith
 * @since 20220324
 */
public with sharing class AutomatedRequestMetadataProvider {
  private static AutomatedRequestMetadataProvider instance;
  private Map<String, Automated_Request_Purpose__mdt> metadataMap;

  /**
   * @description private constructor for this singleton
   */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  private AutomatedRequestMetadataProvider() {
    //need to declare to make the constructor private.
    //but declaring the constructor makes PMD demand a non-empty constructor
  }

  /**
   * @description gets the instance of this singleton
   * @return AutomatedRequestMetadataProvider gets an instance of this class.
   */
  public static AutomatedRequestMetadataProvider getInstance() {
    if (instance == null) {
      instance = new AutomatedRequestMetadataProvider();
    }
    return instance;
  }

  /**
   * @description sets the map of Automated Request Purpose
   * @param incomingMetadataMap Map<String, Automated_Request_Purpose_mdt> the map to be set.
   */
  public void setMap(
    Map<String, Automated_Request_Purpose__mdt> incomingMetadataMap
  ) {
    metadataMap = incomingMetadataMap;
  }

  /**
   * @description returns the current Map or queries the database for the Automated
   * request purpose.
   * @return Map<String, Automated_Request_Purpose__mdt> gets the currently set map
   */
  public Map<String, Automated_Request_Purpose__mdt> getMap() {
    if (metadataMap == null) {
      metadataMap = new Map<String, Automated_Request_Purpose__mdt>();
      if (
        Automated_Request_Purpose__mdt.sObjectType.getDescribe().isQueryable()
      ) {
        List<Automated_Request_Purpose__mdt> automatedPurposes = [
          SELECT Id, MasterLabel, Duration__c
          FROM Automated_Request_Purpose__mdt
        ];
        for (Automated_Request_Purpose__mdt purpose : automatedPurposes) {
          metadataMap.put(purpose.MasterLabel, purpose);
        }
      } else {
        CommonUtil.logAndThrowIAE(
          'AutomatedRequestMetadataProvider',
          'getMap',
          'Not enough permissions to query Automated_Request_Purpose__mdt.'
        );
      }
    }
    return metadataMap;
  }

  /**
   * @description gets the duration for a specified purpose
   * @param purpose String the purpose for which to search
   * @return Integer The duration for the purpose
   */
  public Integer getPurposeDuration(string purpose) {
    if (getMap().containsKey(purpose) == null) {
      return 0;
    }
    Automated_Request_Purpose__mdt purposeMetadata = getMap().get(purpose);
    if (null == purposeMetadata || null == purposeMetadata.Duration__c) {
      return 0;
    }
    return Math.round(purposeMetadata.Duration__c);
  }
}
