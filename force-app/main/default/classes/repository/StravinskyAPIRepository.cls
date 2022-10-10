/**
 * @author Paul Boyington
 * @since May 2022
 * @description Stravinsky API repository for all Stravinsky callouts
 * @group Repository
 */
public with sharing class StravinskyAPIRepository extends RepositoryBase {
  /**
   * @param caseRecord contains ocv id and package id
   * @param checkingAccount the account number for the checking account
   * @param savingsAccount the account number for the savings account
   * @return PackageClosureModel
   * @description stravinsky package closure api
   */
  public PackageClosureModel packageClosure(
    Case caseRecord,
    String checkingAccount,
    String savingsAccount
  ) {
    PackageClosureModel result;

    Service s = ServiceProvider.getService(StravinskyService.class);
    HttpCalloutResponse response = s.closePackage(
      caseRecord.Account.OCV_ID__c,
      caseRecord.Package_Id__c,
      checkingAccount,
      savingsAccount
    );

    if (response.successful) {
      try {
        result = PackageClosureModel.parse(response.body);
      } catch (Exception e) {
        handleErrors(response, e, StravinskyService.class);
      }
    } else {
      handleErrors(response, null, StravinskyService.class);
    }

    return result;
  }
}
