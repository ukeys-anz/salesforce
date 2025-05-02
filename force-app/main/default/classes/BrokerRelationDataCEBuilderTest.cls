/**
 * @author Saurabh Chauhan
 * @since  10/03/2025
 * @description Test class for BrokerRelationDataCEBuilder
 */
@IsTest
public with sharing class BrokerRelationDataCEBuilderTest {
  /**
   * @description test method for buildBrokerRelationAdd
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testBuildBrokerRelationAdd() {
    BrokerCloudEventModel.MasterNode addEventNode = BrokerRelationDataCEBuilder.buildBrokerRelationAdd(
      RetailBrokerRelationEventActionsTest.mockContact(),
      'PRBM'
    );

    Assert.isFalse(
      addEventNode.targetObjects.parent.isEmpty(),
      'There is a parent node for add event'
    );
  }

  /**
   * @description test method for buildBrokerRelationDelete
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testBuildBrokerRelationDelete() {
    BrokerCloudEventModel.MasterNode deleteEventNode = BrokerRelationDataCEBuilder.buildBrokerRelationDelete(
      RetailBrokerRelationEventActionsTest.mockContact(),
      'PRBM',
      mockLanIdWrapper()
    );

    Assert.isTrue(
      deleteEventNode.targetObjects.parent == null,
      'There is no parent node for delete event'
    );
  }

  /**
   * @description test method for buildBrokerRelationParentNodes
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testBuildBrokerRelationParentNodes() {
    List<BrokerCloudEventModel.ParentNode> brokerRelationParentNodes = BrokerRelationDataCEBuilder.buildBrokerRelationParentNodes(
      RetailBrokerRelationEventActionsTest.mockContact(),
      'PRBM',
      'dummylanId'
    );

    Assert.areEqual(
      3,
      brokerRelationParentNodes.size(),
      'There should be 3 sub parent nodes'
    );
    Assert.areEqual(
      'External_Id__c',
      brokerRelationParentNodes[0].extIdField,
      'There should be a Lan Id passed in parent node'
    );
    Assert.areEqual(
      'Lan_Id__c',
      brokerRelationParentNodes[1].extIdField,
      'There should be an external id passed in parent node'
    );
    Assert.areEqual(
      'OCV_Role__c',
      brokerRelationParentNodes[2].extIdField,
      'There should be a role id passed in parent node'
    );
  }

  /**
   * @description test method for returnLanIdForDeleteEvent
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testReturnLanIdForDeleteEvent() {
    String lanIdReturnedForPrbm = BrokerRelationDataCEBuilder.returnLanIdForDeleteEvent(
      mockLanIdWrapper(),
      'PRBM'
    );
    String lanIdReturnedForSrbm = BrokerRelationDataCEBuilder.returnLanIdForDeleteEvent(
      mockLanIdWrapper(),
      'SRBM'
    );

    Assert.areEqual(
      mockLanIdWrapper().prbmLanId,
      lanIdReturnedForPrbm,
      'If type PRBM then lan id of primary rbm is returned'
    );
    Assert.areEqual(
      mockLanIdWrapper().srbmLanId,
      lanIdReturnedForSrbm,
      'If type SRBM then lan id of secondary rbm is returned'
    );
  }

  /**
   * @description test method for returnLanIdForAddEvent
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testReturnLanIdForAddEvent() {
    User primaryRbmUser = new User(Lan_Id__c = 'test123');
    User secondaryRbmUser = new User(Lan_Id__c = 'test456');
    Broker_Relation__c brokerSet = new Broker_Relation__c(
      Primary_RBM__r = primaryRbmUser,
      Secondary_RBM__r = secondaryRbmUser
    );

    String lanIdReturnedForPrbm = BrokerRelationDataCEBuilder.returnLanIdForAddEvent(
      brokerSet,
      'PRBM'
    );
    String lanIdReturnedForSrbm = BrokerRelationDataCEBuilder.returnLanIdForAddEvent(
      brokerSet,
      'SRBM'
    );

    Assert.areEqual(
      brokerSet.Primary_RBM__r.Lan_Id__c,
      lanIdReturnedForPrbm,
      'If type PRBM then lan id of primary rbm is returned'
    );
    Assert.areEqual(
      brokerSet.Secondary_RBM__r.Lan_Id__c,
      lanIdReturnedForSrbm,
      'If type SRBM then lan id of secondary rbm is returned'
    );
  }

  /**
   * @description to create wrapper mock of type LanIdWrapper
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   * @return RetailBrokerRelationEventActions.LanIdWrapper
   **/
  public static RetailBrokerRelationEventActions.LanIdWrapper mockLanIdWrapper() {
    RetailBrokerRelationEventActions.LanIdWrapper lanIdWrapper = new RetailBrokerRelationEventActions.LanIdWrapper();
    lanIdWrapper.prbmLanId = 'prbm123LanId';
    lanIdWrapper.srbmLanId = 'srbm123LanId';
    return lanIdWrapper;
  }
}
