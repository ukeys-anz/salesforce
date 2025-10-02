trigger TerritorySharingSubscriberTrigger on Territory_Base_Sharing_Event__e(
  after insert
) {
  TerritorySharingTriggerHandler objTerritorySubscriber = new TerritorySharingTriggerHandler();
}
