trigger UserTerritorySetupSubscriber on User_Territory_Setup_Event__e(
  after insert
) {
  UserTerritorySetupHandler objHandler = new UserTerritorySetupHandler();
}
