/**
 * @author PBatya Aisman Sufrin
 * @since Dec 2023
 * @description ConnectID API repository for all ConnectID callouts
 * @group Repository
 */
public with sharing class ConnectIDRepository extends RepositoryBase {
  /**
   * @param ocvId Customer record OCV ID
   * @return ConnectIDModel
   * @description Lighthouse ListConsentHistory api
   */
  public ConnectIDModel getConsentHistoryList(String ocvId) {
    Service s = ServiceProvider.getService(ConnectIDService.class);
    HttpCalloutResponse response = s.getConsentHistoryList(ocvId);

    if (response.successful == false) {
      handleErrors(response, null, ConnectIDService.class);
    }

    return ConnectIDModel.parse(response.body);
  }
}
