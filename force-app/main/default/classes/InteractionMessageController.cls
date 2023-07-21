/**
 * @author Nagendra Singh
 * @since July 2023
 * @description InteractionMessageController
 */
public with sharing class InteractionMessageController {
  /**
   * @description fetchDataForInteraction is to query Interaction based on search string
   * @param anyRecordId the id to be queried
   * @param recordTypeDeveloperName recordtype name
   * @param statusSearch search string
   * @return List<Interaction> the queried Interaction list
   */
  @AuraEnabled
  public static List<Interaction> fetchDataForInteraction(
    Id anyRecordId,
    String recordTypeDeveloperName,
    List<String> statusSearch
  ) {
    try {
      Callable interactionListViewCtrl = (Callable) Type.forName(
          'InteractionListViewFetchData'
        )
        .newInstance();
      Map<String, Object> args = new Map<String, Object>();
      args.put(
        'input',
        new Map<String, Object>{
          'anyRecordId' => anyRecordId,
          'recordTypeDeveloperName' => recordTypeDeveloperName,
          'statusSearch' => statusSearch
        }
      );
      args.put('output', new Map<String, Object>());
      interactionListViewCtrl.call('fetchDataBasedOnRecordId', args);
      Map<String, Object> mapOutput = (Map<String, Object>) args.get('output');
      return (List<Interaction>) mapOutput.get('interactions');
    } catch (Exception e) {
      Logger.error(e.getMessage());
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
  }
}
