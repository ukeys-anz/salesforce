/**
 * @description Builds the Cloud Event payload (ce_data) for ApplicationForm records.
 *              This builder transforms ApplicationForm and Account data into the
 *              structured BrokerCloudEventDataModel format, ready for event publishing.
 * @author      Akanksha Kulkarni
 * @date        2025-11-10
 */
public class ApplicationFormEventBuilder extends BrokerCloudEventModel {
  /**
   * @description Builds the Cloud Event payload (ce_data) for one or more ApplicationForms.
   *              For each ApplicationForm, this method constructs two nodes:
   *              1. The Account node linking to the ApplicationForm.
   *              2. The ApplicationForm node linking back to the related Account.
   *
   * @param applicationForms The list of ApplicationForm records to include in the payload.
   * @param accountIdAndExternalId A map of Account IDs to their corresponding External_Id__c values.
   * @return A BrokerCloudEventDataModel containing the structured event data for publishing.
   */
  public static BrokerCloudEventDataModel buildApplicationFormPayload(
    List<ApplicationForm> applicationForms,
    Map<Id, String> accountIdAndExternalId
  ) {
    List<MasterNode> masterNodes = new List<MasterNode>();

    for (ApplicationForm app : applicationForms) {
      // --- 1. Account Node ---
      Map<String, String> accountNodeMap = new Map<String, String>{
        'sourceObjectName' => 'ApplicationForm',
        'sourceObjectExtId' => app.Source_System_Id__c,
        'targetObjects_extObjectName' => 'Account',
        'targetObjects_extIdField' => 'External_Id__c'
      };
      masterNodes.add(BrokerCloudEventModel.buildMasterNode(accountNodeMap));
      Id accountRecId = app.Opportunity?.AccountId != null
        ? app.Opportunity.AccountId
        : app.AccountId;
      // --- 2. ApplicationForm → Account Node ---
      Map<String, String> appNodeMap = new Map<String, String>{
        'sourceObjectName' => 'ApplicationForm',
        'sourceObjectExtId' => app.Source_System_Id__c,
        'targetObjects_extObjectName' => 'ApplicationForm',
        'targetObjects_extIdField' => 'ApplicationForm.Source_System_Id__c',
        'targetObjects_parent_referenceField' => 'Account',
        'targetObjects_parent_objectName' => 'Account',
        'targetObjects_parent_extIdField' => 'External_Id__c',
        'targetObjects_parent_extId' => accountIdAndExternalId.get(accountRecId)
      };
      masterNodes.add(BrokerCloudEventModel.buildMasterNode(appNodeMap));
    }

    // --- 3. Build final ce_data wrapper ---
    BrokerCloudEventDataModel ceData = new BrokerCloudEventDataModel(
      masterNodes
    );
    return ceData;
  }
}
