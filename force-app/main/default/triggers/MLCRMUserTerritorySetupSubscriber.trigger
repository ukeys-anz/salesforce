trigger MLCRMUserTerritorySetupSubscriber on User_Territory_Setup_Event__e(
  after insert
) {
  MLCRMUserTerritorySetupHandler objHandler = new MLCRMUserTerritorySetupHandler();
}
