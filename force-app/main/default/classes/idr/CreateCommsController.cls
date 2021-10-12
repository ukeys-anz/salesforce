/**
 *
 * @author Himabindu Nekkanti
 * @since 2021
 * @description CreateCommsController is the apex side controller for the CreateCaseComms LWC
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class CreateCommsController {
  /**
   * @description The getTemplateList used to fetch availabe templates from IDR_Template_Detail__c .
   *
   * @return List<string>  list of all the templates that have been set up
   */
  @auraEnabled
  public static List<string> getTemplateList() {
    List<string> returnList = new List<string>();
    list<IDR_Template_Detail__c> templatedetails = new List<IDR_Template_Detail__c>();
    if (IDR_Template_Detail__c.sObjectType.getDescribe().isQueryable()) {
      templatedetails = [
        SELECT Id, IDR_Template__c
        FROM IDR_Template_Detail__c
      ];
    }
    set<string> uniqueTemplateNames = new Set<string>();
    for (IDR_Template_Detail__c td : templatedetails) {
      uniqueTemplateNames.add(td.IDR_Template__c);
    }
    returnlist.addAll(uniqueTemplateNames);
    return returnlist;
  }
  /**
   * @description  fetch free text fields for the selected template with pre populated case data
   *
   * @param template user selected template for this letter/email
   * @param caseId the id of the case against which this lette/email is being created
   * @return List<CreateCommsData> list of free text fields with pre populated data where applicable
   */
  @auraEnabled
  public static list<CreateCommsData> fetchTemplateFields(
    string template,
    string caseId
  ) {
    list<CreateCommsData> returnFieldList = new List<CreateCommsData>();
    list<IDR_Template_Detail__c> templatedetails = new List<IDR_Template_Detail__c>();
    if (IDR_Template_Detail__c.sObjectType.getDescribe().isQueryable()) {
      templatedetails = [
        SELECT
          Id,
          IDR_Template_Field_Name__c,
          IDR_Field_Description__c,
          IDR_Case_Field_Name__c
        FROM IDR_Template_Detail__c
        WHERE IDR_Template__c = :template AND IDR_Is_Free_Text__c = TRUE
        ORDER BY IDR_sort_order__c
      ];
    }
    string caseQuery = '';

    for (IDR_Template_Detail__c td : templatedetails) {
      if (string.isNotBlank(td.IDR_Case_Field_Name__c)) {
        if (string.isBlank(caseQuery)) {
          caseQuery = 'Select ' + td.IDR_Case_Field_Name__c;
        } else {
          caseQuery += ', ' + td.IDR_Case_Field_Name__c;
        }
      }
    }
    case parentCase = new case();
    if (string.isNotBlank(caseQuery)) {
      caseQuery += ' From Case where Id = :CaseId LIMIT 1';
      parentCase = Database.query(caseQuery); //NOPMD
    }
    for (IDR_Template_Detail__c td : templatedetails) {
      string caseValue = '';
      if (string.isNotBlank(td.IDR_Case_Field_Name__c)) {
        caseValue = getValueFromCaseMap(td.IDR_Case_Field_Name__c, parentCase);
      }

      CreateCommsData singleFieldData = new CreateCommsData(td.IDR_Template_Field_Name__c, caseValue, td.id, td.IDR_Field_Description__c);
     
      returnFieldList.add(singleFieldData);
    }
    return returnFieldList;
  }

  /**
   * @description  loop through the case record and fetch the field
   *
   * @param fieldName name of the field that needs to retrived
   * @param caseRec the case record that needs to be looped through.
   * @return string field value retrieved from the case record.
   */
  public static string getValueFromCaseMap(string fieldName, case caseRec) {
    string fieldValue = '';
    // if we are trying to retrieve lookup fields we cannot directly get the field.
    // receiving error when trying to get Owner.Name: Cannot get 'Owner.Name' from case;
    if (fieldName.contains('.')) {
      list<string> fieldPath = fieldName.split('\\.');
      // convert the query result to a JSON; as we cannot directly type cast it to Map<string, Object>
      string jsonstring = JSON.serialize(caseRec, true);
      //now type cast the string into Map<string,Object>
      Map<String, Object> obj = (Map<String, Object>) JSON.deserializeUntyped(
        jsonstring
      );
      Map<string, object> childObj = obj;
      integer i = 1;
      // flow down the fieldPath for example => Owner.Name; get owner object then Name.
      for (string st : fieldPath) {
        //final value should be string of data ( example Name);
        if (i == fieldPath.size()) {
          fieldValue = (string) childObj.get(st);
        } else {
          childObj = (Map<String, Object>) childObj.get(st);
          i++;
        }
      }
    } else {
      fieldValue = (string) caseRec.get(fieldName);
    }
    return fieldValue;
  }

  /**
   * @description create letter approval records for the letter/email to be approved.
   *
   * @param otherDetails List of parms (caseID ,isEmail , isLetter , template )
   * @param lineItems list of free text fields with user inputed data.
   * @return string ID of the created letter approval record.
   */

  @auraEnabled
  public static string createComms(
    list<object> otherDetails,
    list<object> lineItems
  ) {
    Map<Object, Object> letterDetails = (Map<Object, Object>) otherDetails[0];
    string template = (string) letterDetails.get('template');
    string caseID = (string) letterDetails.get('caseId');
    IDR_Letter_Approval__c caseComms = new IDR_Letter_Approval__c( 
      IDR_Send_As_Email__c = (Boolean) letterDetails.get('isEmail'),
      IDR_Send_As_Letter__c = (Boolean) letterDetails.get('isLetter'),
      IDR_case__c = caseID,
      IDR_Template_Name__c = IDRConstants.xpressiontemplateName.get(
      template),
      IDR_Status__c = 'Submitted');

    if (lineItems.size() == 0) {
        caseComms.IDR_Auto_Approve__c = true;
    }

    if (
      IDR_Letter_Approval__c.sObjectType.getDescribe().isCreateable() &&
      Schema.sObjectType.IDR_Letter_Approval__c.fields.IDR_Auto_Approve__c.isCreateable() &&
      Schema.sObjectType.IDR_Letter_Approval__c.fields.IDR_case__c.isCreateable() &&
      Schema.sObjectType.IDR_Letter_Approval__c.fields.IDR_Send_As_Letter__c.isCreateable() &&
      Schema.sObjectType.IDR_Letter_Approval__c.fields.IDR_Status__c.isCreateable() &&
      Schema.sObjectType.IDR_Letter_Approval__c.fields.IDR_Send_As_Email__c.isCreateable() &&
      Schema.sObjectType.IDR_Letter_Approval__c.fields.IDR_Template_Name__c.isCreateable()
    ) {
      insert caseComms;
    } else {
      CommonUtil.logAndThrowIAE(
        'CreateCommsController',
        'createComms',
        'Not enough permissions to create IDR_Letter_Approval__c.'
      );
    }

    list<IDR_Letter_Approval_Details__c> commsLineItemsList = new List<IDR_Letter_Approval_Details__c>();
    for (object o : lineItems) {
      Map<object, object> fieldList = (Map<object, object>) o;
      IDR_Letter_Approval_Details__c commsLineItem = new IDR_Letter_Approval_Details__c(
        IDR_Letter_Approval__c = caseComms.Id
      );
      commsLineItem.Name = (string) fieldList.get('fieldLabel');
      commsLineItem.IDR_Field_Name__c = (string) fieldList.get('fieldLabel');
      commsLineItem.IDR_Value__c = (string) fieldList.get('fieldValue');
      commsLineItemsList.add(commsLineItem);
    }
    list<IDR_Letter_Approval_Details__c> caseDataItems = getCommsDataFromCase(
      template,
      caseId
    );

    for (IDR_Letter_Approval_Details__c item : caseDataItems) {
      item.IDR_Letter_Approval__c = caseComms.Id;
      commsLineItemsList.add(item);
    }

    if (commsLineItemsList.size() > 0) {
      if (
        IDR_Letter_Approval_Details__c.sObjectType.getDescribe()
          .isCreateable() &&
        Schema.sObjectType.IDR_Letter_Approval_Details__c.fields.IDR_Field_Name__c.isCreateable() &&
        Schema.sObjectType.IDR_Letter_Approval_Details__c.fields.IDR_Value__c.isCreateable() &&
        Schema.sObjectType.IDR_Letter_Approval_Details__c.fields.Name.isCreateable() &&
        Schema.sObjectType.IDR_Letter_Approval_Details__c.fields.IDR_Letter_Approval__c.isCreateable()
      ) {
        insert commsLineItemsList;
      } else {
        CommonUtil.logAndThrowIAE(
          'CreateCommsController',
          'createComms',
          'Not enough permissions to create IDR_Letter_Approval_Details__c.'
        );
      }
    }

    submitCommsForApproval(caseComms);
    return caseComms.Id;
  }

  /**
   * @description for the selected template get the data that needs to be populated directly from the case.
   *
   * @param template user selected template for this letter/email
   * @param caseId the id of the case against which this lette/email is being created
   * @return list<IDR_Letter_Approval_Details__c> list of detail records to be added against the letter/email.
   */
  public static list<IDR_Letter_Approval_Details__c> getCommsDataFromCase(
    string template,
    string caseId
  ) {
    list<IDR_Letter_Approval_Details__c> caseDataItems = new List<IDR_Letter_Approval_Details__c>();
    list<IDR_Template_Detail__c> templatedetails = new List<IDR_Template_Detail__c>();
    if (IDR_Template_Detail__c.sObjectType.getDescribe().isQueryable()) {
      templatedetails = [
        SELECT Id, IDR_Template_Field_Name__c, IDR_Case_Field_Name__c
        FROM IDR_Template_Detail__c
        WHERE IDR_Template__c = :template AND IDR_Is_Free_Text__c = FALSE
      ];
    }

    string caseQuery = '';

    for (IDR_Template_Detail__c td : templatedetails) {
      if (string.isBlank(caseQuery)) {
        caseQuery = 'Select ' + td.IDR_Case_Field_Name__c;
      } else {
        caseQuery += ', ' + td.IDR_Case_Field_Name__c;
      }
    }

    if (string.isNotBlank(caseQuery)) {
      caseQuery += ' From Case where Id = :CaseId LIMIT 1';
      case parentCase = new case();
      parentCase = Database.query(caseQuery); //NOPMD
      for (IDR_Template_Detail__c td : templatedetails) {
        IDR_Letter_Approval_Details__c item = new IDR_Letter_Approval_Details__c();
        item.Name = td.IDR_Template_Field_Name__c;
        item.IDR_Field_Name__c = td.IDR_Template_Field_Name__c;
        string itemValue = getValueFromCaseMap(
          td.IDR_Case_Field_Name__c,
          parentCase
        );
        item.IDR_Value__c = itemValue;

        caseDataItems.add(item);
      }
    }
    return caseDataItems;
  }

  /**
   * @description submit the letter approval record for approval
   *
   * @param caseComms the record that needs to be submitted for approval
   */
  public static void submitCommsForApproval(IDR_Letter_Approval__c caseComms) {
    // Create an approval request
    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    req.setObjectId(caseComms.Id);
    // Submit the approval request
    Approval.process(req);
  }
}
