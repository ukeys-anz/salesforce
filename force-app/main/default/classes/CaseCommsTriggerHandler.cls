public without sharing class CaseCommsTriggerHandler extends Lib_TriggerHandler {
	/**
   * @description Constructor to call the trigger framework
   */
  public CaseCommsTriggerHandler() {
    super();
  }

  /**
   * @description onbeforeUpdate
   */
    public override void onBeforeUpdate(Map<Id, SObject> oldMap){
        Map<id,case_comms__c> commsOldMap = (Map<id,case_comms__c>) oldMap;
        list<case_comms__c> CommsEventlist = new list<case_comms__c>();
        for(case_comms__c com : (list<case_comms__c>)trigger.new){
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
    private static list<Comms_Event__e> generateEventList (list<case_comms__c> CommsEventlist){
        list<Comms_Event__e> eventList = new list<Comms_Event__e>();
        set<id> comIdSet = new set<id>();
        set<Id> caseIDSet = new set<id>();
        for(case_comms__c com : CommsEventlist){
                comIdSet.add(com.Id);
            	caseIDSet.add(com.Case__c);
        }
        Map<Id,string> caseDetMap = getCaseDetails(caseIDSet);
        Map<Id,list<Case_Comms_Line_Item__c>> lineItemMap = getCommLineItems(comIdSet);
        for(case_comms__c com : CommsEventlist){
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
    private static Map<Id,list<Case_Comms_Line_Item__c>> getCommLineItems(set<id> ComIdSet){
        Map<Id,list<Case_Comms_Line_Item__c>> lineItemMap = new Map<Id,list<Case_Comms_Line_Item__c>>();
        list<Case_Comms_Line_Item__c> lineItemList = [Select Id, Field_Name__c , Value__c , Case_Comms__c from Case_Comms_Line_Item__c where Case_comms__c in :ComIdSet order by Case_comms__c];
        for (Case_Comms_Line_Item__c lineItem :lineItemList ){
            if(lineItemMap.keySet().contains(lineItem.Case_Comms__c)){
                list<Case_Comms_Line_Item__c> itemList = lineItemMap.get(lineItem.Case_Comms__c);
                itemList.add(lineItem);
                lineItemMap.put(lineItem.Case_Comms__c,itemList);
            }else{
                list<Case_Comms_Line_Item__c> itemList = new list<Case_Comms_Line_Item__c>();
                itemList.add(lineItem);
                lineItemMap.put(lineItem.Case_Comms__c,itemList);
            }
		}
        return lineItemMap;
    }
    
    private static list<string> buildJsonField(list<Case_Comms_Line_Item__c> LineItemList){
        list<string> jsonFieldList = new list<string>();
        string jsonString = '{';
        for(Case_Comms_Line_Item__c lineItem : LineItemList){
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