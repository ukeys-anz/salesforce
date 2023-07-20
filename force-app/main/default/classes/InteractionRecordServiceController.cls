/**
 * @author Kopal Goswami
 * @since July 2023
 * @description InteractionRecordServiceController 

 */
public with sharing class InteractionRecordServiceController {
  /**
   * @description getInteractionRecord is to query Interaction based on parentId and recordtype
   * @param strParentId the id to be queried
   * @param strRecordTypeName
   * @param maxRecords
   * @return List<Interaction> the queried Interaction list
   */
  @AuraEnabled(cacheable=true)
  public static List<InteractionWrapper> getInteractionRecord(
    String strParentId,
    String strRecordTypeName,
    Integer maxRecords
  ) {
    Map<String, Object> params = new Map<String, Object>();
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    inputMap.put('anyRecordId', strParentId);
    inputMap.put('recordTypeDeveloperName', strRecordTypeName);
    inputMap.put('maxNumber', maxRecords);
    params.put('input', inputMap);
    params.put('output', outMap);
    params.put('options', options);
    InteractionListViewFetchData interactionListViewData = new InteractionListViewFetchData();
    interactionListViewData.call('fetchDataBasedOnRecordId', params);
    List<Interaction> interactionList = (List<Interaction>) outMap.get(
      'interactions'
    );
    List<InteractionWrapper> wrapperList = new List<InteractionWrapper>();
    for (Interaction record : interactionList) {
      wrapperList.add(new InteractionWrapper(record));
    }
    return wrapperList;
  }

  /**
   * @description wrapper class to wrap interaction information
   */
  public with sharing class InteractionWrapper {
    @AuraEnabled
    public String interactId;
    @AuraEnabled
    public String interactName;
    @AuraEnabled
    public String interactTime;
    @AuraEnabled
    public String ownerName;
    @AuraEnabled
    public String actualTopic;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public String attendees;
    @AuraEnabled
    public String reasonOfVisit;
    @AuraEnabled
    public String place;
    @AuraEnabled
    public String accountId;
    @AuraEnabled
    public String chatOrCallSid;
    @AuraEnabled
    public Boolean videoCall;
    @AuraEnabled
    public Boolean enableReinitiate;

    /**
     * @description constructor of wrapper class to turn an interaction sobject into wrapper record
     * @param record Interaction record to be converted into wrapper record
     */
    public InteractionWrapper(Interaction record) {
      this.interactId = record.Id;
      this.interactName = record.Name;
      this.ownerName = record.Owner.Name;
      this.actualTopic = record.Actual_Topics__c;
      this.videoCall = record.Video_Call__c;
      this.status = record.Status__c;
      this.attendees = record.Attendees__c;
      this.reasonOfVisit = record.Reason_for_Visit__c;
      this.place = record.Place__c;
      this.accountId = record.AccountId;
      this.chatOrCallSid = record.Chat_or_Call_SID__c;
      if (record.StartTime != null) {
        this.interactTime = record.StartTime.format('dd/MM/yyyy h:mm a');
      } else {
        this.interactTime = record.CreatedDate.format('dd/MM/yyyy h:mm a');
      }
      if (record.Status__c != 'Completed') {
        this.enableReinitiate = true;
      } else {
        this.enableReinitiate = false;
      }
    }
  }
}
