trigger MLCRMTerritorySharingSubscriberTrigger on Territory_Base_Sharing_Event__e(
  after insert
) {
  MLCRMTerritorySharingTriggerHandler objTerritorySubscriber = new MLCRMTerritorySharingTriggerHandler();
}
