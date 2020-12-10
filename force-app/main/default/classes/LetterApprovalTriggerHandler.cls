public without sharing class LetterApprovalTriggerHandler extends Lib_TriggerHandler {
	/**
   * @description Constructor to call the trigger framework
   */
  public LetterApprovalTriggerHandler() {
    super();
  }

  /**
   * @description onbeforeUpdate
   */
    public override void onBeforeUpdate(Map<Id, SObject> oldMap){
        Map<id,Letter_Approval__c> commsOldMap = (Map<id,Letter_Approval__c>) oldMap;
        list<Letter_Approval__c> CommsEventlist = new list<Letter_Approval__c>();
        for(Letter_Approval__c com : (list<Letter_Approval__c>)trigger.new){
            if (com.status__c == 'Approved' && commsOldMap.get(com.Id).status__c != 'Approved' ){
                CommsEventlist.add(com);
                com.Status__c = 'Sent';
            }
        }
        list<Comms_Event__e> eventList = generateEventList(CommsEventlist);
        if(eventList.size()>0){
            Database.SaveResult[] srList = EventBus.publish(eventList);
          for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
        // Operation failed, so get all errors                
        		for(Database.Error err : sr.getErrors()) {
                	string errmsg = 'Unable to approve - error while sending out comms : ' + err.getStatusCode() + ': ' + err.getMessage();
                    CalloutException e = new CalloutException();
                    e.setMessage(errmsg);
                    throw e;
        		}
    		}
          }
       } 
    }
    private static list<Comms_Event__e> generateEventList (list<Letter_Approval__c> CommsEventlist){
        list<Comms_Event__e> eventList = new list<Comms_Event__e>();
        set<id> comIdSet = new set<id>();
        set<Id> caseIDSet = new set<id>();
        for(Letter_Approval__c com : CommsEventlist){
                comIdSet.add(com.Id);
            	caseIDSet.add(com.Case__c);
        }
        Map<Id,string> caseDetMap = getCaseDetails(caseIDSet);
        Map<Id,list<Letter_Approval_Details__c>> lineItemMap = getCommLineItems(comIdSet);
        for(Letter_Approval__c com : CommsEventlist){
            Comms_Event__e event = new Comms_Event__e();
            event.Customer_Number__c = caseDetMap.get(com.Case__c);
            event.isEmail__c = com.Send_As_Email__c;
            event.isLetter__c = com.Send_As_Letter__c;
            event.Template_Name__c = com.Template_Name__c;
            list<string> jsonFieldList = buildJsonField(lineItemMap.get(com.Id));
            
            if(jsonFieldList.size()>=1){
               event.Json1__c = jsonFieldList[0];
            }
            if (jsonFieldList.size()>=2){       
               event.Json2__c = jsonFieldList[1];
            }
            eventList.add(event);
        }
        return eventList;
    }
    private static Map<Id,string> getCaseDetails(set<id> caseIDSet){
        Map<Id,string> caseDetMap = new Map<Id, string> ();
        list<case> caseList = [Select Id,IDR_Customer_Number__c from case where Id in :caseIdSet];
        
        for(case c: caseList){
            caseDetMap.put(c.Id , c.IDR_Customer_Number__c);
        }
        return caseDetMap;
    }
    private static Map<Id,list<Letter_Approval_Details__c>> getCommLineItems(set<id> ComIdSet){
        Map<Id,list<Letter_Approval_Details__c>> lineItemMap = new Map<Id,list<Letter_Approval_Details__c>>();
        list<Letter_Approval_Details__c> lineItemList = [Select Id, Field_Name__c , Value__c , Letter_Approval__c from Letter_Approval_Details__c where Letter_Approval__c in :ComIdSet order by Letter_Approval__c];
        for (Letter_Approval_Details__c lineItem :lineItemList ){
            if(lineItemMap.keySet().contains(lineItem.Letter_Approval__c)){
                list<Letter_Approval_Details__c> itemList = lineItemMap.get(lineItem.Letter_Approval__c);
                itemList.add(lineItem);
                lineItemMap.put(lineItem.Letter_Approval__c,itemList);
            }else{
                list<Letter_Approval_Details__c> itemList = new list<Letter_Approval_Details__c>();
                itemList.add(lineItem);
                lineItemMap.put(lineItem.Letter_Approval__c,itemList);
            }
		}
        return lineItemMap;
    }
    
    private static list<string> buildJsonField(list<Letter_Approval_Details__c> LineItemList){
        list<string> jsonFieldList = new list<string>();
        string jsonString = '{';
        for(Letter_Approval_Details__c lineItem : LineItemList){
           jsonString += '"' + lineItem.Field_Name__c + '" : "' + lineItem.Value__c + '"';
        }
        
        jsonString += ' }';
        integer index = 0;
        while(index< jsonString.length()){
          if((jsonString.length() - index) > 131072){
            jsonFieldList.add(jsonString.substring(index, 131071));
          }else{
            jsonFieldList.add(jsonString.substring(index)); 
          } 
          index += 131072;  
        }
        
        return jsonFieldList;
        
    }
}