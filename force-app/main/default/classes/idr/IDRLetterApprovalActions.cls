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
      makeOCVCallout(
        capIdMap.get(appRecId).IDR_Customer_Number__c,
        capIdMap.get(appRecId).IDR_Customer_Identifier__c,
        appRecId
      );
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

    if (
      IDR_Letter_Approval_Details__c.sObjectType.getDescribe().isCreateable() &&
      Schema.sObjectType.IDR_Letter_Approval_Details__c.fields.IDR_Field_Name__c.isCreateable() &&
      Schema.sObjectType.IDR_Letter_Approval_Details__c.fields.IDR_Letter_Approval__c.isCreateable() &&
      Schema.sObjectType.IDR_Letter_Approval_Details__c.fields.IDR_Value__c.isCreateable() &&
      Schema.sObjectType.IDR_Letter_Approval_Details__c.fields.Name.isCreateable()
    ) {
      insert appDetailsList;
    } else {
      CommonUtil.logAndThrowIAE(
        'IDRLetterApprovalActions',
        'makeOCVCallout',
        'Not enough permissions to create IDR_Letter_Approval_Details__c.'
      );
    }

    IDR_Letter_Approval__c appRec = new IDR_Letter_Approval__c(
      id = approvalRecId
    );
    appRec.Customer_Data_updated__c = true;
    if (
      IDR_Letter_Approval__c.sObjectType.getDescribe().isUpdateable() &&
      Schema.sObjectType.IDR_Letter_Approval__c.fields.Customer_Data_updated__c.isUpdateable()
    ) {
      update appRec;
    } else {
      CommonUtil.logAndThrowIAE(
        'IDRLetterApprovalActions',
        'makeOCVCallout',
        'Not enough permissions to update IDR_Letter_Approval__c.'
      );
    }
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
