/**
 * @author Afreen Khan
 * @since 04/2021
 * @description  IDRLetterApprovalActions contains all the operations related to Letter Approval record and is called from LetterApprovalTriggerhandler.
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class IDRLetterApprovalActions {
  /**
   * @description populateCustomerData is to filter the approved letter records related to customer complaint.
   * @param approvalRecords records in current context
   * @param oldMap map of old record in current context
   */
  public static void populateCustomerData(
    List<IDR_Letter_Approval__c> approvalRecords,
    Map<Id, IDR_Letter_Approval__c> oldMap
  ) {
    Map<Id, Case> capIdMap = new Map<Id, Case>();
    Set<Id> caseIds = new Set<Id>();

    Map<Id, Map<String, String>> ocvCalloutInfo = new Map<Id, Map<String, String>>();

    for (IDR_Letter_Approval__c app : approvalRecords) {
      if (
        app.IDR_Status__c == 'Approved' &&
        (oldMap == null ||
        oldMap.get(app.id).IDR_Status__c != 'Approved')
      ) {
        caseIds.add(app.IDR_Case__c);
      }
    }

    Map<Id, Case> caseMap = new Map<Id, Case>(
      [
        SELECT id, IDR_Customer_Number__c, IDR_Customer_Identifier__c
        FROM Case
        WHERE Id IN :caseIds AND IDR_Customer_Number__c != NULL
      ]
    );

    for (IDR_Letter_Approval__c app : approvalRecords) {
      if (caseMap.containsKey(app.IDR_Case__c)) {
        capIdMap.put(app.id, caseMap.get(app.IDR_Case__c));
      }
    }

    for (Id appRecId : capIdMap.keySet()) {
      Map<String, String> idrInfo = new Map<String, string>{
        'idrCustomerNumber' => capIdMap.get(appRecId).IDR_Customer_Number__c,
        'idrCustomerIdentifier' => capIdMap.get(appRecId)
          .IDR_Customer_Identifier__c
      };
      ocvCalloutInfo.put(appRecId, idrInfo);
    }

    if (ocvCalloutInfo.size() > 0) {
      String ocvCalloutInfoJson = JSON.serialize(ocvCalloutInfo);
      makeMultipleOCVCallout(ocvCalloutInfoJson);
    }
  }

  /**
   * @description populateCustomerData is to make OCV call and create the detail record with customer data
   * @param customerNumber customer Number
   * @param customerIdentifier Customer Identifier Type
   * @param approvalRecId Letter Approval record Id
   */
  @future(callOut=true)
  public static void makeOCVCallout(
    String customerNumber,
    String customerIdentifier,
    String approvalRecId
  ) {
    IDRCustomerInformationModel responseMap = IDRAPIRepository.getCustomerInfoLWC(
      customerNumber,
      customerIdentifier
    );
    Map<String, Object> customerData = (Map<String, Object>) System.JSON.deserializeUntyped(
      System.JSON.serialize(responseMap.profile)
    );

    List<IDR_Letter_Approval_Details__c> appDetailsList = buildAllDetailsList(
      customerData,
      approvalRecId
    );
    List<IDR_Letter_Approval__c> allAppRec = new List<IDR_Letter_Approval__c>();
    allAppRec.add(buildLetterApproval(approvalRecId));

    insertAllAppDetailsList(appDetailsList);
    updateAllAppRecords(allAppRec);
  }

  /**
   * @description populateCustomerData is to make multiple OCV call and create the detail record with customer data
   * @param ocvCalloutInfoJson which is a serialized string made out of Map<approvalRecId, Map<String,String>{customerNumber,customerIdentifier}>
   * point: We can not use makeOCVCallout method inside this method, as using future method inside a loop is critical.
   */
  @future(callOut=true)
  public static void makeMultipleOCVCallout(String ocvCalloutInfoJson) {
    Map<String, Object> ocvCalloutInfo = (Map<String, Object>) JSON.deserializeUntyped(
      ocvCalloutInfoJson
    );

    List<IDR_Letter_Approval_Details__c> allAppDetailsList = new List<IDR_Letter_Approval_Details__c>();
    List<IDR_Letter_Approval__c> allAppRec = new List<IDR_Letter_Approval__c>();

    for (String approvalRecId : ocvCalloutInfo.keySet()) {
      Map<String, Object> customerData = customerDataMap(
        ocvCalloutInfo,
        approvalRecId
      );
      allAppDetailsList.addAll(
        buildAllDetailsList(customerData, approvalRecId)
      );

      IDR_Letter_Approval__c appRec = buildLetterApproval(approvalRecId);
      allAppRec.add(appRec);
    }

    insertAllAppDetailsList(allAppDetailsList);
    updateAllAppRecords(allAppRec);
  }

  /**
   * @description insertAllAppDetailsList is to check all the fields on IDR_Letter_Approval_Details__c is creatable and if -
   * - there is at least one member in allAppDetailsList. then insert all of them.
   * @param allAppDetailsList which is List<IDR_Letter_Approval_Details__c>
   */
  public static void insertAllAppDetailsList(
    List<IDR_Letter_Approval_Details__c> allAppDetailsList
  ) {
    if (
      allAppDetailsList.size() > 0 &&
      IDR_Letter_Approval_Details__c.sObjectType.getDescribe().isCreateable() &&
      Schema.sObjectType.IDR_Letter_Approval_Details__c.fields.IDR_Field_Name__c.isCreateable() &&
      Schema.sObjectType.IDR_Letter_Approval_Details__c.fields.IDR_Letter_Approval__c.isCreateable() &&
      Schema.sObjectType.IDR_Letter_Approval_Details__c.fields.IDR_Value__c.isCreateable() &&
      Schema.sObjectType.IDR_Letter_Approval_Details__c.fields.Name.isCreateable()
    ) {
      insert allAppDetailsList;
    } else {
      CommonUtil.logAndThrowIAE(
        'IDRLetterApprovalActions',
        'makeOCVCallout',
        'Not enough permissions to create IDR_Letter_Approval_Details__c.'
      );
    }
  }

  /**
   * @description updateAllAppRecords is to check Customer_Data_updated__c field on IDR_Letter_Approval__c is updateable and if -
   * - there is at least one member in allAppRec. then update all of them.
   * @param allAppRec which is List<IDR_Letter_Approval__c>
   */
  public static void updateAllAppRecords(
    List<IDR_Letter_Approval__c> allAppRec
  ) {
    if (
      allAppRec.size() > 0 &&
      IDR_Letter_Approval__c.sObjectType.getDescribe().isUpdateable() &&
      Schema.sObjectType.IDR_Letter_Approval__c.fields.Customer_Data_updated__c.isUpdateable()
    ) {
      update allAppRec;
    } else {
      CommonUtil.logAndThrowIAE(
        'IDRLetterApprovalActions',
        'makeOCVCallout',
        'Not enough permissions to update IDR_Letter_Approval__c.'
      );
    }
  }

  /**
   * @description buildAllDetailsList is to build all app details according to customerData and approvalRecordId
   * @param customerData which is Map<String, Object> which will be achieved from ocvCalloutInfo
   * @param approvalRecId which is the Id of approval record.
   * @return List<IDR_Letter_Approval_Details__c>
   */
  public static List<IDR_Letter_Approval_Details__c> buildAllDetailsList(
    Map<String, Object> customerData,
    String approvalRecId
  ) {
    List<IDR_Letter_Approval_Details__c> appDetailsList = new List<IDR_Letter_Approval_Details__c>();
    Map<String, String> customerFields = new Map<String, String>{
      'street' => 'AddressStreet',
      'suburb' => 'AddressSuburb',
      'state' => 'AddressState',
      'postCode' => 'AddressPostCode',
      'email' => 'EmailAddress'
    };
    for (String field : customerFields.keySet()) {
      appDetailsList.add(
        createAppDetailRecord(
          customerData.get(field),
          customerFields.get(field),
          approvalRecId
        )
      );
    }
    return appDetailsList;
  }

  /**
   * @description buildLetterApproval is to build app record.
   * @param approvalRecId which is the Id of approval record.
   * @return IDR_Letter_Approval__c
   */
  public static IDR_Letter_Approval__c buildLetterApproval(
    String approvalRecId
  ) {
    IDR_Letter_Approval__c appRec = new IDR_Letter_Approval__c(
      id = approvalRecId
    );
    appRec.Customer_Data_updated__c = true;
    return appRec;
  }

  /**
   * @description customerDataMap is to find the customerData out of ocv callout
   * @param ocvCalloutInfo which is Map<String, Object> which will be achieved from ocv callout
   * @param approvalRecId which is the Id of approval record.
   * @return Map<String, Object>
   */
  public static Map<String, Object> customerDataMap(
    Map<String, Object> ocvCalloutInfo,
    String approvalRecId
  ) {
    Map<string, Object> idrInfo = (Map<string, Object>) ocvCalloutInfo.get(
      approvalRecId
    );
    String customerNumber = (String) idrInfo.get('idrCustomerNumber');
    String customerIdentifier = (String) idrInfo.get('idrCustomerIdentifier');

    IDRCustomerInformationModel responseMap = IDRAPIRepository.getCustomerInfoLWC(
      customerNumber,
      customerIdentifier
    );
    Map<String, Object> cData = (Map<String, Object>) System.JSON.deserializeUntyped(
      System.JSON.serialize(responseMap.profile)
    );
    return cData;
  }

  /**
   * @description createAppDetailRecord is to create Letter Approval detail record
   * @param custData customer data recieved from OCV
   * @param fieldName Field name
   * @param approvalRecId Letter Approval record Id
   * @return IDR_Letter_Approval_Details__c
   */
  public static IDR_Letter_Approval_Details__c createAppDetailRecord(
    Object custData,
    String fieldName,
    String approvalRecId
  ) {
    IDR_Letter_Approval_Details__c rec = new IDR_Letter_Approval_Details__c();
    rec.Name = fieldName;
    rec.IDR_Field_Name__c = fieldName;
    rec.IDR_Value__c = (String) custData;
    rec.IDR_Letter_Approval__c = approvalRecId;

    return rec;
  }
}
