/**
 * @author Deepro De
 * @since 05/2024
 * @description class for Residential Loan Application GCP actions
 * @runTests ResidentialLoanApplicationGCPActionsTest
 */
public with sharing class ResidentialLoanApplicationGCPActions {
  public static final String GCP_EVENT_ADD = 'add';
  public static final String GCP_EVENT_UPDATE = 'update';

  /**
   * @description Creating Cloud Event Model structure which is subsequently passed into the publishing method from the caller method
   * @author Deepro De | 06-04-2024
   * @param loanAppList
   * @param triggerContext
   * @return List<BrokerCloudEventModel>
   **/
  public static List<BrokerCloudEventModel> createCloudEventModels(
    List<ResidentialLoanApplication> loanAppList,
    String triggerContext
  ) {
    List<BrokerCloudEventModel> cloudEventModels = new List<BrokerCloudEventModel>();
    if (loanAppList.isEmpty()) {
      return cloudEventModels;
    }
    for (ResidentialLoanApplication eachLoanApp : loanAppList) {
      BrokerCloudEventModel eventModel = generateRLACEModel(
        eachLoanApp,
        triggerContext
      );
      cloudEventModels.add(eventModel);
    }
    return cloudEventModels;
  }

  /**
   * @description Generate RLA related Cloud Event Model
   * @param loanApp ResidentialLoanApplication record
   * @param eventType GCP event type
   * @return BrokerCloudEventModel
   */
  @TestVisible
  private static BrokerCloudEventModel generateRLACEModel(
    ResidentialLoanApplication loanApp,
    String eventType
  ) {
    List<BrokerCloudEventModel.MasterNode> masterNodes = new List<BrokerCloudEventModel.MasterNode>();
    BrokerCloudEventModel.MasterNode masterNodeObj = ApplicationDataCEBuilder.buildResidentialLoanAppNode(
      loanApp
    );
    masterNodes.add(masterNodeObj);
    return new ApplicationDataCloudEventModel(loanApp, masterNodes, eventType);
  }

  /**
   * @description Log publish success events
   * @param successEvents List of success events
   */
  @TestVisible
  public static void logSuccessEvents(List<SObject> successEvents) {
    if (successEvents.isEmpty()) {
      return;
    }
    Logger.info(
      'Residential Loan Application Published' +
        successEvents.size() +
        ' Loan App Cloud Events'
    );
    Logger.saveLog();
  }
}