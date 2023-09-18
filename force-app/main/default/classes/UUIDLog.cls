/**
 * @author cruzb
 * @since July 2023
 * @description object class for UUID Logs
 * @group Services
 */
public with sharing class UUIDLog {
  /**
   * @description uuid
   */
  public String uuid { get; set; }

  /**
   * @description exists flag
   */
  private Boolean exists { get; set; }

  /**
   * @description hashPayload
   */
  private String hashPayload { get; set; }

  /**
   * @param payload payload to hash
   * @description constructor
   */
  public UUIDLog(String payload) {
    this.hashPayload = CommonUtil.hashValue(payload);

    if (!PermissionUtils.canQuery('UUID_Log_Entry__c')) {
      throw new AuraHandledException('Insufficient Permissions');
    }

    UUID_Log_Entry__c[] uuid = [
      SELECT UUID__c
      FROM UUID_Log_Entry__c
      WHERE
        Hash_Payload__c = :this.hashPayload
        AND Status__c = :GetHelpConstants.IN_PROGRESS_STATUS
    ];
    if (uuid.size() > 0) {
      this.uuid = uuid[0].UUID__c;
      this.exists = true;
    } else {
      this.uuid = CommonUtil.generateUUID();
      this.exists = false;
    }
  }

  /**
   * @param recordId for reference
   * @param caseType for case record type
   * @description creates a UUID log record
   */
  public void insertUUID(String recordId, String caseType) {
    if (this.exists) {
      return;
    }
    try {
      PlatformEventUtils.publishEvents(
        new List<UUID_Log_Event__e>{
          new UUID_Log_Event__e(
            Status__c = GetHelpConstants.IN_PROGRESS_STATUS,
            UUID__c = this.uuid,
            Hash_Payload__c = this.hashPayload,
            Reference_Id__c = recordId,
            Type__c = caseType
          )
        }
      );
    } catch (Exception e) {
      Logger.error('Error creating UUID Log Entry: ' + e.getMessage());
      Logger.saveLog();
      throw e;
    }
  }

  /**
   * @param payload payload to attach UUID to
   * @description attach uuid in payload
   * @return serialized string
   */
  public String attachUUID(String payload) {
    Map<String, Object> objectMap = (Map<String, Object>) JSON.deserializeUntyped(
      payload
    );

    objectMap.put('requestId', this.uuid);

    return JSON.serialize(objectMap);
  }
}
