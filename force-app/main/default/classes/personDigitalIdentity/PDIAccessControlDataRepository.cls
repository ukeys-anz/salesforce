/**
 * @description This class is responsible for querying and mapping accessController data
 *              from the PDIApiRepository to the required format.
 * @author Tan Phan
 * @since 04/2025
 * @group Person Digital Entity
 */
public with sharing class PDIAccessControlDataRepository extends PDIDataConnection.DataRepositoryBase {
  private static final PDIRepository QUERY = (PDIRepository) Lib_InstanceProvider.forType(
    PDIRepository.class
  );

  private static final PDIApiRepository REPO = (PDIApiRepository) Lib_InstanceProvider.forType(
    PDIApiRepository.class
  );

  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );

  static final Map<String, String> MAPPER_CHANNEL_IN = new Map<String, String>{
    'EDGE_AUTH_CHANNEL_COMPANION' => 'Web Banking',
    'EDGE_AUTH_CHANNEL_PRIMARY' => 'Primary Device'
  };
  static final Map<String, String> MAPPER_CHANNEL_OUT = PDIHelper.flipMap(
    MAPPER_CHANNEL_IN
  );
  static final Map<String, String> MAPPER_POLICY_IN = new Map<String, String>{
    'POLICY_DENY' => 'Deny',
    'POLICY_CONDITIONAL' => 'Conditional'
  };
  static final Map<String, String> MAPPER_POLICY_OUT = PDIHelper.flipMap(
    MAPPER_POLICY_IN
  );

  @TestVisible
  protected override List<CalloutModel> doQuery(
    DataSource.QueryContext context
  ) {
    String uuid = PDIHelper.getCustomerUuid(context.tableSelection.filter);
    return REPO.getAccessControls(uuid, null);
  }

  @TestVisible
  protected override void doDelete(String externalId) {
    AccessControl__x record = QUERY.getAccessControlByExternalId(externalId);
    if (canDelete(record) == false) {
      return;
    }
    String customerUuid = PDIHelper.parseResourcePath(externalId, 'person');
    REPO.deleteAccessControl(customerUuid, externalId);
  }

  @TestVisible
  private static Boolean canDelete(AccessControl__x record) {
    if (record == null) {
      return false;
    }
    if (record.DeviceCorrelationId__c == null) {
      return true;
    }
    if (USER_INFO.checkRole('Join_Lead')) {
      return true;
    }
    throw new RepositoryBase.InsufficientAccessException(
      'You do not have permission to delete this access control.'
    );
  }

  @TestVisible
  protected override String doUpsert(Map<String, Object> row) {
    String customerUuid = (String) row.get('PersonId');
    PDIApiModel.AccessControl accessControl = new PDIApiModel.AccessControl();
    accessControl.name = (String) row.get('ExternalId');
    accessControl.policy = MAPPER_POLICY_OUT.get((String) row.get('Policy'));
    accessControl.match = new PDIApiModel.AccessControlMatchCriteria();
    accessControl.match.authChannel = MAPPER_CHANNEL_OUT.get(
      (String) row.get('Channel')
    );
    accessControl.match.personaId = (String) row.get('PersonaId');
    if (accessControl.policy == 'POLICY_CONDITIONAL') {
      accessControl.conditionalAdvice = new PDIApiModel.AccessControlConditionalAdvice();
      accessControl.conditionalAdvice.deleteWhenMet = (Boolean) row.get(
        'DeleteWhenMet'
      );
      accessControl.conditionalAdvice.minimumAal = (String) row.get(
        'MinimumAAL'
      );
    }

    PDIApiModel.AccessControl createdAccessControl = REPO.createAccessControl(
      customerUuid,
      accessControl
    );

    return createdAccessControl.name;
  }

  @TestVisible
  protected override virtual List<Map<String, Object>> transform(
    List<CalloutModel> records
  ) {
    List<Map<String, Object>> mappedRecords = super.transform(records);
    if (isDeviceLinkingRequired(mappedRecords) == false) {
      return mappedRecords;
    }
    String personId = (String) mappedRecords[0].get('PersonId');
    List<Device__x> devices = QUERY.getDevicesByPersonId(personId);
    linkDevices(mappedRecords, devices);
    return mappedRecords;
  }

  @TestVisible
  private static void linkDevices(
    List<Map<String, Object>> records,
    List<Device__x> devices
  ) {
    Map<String, Device__x> deviceByCorrelationId = (Map<String, Device__x>) ListUtil.mapBy(
      devices,
      Device__x.DeviceCorrelationId__c
    );
    for (Map<String, Object> record : records) {
      String dci = (String) record.get('DeviceCorrelationId');
      Device__x device = deviceByCorrelationId.get(dci);
      if (device == null) {
        continue;
      }
      record.put('Device', device.ExternalId);
    }
  }

  @TestVisible
  private static Boolean isDeviceLinkingRequired(
    List<Map<String, Object>> records
  ) {
    for (Map<String, Object> record : records) {
      if (record.get('DeviceCorrelationId') != null) {
        return true;
      }
    }
    return false;
  }

  @TestVisible
  protected override Map<String, Object> transform(CalloutModel apiRecord) {
    if ((apiRecord instanceof PDIApiModel.AccessControl) == false) {
      return null;
    }
    PDIApiModel.AccessControl record = (PDIApiModel.AccessControl) apiRecord;
    String authChannel = record.match?.authChannel;
    String channel = MAPPER_CHANNEL_IN.get(authChannel) ?? authChannel;
    String policy = MAPPER_POLICY_IN.get(record.policy) ?? record.policy;
    return new Map<String, Object>{
      'Name' => TextUtils.concat(new List<String>{ channel, policy }, ' - '),
      'Channel' => channel,
      'CreatedBy' => record.createdBy,
      'CreatedTime' => record.createdAt,
      'DeleteWhenMet' => record.conditionalAdvice?.deleteWhenMet,
      'DeviceCorrelationId' => record.match?.deviceCorrelationId,
      'ExternalId' => record.name,
      'MinimumAAL' => record.conditionalAdvice?.minimumAal,
      'PersonId' => PDIHelper.parseResourcePath(record.name, 'person'),
      'PersonaId' => record.match?.personaId,
      'Policy' => policy
    };
  }
}
