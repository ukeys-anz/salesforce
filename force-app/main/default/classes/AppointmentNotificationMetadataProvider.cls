/**
 * @description Class to provide access to Appointment Notification Metadata
 * @author Adam smith
 * @since 20220516
 */
public with sharing class AppointmentNotificationMetadataProvider {
  private static AppointmentNotificationMetadataProvider instance;
  private Map<String, Appointment_Notification_Template__mdt> metadataMap;

  /**
   * @description private constructor for this singleton
   */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  private AppointmentNotificationMetadataProvider() {
    //need to declare to make the constructor private.
    //but declaring the constructor makes PMD demand a non-empty constructor
  }

  /**
   * @description gets the instance of this singleton
   * @return AppointmentNotificationMetadataProvider gets an instance of this class.
   */
  public static AppointmentNotificationMetadataProvider getInstance() {
    if (instance == null) {
      instance = new AppointmentNotificationMetadataProvider();
    }
    return instance;
  }

  /**
   * @description sets the map of Automated Request Purpose
   * @param incomingMetadataMap Map<String, Automated_Request_Purpose_mdt> the map to be set.
   */
  public void setMap(
    Map<String, Appointment_Notification_Template__mdt> incomingMetadataMap
  ) {
    metadataMap = incomingMetadataMap;
  }

  /**
   * @description returns the current Map or queries the database for metadata
   * @return Map<String, Automated_Request_Purpose__mdt> gets the currently set map
   */
  public Map<String, Appointment_Notification_Template__mdt> getMap() {
    if (metadataMap == null) {
      metadataMap = new Map<String, Appointment_Notification_Template__mdt>();
      if (
        Appointment_Notification_Template__mdt.sObjectType.getDescribe()
          .isQueryable()
      ) {
        List<Appointment_Notification_Template__mdt> metadataList = [
          SELECT Id, MasterLabel, Template_Id__c
          FROM Appointment_Notification_Template__mdt
          LIMIT 500
        ];
        for (
          Appointment_Notification_Template__mdt currentMetadata : metadataList
        ) {
          metadataMap.put(currentMetadata.MasterLabel, currentMetadata);
        }
      } else {
        CommonUtil.logAndThrowIAE(
          'AppointmentNotificationMetadataProvider',
          'getMap',
          'Not enough permissions to query Appointment_Notification_Template__mdt.'
        );
      }
    }
    return metadataMap;
  }

  /**
   * @description gets the notification template Id based upon name provided
   * @param templateName Name of the template to retrieve
   * @return String of template Id
   */
  public String getNotificationTemplateId(String templateName) {
    return this.getMap().get(templateName).Template_Id__c;
  }
}
