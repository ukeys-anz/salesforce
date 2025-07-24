/**
 * @description This class is responsible for querying and mapping accessController data
 *              from the PDIApiRepository to the required format.
 * @author Tan Phan
 * @since 04/2025
 * @group Person Digital Entity
 */
public with sharing class PDIAccessControlDataRepository extends PDIDataConnection.DataRepositoryBase {
  private static final PDIApiRepository REPO = (PDIApiRepository) Lib_InstanceProvider.forType(
    PDIApiRepository.class
  );

  @TestVisible
  protected override List<CalloutModel> doQuery(
    DataSource.QueryContext context
  ) {
    return REPO.getAccessControls(
      PDIHelper.getCustomerUuid(context.tableSelection.filter),
      null
    );
  }

  @TestVisible
  protected override void doDelete(String externalId) {
    String customerUuid = PDIHelper.parseResourcePath(externalId, 'person');
    REPO.deleteAccessControl(customerUuid, externalId);
  }

  @TestVisible
  protected override String doUpsert(Map<String, Object> row) {
    String customerUuid = (String) row.get('PersonId');
    PDIApiModel.AccessControl accessControl = new PDIApiModel.AccessControl();
    accessControl.name = (String) row.get('ExternalId');
    accessControl.policy = (String) row.get('Policy');
    accessControl.match = new PDIApiModel.AccessControlMatchCriteria();
    accessControl.match.authChannel = (String) row.get('Channel');
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
  protected override Map<String, Object> transform(CalloutModel apiRecord) {
    if ((apiRecord instanceof PDIApiModel.AccessControl) == false) {
      return null;
    }
    PDIApiModel.AccessControl record = (PDIApiModel.AccessControl) apiRecord;
    Map<String, String> channelLabels = CommonUtil.getPicklistLabelsByValues(
      AccessControl__x.Channel__c
    );
    Map<String, String> policyLabels = CommonUtil.getPicklistLabelsByValues(
      AccessControl__x.Policy__c
    );
    String authChannel = record.match?.authChannel;
    return new Map<String, Object>{
      'Name' => TextUtils.concat(
        new List<String>{
          channelLabels.get(authChannel) ?? authChannel,
          policyLabels.get(record.policy) ?? record.policy
        },
        ' - '
      ),
      'Channel' => authChannel,
      'CreatedBy' => record.createdBy,
      'CreatedTime' => record.createdAt,
      'DeleteWhenMet' => record.conditionalAdvice?.deleteWhenMet,
      'ExternalId' => record.name,
      'MinimumAAL' => record.conditionalAdvice?.minimumAal,
      'PersonId' => PDIHelper.parseResourcePath(record.name, 'person'),
      'PersonaId' => record.match?.personaId,
      'Policy' => record.policy
    };
  }
}
