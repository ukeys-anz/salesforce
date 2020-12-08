public class CreateCommsController {
   @auraEnabled
    public static list<string> getTemplateList(){
       list<string> returnList = new list<string>();
        list<Template_Detail__c> templatedetails = new list<Template_Detail__c>();
        templatedetails = [Select Id, Template__c from Template_Detail__c];
        set<string> uniqueTemplateNames = new set<string>();
        for(Template_Detail__c td : templatedetails){
            system.debug('td:'+td.Template__c);
           uniqueTemplateNames.add(td.Template__c); 
        }
        for(string templateName :uniqueTemplateNames){
            returnlist.add(templateName);
        }
        return returnlist; 
    }
    @auraEnabled
    public static list<CreateCommsData.TemplateFieldsData> fetchTemplateFields(string template){
        list<CreateCommsData.TemplateFieldsData> returnFieldList = new list<CreateCommsData.TemplateFieldsData>();
        list<Template_Detail__c> templatedetails = new list<Template_Detail__c>();
        templatedetails = [Select Id,Template_Field_Name__c,Field_Description__c from Template_Detail__c where Template__c=:template and Is_Free_Text__c = true order by Sort_order__c];
         for(Template_Detail__c td : templatedetails){
           CreateCommsData.TemplateFieldsData singleFieldData = new CreateCommsData.TemplateFieldsData();
           singleFieldData.fieldLabel = td.Template_Field_Name__c;
           singleFieldData.fieldValue = '';
           singleFieldData.fieldId = td.id;
           singleFieldData.fieldDesc = td.Field_Description__c;
           returnFieldList.add(singleFieldData); 
        }
        return returnFieldList;
    }
    @auraEnabled
    public static string  createComms(string caseId, boolean isEmail , boolean isLetter ,string template , list<object> lineItems){
        system.debug('caseId:'+caseId);
        Case_Comms__c caseComms = new Case_Comms__c ();
        caseComms.Send_As_Email__c  = isEmail;
        caseComms.Send_As_Letter__c  = isLetter;
        caseComms.case__c = caseId ;
        caseComms.Template_Name__c = template;
        caseComms.Status__c = 'Submitted';  
        if(lineItems.size()==0){
            caseComms.Auto_Approve__c = true;
        }
        insert caseComms;
        
        list<Case_Comms_Line_Item__c> commsLineItemsList = new list<Case_Comms_Line_Item__c>();
        for(object o : lineItems){
            Map<object,object> fieldList = (Map<object,object>)o;
            system.debug('fieldList:'+fieldList);
            Case_Comms_Line_Item__c commsLineItem = new Case_Comms_Line_Item__c( Case_Comms__c = caseComms.Id);
            for(object key : fieldList.keyset()){
                if((string)key =='fieldLabel'){
                    commsLineItem.Name = (string)fieldList.get(key);
                    commsLineItem.Field_Name__c = (string)fieldList.get(key);
                }else if ((string)key =='fieldValue'){
                    commsLineItem.Value__c	 = (string)fieldList.get(key);
                }else if ((string)key == 'fieldDesc'){
                    commsLineItem.Description__c = (string)fieldList.get(key);
                }              
            }
          	commsLineItemsList.add(commsLineItem);
        }
        list<Case_Comms_Line_Item__c> caseDataItems = getCommsDataFromCase(template, caseId);
        
        for (Case_Comms_Line_Item__c item : caseDataItems){
            item.Case_Comms__c = caseComms.Id;
            commsLineItemsList.add(item);
        }  
        
        if(commsLineItemsList.size() > 0){
           insert commsLineItemsList;
        }
        
		submitCommsForApproval(caseComms,CaseId);
        return caseComms.Id;
    }
    
    public static list<Case_Comms_Line_Item__c> getCommsDataFromCase(string template , string caseId){
        list<Case_Comms_Line_Item__c> caseDataItems = new list<Case_Comms_Line_Item__c>();
        list<Template_Detail__c> templatedetails = new list<Template_Detail__c>();
        templatedetails = [Select Id,Template_Field_Name__c, Case_Field_Name__c from Template_Detail__c where Template__c =:template and Is_Free_Text__c = false];
        
        string caseQuery = '';

        for (Template_Detail__c td : templatedetails ){
           
            if (string.isBlank(caseQuery)){
                caseQuery = 'Select '+ td.Case_Field_Name__c;
            }else{
                caseQuery += ', ' +td.Case_Field_Name__c;
            }
        }
        
        if(string.isNotBlank(caseQuery)){
            caseQuery += ' From Case where Id = :CaseId LIMIT 1';
            
            system.debug('caseQuery:'+caseQuery);
            case parentCase = new case();
            parentCase = Database.query(caseQuery);
            for (Template_Detail__c td : templatedetails ){
                Case_Comms_Line_Item__c item = new Case_Comms_Line_Item__c();
                item.Name = td.Template_Field_Name__c;
                item.Field_Name__c = td.Template_Field_Name__c;
                string itemValue = '';
                system.debug('td.Case_Field_Name__c:'+td.Case_Field_Name__c);
                // if we are trying to retrieve lookup fields we cannot directly get the field.
                // receiving error when trying to get Owner.Name: Cannot get 'Owner.Name' from case;
                if(td.Case_Field_Name__c.contains('.')){
                    list<string> fieldPath = td.Case_Field_Name__c.split('\\.');
                    system.debug('fieldPath:'+fieldPath);
                    // convert the query result to a JSON; as we cannot directly type cast it to Map<string, Object>
                     string jsonstring = JSON.serialize(parentCase, true);
                    //now type cast the string into Map<string,Object>
      				 Map<String, Object> obj = (Map<String, Object>) JSON.deserializeUntyped(jsonstring);
                     Map<string,object> childObj = obj;
                     integer i = 1;
                    // flow down the fieldPath for example => Owner.Name; get owner object then Name.
                     for(string st : fieldPath){
                        system.debug('st:'+st);
                         //final value should be string of data ( example Name);
                         if(i==fieldPath.size()){
                             itemValue = (string)childObj.get(st);
                         }else{
                            childObj = (Map<String, Object>)childObj.get(st);
                             i++;
                         }        
                     }
                }else{
                    itemValue= (string)parentCase.get(td.Case_Field_Name__c);
                }
                item.Value__c =  itemValue;
                
                caseDataItems.add(item);
            }
        }
        return caseDataItems;
    }
    
    public static void submitCommsForApproval(Case_Comms__c caseComms, Id CaseId){
        	case c = [Select OwnerId from Case where id=:CaseId];
        	List<Id> approver = new list<Id> ();
        	approver.add(c.OwnerId);
        	// Create an approval request 
        	Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        	req.setObjectId(caseComms.Id);
        	req.setNextApproverIds(approver);
        	// Submit the approval request 
        	Approval.process(req);
    }
}