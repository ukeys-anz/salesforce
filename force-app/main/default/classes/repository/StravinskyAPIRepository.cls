/**
 * @author Paul Boyington
 * @since May 2022
 * @description Stravinsky API repository for all Stravinsky callouts
 * @group Repository
 */
public with sharing class StravinskyAPIRepository extends RepositoryBase {
  @TestVisible
  public static Boolean throwException = false; // This is to force an exception to increase unit test coverage as current mock framework only returns positive response. A PDR will be raised to extend the mock framework if similar instances arise.

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

  /**
   * @param caseRecord COB Case to be updated
   * @description triggers Temporal Case Workflow API
   */
  public void triggerTemporalCaseWorkflow(Case caseRecord) {
    Service s = ServiceProvider.getService(StravinskyService.class);
    HttpCalloutResponse response = s.triggerTemporalCaseWorkflow(caseRecord);
    if (!response.successful || throwException == true) {
      handleErrors(response, null, StravinskyService.class);
    }
  }

  /**
   * @param personaId COB Primary ID record Persona Id
   * @param tokenizedFields a list of fields to be detokenized, as callout request body
   * @return COBPrimaryIDDocumentModel
   * @description stravinsky COBPID detokenization api
   */
  public COBPrimaryIDDocumentModel cobPidDetokenization(
    String personaId,
    List<COBPrimaryIDDocumentModel.TokenizedValue> tokenizedFields
  ) {
    Service s = ServiceProvider.getService(StravinskyService.class);
    HttpCalloutResponse response = s.detokenizeCOBPID(
      personaId,
      tokenizedFields
    );

    if (response.successful == false) {
      handleErrors(response, null, StravinskyService.class);
    }

    return COBPrimaryIDDocumentModel.parse(response.body);
  }

  /**
   * @param personaId COB Primary ID record Persona Id
   * @param detokenizedValue detokenized value (plain text) of a COBPID record
   * @return COBPrimaryIDDocumentModel
   * @description stravinsky COBPID tokenization api
   */
  public COBPrimaryIDDocumentModel cobPidTokenization(
    String personaId,
    COBPrimaryIDDocumentModel detokenizedValue
  ) {
    Service s = ServiceProvider.getService(StravinskyService.class);
    HttpCalloutResponse response = s.tokenizeCOBPID(
      personaId,
      detokenizedValue
    );

    if (response.successful == false) {
      handleErrors(response, null, StravinskyService.class);
    }

    return COBPrimaryIDDocumentModel.parse(response.body);
  }
}
