/**
 * @author Shermal Warnakula
 * @since Feb 2021
 * @description Holds common util  functions
 * @group Utils
 */
@SuppressWarnings(
  'PMD.CyclomaticComplexity, PMD.ExcessivePublicCount, PMD.ExcessiveClassLength'
)
public with sharing class CommonUtil {
  public static final String GROUP_TYPE_QUEUE = 'Queue';
  public static final String GROUP_TYPE_PUBLICGROUP = 'Regular';
  /**
   * @description cache profile record by name to reduce SOQL to query for profile
   */
  private static Map<String, Profile> mapProfileByName {
    private get {
      if (mapProfileByName == null) {
        mapProfileByName = new Map<String, Profile>();
        for (Profile prof : [SELECT Id, Name FROM Profile WITH SYSTEM_MODE]) {
          mapProfileByName.put(prof.Name, prof);
        }
      }
      return mapProfileByName;
    }
    private set;
  }

  /**
   * @description cache UserRole record by developername to reduce SOQL to query for UserRole
   */
  private static Map<String, UserRole> mapUserRoleByDevName {
    private get {
      if (mapUserRoleByDevName == null) {
        mapUserRoleByDevName = new Map<String, UserRole>();
        for (UserRole ur : [
          SELECT Id, DeveloperName
          FROM UserRole
          WITH SYSTEM_MODE
        ]) {
          mapUserRoleByDevName.put(ur.DeveloperName, ur);
        }
      }
      return mapUserRoleByDevName;
    }
    private set;
  }

  /**
   * @description cache permission set record by name to reduce SOQL to query for permission set
   */
  private static Map<String, PermissionSet> mapPermissionSetByName {
    private get {
      if (mapPermissionSetByName == null) {
        mapPermissionSetByName = new Map<String, PermissionSet>();
        for (PermissionSet ps : [
          SELECT Id, Name
          FROM PermissionSet
          WITH SYSTEM_MODE
        ]) {
          mapPermissionSetByName.put(ps.Name, ps);
        }
      }
      return mapPermissionSetByName;
    }
    private set;
  }

  /**
   * @description Represents a map of Group records, organized by Type and DeveloperName.
   */
  private static Map<String, Map<String, Group>> mapGroupsByTypeAndName {
    private get {
      if (mapGroupsByTypeAndName == null) {
        mapGroupsByTypeAndName = new Map<String, Map<String, Group>>();
        for (Group g : [
          SELECT Id, Name, Type, DeveloperName
          FROM Group
          WITH USER_MODE
        ]) {
          if (!mapGroupsByTypeAndName.containsKey(g.Type)) {
            mapGroupsByTypeAndName.put(g.Type, new Map<String, Group>());
          }
          mapGroupsByTypeAndName.get(g.Type).put(g.DeveloperName, g);
        }
      }
      return mapGroupsByTypeAndName;
    }
    private set;
  }

  /**
   * @description Represents a map of Queue records by DeveloperName.
   */
  private static Map<String, Group> mapQueueByName {
    private get {
      return mapGroupsByTypeAndName.get(GROUP_TYPE_QUEUE);
    }
  }

  /**
   * @description Represents a map of Public Group records by DeveloperName.
   */
  private static Map<String, Group> mapPublicGroupByName {
    private get {
      return mapGroupsByTypeAndName.get(GROUP_TYPE_PUBLICGROUP);
    }
  }

  /**
   * @description Get all the business hours
   */
  public static BusinessHours anzBusinessHours {
    public get {
      if (
        anzBusinessHours == null &&
        BusinessHours.SObjectType.getDescribe().isQueryable()
      ) {
        anzBusinessHours = [
          SELECT Id
          FROM BusinessHours
          WHERE Name = 'ANZx Case Business Hours'
          LIMIT 1
        ];
      }
      return anzBusinessHours;
    }
    private set;
  }

  /**
   * @description Cached map of value > label for picklist fields, grouped by field
   */
  private static Map<SObjectField, Map<String, String>> mapPicklistValueToLabel = new Map<SObjectField, Map<String, String>>();

  /**
   * @description Get a picklist labels by values (API names).
   * @param field The picklist field, for example Case.Type
   * @return a map of picklist labels by values (example '11':'Other')
   */
  @TestVisible
  public static Map<String, String> getPicklistLabelsByValues(
    Schema.SobjectField field
  ) {
    if (mapPicklistValueToLabel.containsKey(field)) {
      return mapPicklistValueToLabel.get(field);
    }
    Map<String, String> labelsByValues = new Map<String, String>();
    Schema.DescribeFieldResult fieldPicklist = field.getDescribe();
    for (Schema.PicklistEntry f : fieldPicklist.getPicklistValues()) {
      labelsByValues.put(f.getValue(), f.getLabel());
    }
    mapPicklistValueToLabel.put(field, labelsByValues);
    return labelsByValues;
  }

  /**
   * @description getAvailableRecordTypeNamesForSObject(input) method is used to get available record types for a certain sobject.
   * This method will only return the record types that are available to the current user
   * @param sObjectTypeName the API name of the object whose record types we want to retrieve
   * @return Set<Id> list of record type Ids that are available to this user on this object.
   */
  @AuraEnabled
  public static List<Id> getAvailableRecordTypeIdsForSObject(
    String sObjectTypeName
  ) {
    Schema.SObjectType sObj = Schema.getGlobalDescribe().get(sObjectTypeName);
    List<Id> recordTypeIds = new List<Id>();
    for (RecordTypeInfo rti : sObj.getDescribe().getRecordTypeInfos()) {
      if (
        rti.isAvailable() && // Ignore the Master Record Type, whose Id always ends with 'AAA'.
        // We check the Id because Name can change depending on the user's language.
        !String.valueOf(rti.getRecordTypeId()).endsWith('AAA')
      ) {
        recordTypeIds.add(rti.getRecordTypeId());
      }
    }
    return recordTypeIds;
  }

  /**
   * @description Get a picklist label from it's value (API_Key).
   * This function differs from the `getPicklistLabelsByValues` as it returns
   * a single picklist value, not a map.
   * @param field The picklist field, for example Case.Type
   * @param picklistValue The picklist value, for example '2'
   * @return the picklist label, for example 'Advice'
   */
  @TestVisible
  public static String getSinglePicklistLabel(
    Schema.SobjectField field,
    String picklistValue
  ) {
    Map<String, String> mapValueToLabel = getPicklistLabelsByValues(field);

    if (mapValueToLabel.containsKey(picklistValue)) {
      return mapValueToLabel.get(picklistValue);
    }

    return picklistValue;
  }

  /**
   * @description Returns the label(s) of the selected value(s) in a multi-select picklist field.
   * @param field The multi-select picklist field.
   * @param value The selected value(s) in the field, separated by semicolons.
   * @return The label(s) of the selected value(s), joined by semicolons.
   */
  public static String getMultiPicklistLabel(SObjectField field, String value) {
    Map<String, String> mapValueToLabel = getPicklistLabelsByValues(field);
    List<String> labels = new List<String>();

    for (String v : value.split(';')) {
      v = v.trim();
      if (mapValueToLabel.containsKey(v)) {
        labels.add(mapValueToLabel.get(v));
      } else {
        labels.add(v);
      }
    }

    return String.join(labels, ';');
  }

  /**
   * @description Get a picklist value from it's label.
   * @param field The picklist field, for example Case.Type
   * @param picklistLabel The picklist label, for example 'Advice'
   * @return the picklist label, for example '2'
   */
  @TestVisible
  public static String getSinglePicklistValue(
    Schema.SobjectField field,
    String picklistLabel
  ) {
    Schema.DescribeFieldResult fieldPicklist = field.getDescribe();
    Map<String, String> fieldMap = new Map<String, String>();
    for (Schema.PicklistEntry f : fieldPicklist.getPicklistValues()) {
      if (f.getLabel() == picklistLabel) {
        return f.getValue();
      }
    }
    return '';
  }

  /**
   * @description handleMasking method is used to validate free text fields for masking as we dont want to store e.g. card numbers in SF.
   * So, we mask the number and store only last 4 digits unmasked.
   * @param record The actual record from Trigger.new
   * @param oldRecord The actual record from Trigger.old, null if in a before insert trigger
   * @param fieldsToMask a list of fields from a field set, storing the data to be masked
   */
  public static void handleMasking(
    sObject record,
    sObject oldRecord,
    Schema.FieldSetMember[] fieldsToMask
  ) {
    for (Schema.FieldSetMember fsm : fieldsToMask) {
      String fieldName = fsm.getFieldPath();
      if (
        (String.valueOf(fsm.getType()) == 'STRING' ||
        String.valueOf(fsm.getType()) == 'COMBOBOX' ||
        String.valueOf(fsm.getType()) == 'TEXTAREA') &&
        (oldRecord == null ||
        String.valueOf(record.get(fieldName)) !=
        String.valueOf(oldRecord.get(fieldName))) &&
        String.isNotBlank(String.valueOf(record.get(fieldName)))
      ) {
        maskAccountNumbers(fieldName, record);
      }
    }
  }

  /**
   * @description maskAccountNumbers method is used to mask free text fields as we dont want to store e.g. card numbers in SF.
   * So, we mask the number and store only last 4 digits unmasked.
   * @param fieldName name of the field to mask
   * @param record The actual record from Trigger.new
   */
  private static void maskAccountNumbers(String fieldName, sObject record) {
    if (
      fieldName == 'IDR_Account_Card_Policy_Number__c' ||
      fieldName == 'IDR_Account_Card_Policy_Number_2__c' ||
      fieldName == 'IDR_Account_Card_Policy_Number_3__c'
    ) {
      List<String> maskedAccList = new List<String>();
      for (
        String accNumber : String.valueOf(record.get(fieldName)).split(';')
      ) {
        maskedAccList.add(TextUtils.maskData(accNumber));
      }
      record.put(fieldName, String.join(maskedAccList, ';'));
    } else if (
      fieldName == 'Description' ||
      fieldName == 'IDR_Complainant_Desired_Outcome__c' ||
      fieldName == 'IDR_Description_of_Outcome__c' ||
      fieldName == 'How_has_delay_criteria_been_met_not_met__c' ||
      fieldName == 'SI_Subject_of_Breach_Report_Comments__c' ||
      fieldName == 'SI_Definite_Action_Completed__c' ||
      fieldName == 'Subject' ||
      fieldName == 'RAG_Comments__c' ||
      fieldName == 'SI_Rec_Rem_Actions__c' ||
      fieldName == 'IDR_Systemic_Issue_Description__c' ||
      fieldName == 'IDR_Other_Remedy_Provided__c' ||
      fieldName == 'IDR_Other_Remedy_Provided_2__c' ||
      fieldName == 'IDR_Other_Remedy_Provided_3__c' ||
      fieldName == 'IDR_Description_of_Outcome_Offered__c' ||
      fieldName == 'IDR_Other_Remedy_Offered__c'
    ) {
      TextUtils.maskDataCmos(record, fieldName);
    } else {
      record.put(fieldName, TextUtils.maskData((String) record.get(fieldName)));
    }
  }
  /**
   * @description Generates a standard UUID (Universally Unique Identifier)
   * @param hashKey send request body as blob
   * @return A UUID, e.g. 874ddf01-552c-dc25-821b-33c57946632e
   */
  public static String generateUUID(Blob hashKey) {
    String uuid = EncodingUtil.ConvertTohex(
      Crypto.generateDigest('SHA-256', hashKey)
    );
    return uuid.Substring(0, 31);
  }

  /**
   * @description Generates a standard UUID (Universally Unique Identifier)
   * @return A UUID, e.g. 874ddf01-552c-dc25-821b-33c57946632e
   */
  public static String generateUUID() {
    String uuid = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
    return uuid.Substring(0, 8) +
      '-' +
      uuid.SubString(8, 12) +
      '-' +
      uuid.SubString(12, 16) +
      '-' +
      uuid.SubString(16, 20) +
      '-' +
      uuid.substring(20);
  }

  /**
   * @description Generates a traceParent Identifier
   * @return A traceParent, e.g.  00-0af7651916cd43dd8448eb211c80319c-00f067aa0ba902b7-01
   */
  public static String generateTraceParent() {
    String traceParent;
    String traceId = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
    String version = '00';
    String parentId = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
    String traceFlags = '01';
    traceParent =
      version +
      '-' +
      traceId +
      '-' +
      parentId.SubString(0, 16) +
      '-' +
      traceFlags;
    return traceParent;
  }

  /**
   * @param toShaHash value arg to hash
   * @description performs hashing of input value using sha algorithm
   * @return encoded hash
   */
  public static String hashValue(String toShaHash) {
    Blob myBlob = Blob.valueOf(toShaHash);
    Blob shaHash = Crypto.generateDigest('SHA-256', myBlob);
    return EncodingUtil.convertToHex(shaHash);
  }

  /**
   * @description Log an error and throw an exception if user doen't have the required permissions
   * @param processName Process name used to generate the log.
   * @param functionName Name of the funtion to generate the log.
   * @param errorDescription Error description used to create the log record.
   */
  public static void logAndThrowIAE(
    String processName,
    String functionName,
    String errorDescription
  ) {
    Logger.error(errorDescription);
    Logger.saveLog();
    throw new InsufficientAccessException(errorDescription);
  }

  /**
   * @description Logs and return the given exception.
   * Useful for re-throw from caller.
   * @param ex The exception to be logged.
   * @return The logged exception.
   */
  public static Exception logException(Exception ex) {
    Logger.error(ex.getMessage(), ex);
    Logger.saveLog();
    return ex;
  }

  /**
   * @description Logs and return an exception based on error provided in HttpCalloutResponse.
   * Useful for re-throw from caller.
   * @param response The HTTP callout response containing the error information.
   * @return An Exception object representing the logged exception.
   */
  public static Exception logException(HttpCalloutResponse response) {
    return logException(response.error);
  }

  /**
   * @description extend the Exception class to allow errors to be thrown if the user does not have access
   */
  private class InsufficientAccessException extends Exception {
  }
  /**
   * @description Get Profile by Profile Name
   * @param profileName name of the Profile
   * @return Profile
   */
  public static Profile getProfileByName(String profileName) {
    return mapProfileByName.get(profileName);
  }

  /**
   * @description Get UserRole by UserRole DeveloperName
   * @param developerName developer name of the UserRole
   * @return UserRole
   */
  public static UserRole getUserRoleByDevName(String developerName) {
    return mapUserRoleByDevName.get(developerName);
  }

  /**
   * @description Get PermissionSet by PermissionSet Name
   * @param name name of the PermissionSet
   * @return PermissionSet
   */
  public static PermissionSet getPermissionSetByName(String name) {
    return mapPermissionSetByName.get(name);
  }

  /**
   * @description Returns a queue based on the provided name.
   * @param name The name of the queue.
   * @return The Group object associated with the provided name.
   */
  public static Group getQueueByName(String name) {
    return mapQueueByName.get(name);
  }

  /**
   * @description Returns a map of queue records based on the provided set of names.
   * @param names A set of names of the queues.
   * @return A map of Group objects associated with the provided names.
   */
  public static Map<String, Group> getQueueByName(Set<String> names) {
    Map<String, Group> mapQueues = new Map<String, Group>();
    for (String name : names) {
      if (mapQueueByName.containsKey(name)) {
        mapQueues.put(name, mapQueueByName.get(name));
      }
    }
    return mapQueues;
  }

  /**
   * @description Returns a public group based on the provided name.
   * @param name The name of the public group.
   * @return The Group object associated with the provided name.
   */
  public static Group getPublicGroupByName(String name) {
    return mapPublicGroupByName.get(name);
  }

  /**
   * @description Returns a map of public group records based on the provided set of names.
   * @param names A set of names of the public groups.
   * @return A map of Group objects associated with the provided names.
   */
  public static Map<String, Group> getPublicGroupByName(Set<String> names) {
    Map<String, Group> mapPublicGroups = new Map<String, Group>();
    for (String name : names) {
      if (mapPublicGroupByName.containsKey(name)) {
        mapPublicGroups.put(name, mapPublicGroupByName.get(name));
      }
    }
    return mapPublicGroups;
  }

  /**
   * @description Gets the filtered string using Regular Expression
   * @param pattern The RegEx pattern
   * @param matcher The string with which the matching is performed
   * @return returnString The filtered String
   */
  public static String filterStringUsingRegEx(String pattern, String matcher) {
    String returnString;
    Matcher m = System.Pattern.compile(pattern).matcher(matcher);
    if (m.find()) {
      if (pattern == IDRConstants.CASE_NO_REGEX) {
        returnString = m.group().leftPad(8, '0');
      } else {
        returnString = m.group();
      }
    } else {
      returnString = matcher;
    }
    return returnString;
  }

  /**
   * @description Queries through the group object
   * @param type The type of group
   * @param queueName The devveloper name of group
   * @return Group
   */
  public static Group getGroupDetails(String type, String queueName) {
    if (Group.sObjectType.getDescribe().isQueryable()) {
      return [
        SELECT Id
        FROM Group
        WHERE Type = :type AND developername = :queueName
        LIMIT 1
      ];
    } else {
      return null;
    }
  }

  /**
   * @description Get CustomNotificationType by name
   * @param notificationName developer name of the CustomNotificationType
   * @return `CustomNotificationType`
   */
  public static CustomNotificationType getCustomNotificationTypeByName(
    String notificationName
  ) {
    CustomNotificationType notificationType;
    if (Schema.sObjectType.CustomNotificationType.isQueryable()) {
      notificationType = [
        SELECT Id
        FROM CustomNotificationType
        WHERE DeveloperName = :notificationName
      ];
    }

    return notificationType;
  }

  /**
   * @description Send the in app notification
   * @param wrapperRecord wrapper reccord
   */
  public static void sendInAppNotification(
    InAppNotificationWrapper wrapperRecord
  ) {
    Messaging.CustomNotification notification = new Messaging.CustomNotification();
    notification.setBody(wrapperRecord.msgBody);
    notification.setTitle(wrapperRecord.msgTitle);
    notification.setNotificationTypeId(wrapperRecord.notificationTypeId);
    notification.setTargetId(wrapperRecord.targetObjectId);
    try {
      notification.send(wrapperRecord.recipientList);
    } catch (Exception e) {
      Logger.error(
        'Problem sending in app notification: ' +
          wrapperRecord.recipientList +
          e.getMessage(),
        e
      );
      Logger.saveLog();
    }
  }

  /**
   * @description converts a base64url to base64 string
   * @param base64url string to convert
   * @return base64 converted input string
   */
  public static String base64URLToBase64(String base64url) {
    // replace base64url chars to base64
    String base64 = base64URL.replaceAll('-', '+').replaceAll('_', '/');
    // if string length of base64 mod 4 is not equal to 0
    Integer remainder = Math.mod(base64.length(), 4);
    if (remainder != 0) {
      Integer paddingCount = 4 - remainder;
      //update base64 value with padding
      base64 = base64 + '='.repeat(paddingCount);
    }
    return base64;
  }

  /**
   * @description getCaseInsensitiveMap creates a map of lower case values to cased values
   * @param field the object.field to create the map from
   * @return caseInsensitiveMap map of all picklist values with a case insensitive key
   */
  public static Map<String, String> getCaseInsensitiveMap(
    Schema.SobjectField field
  ) {
    Map<String, String> caseInsensitiveMap = new Map<String, String>();
    Schema.DescribeFieldResult fieldPicklist = field.getDescribe();
    for (Schema.PicklistEntry f : fieldPicklist.getPicklistValues()) {
      caseInsensitiveMap.put(f.getValue().toLowerCase(), f.getValue());
    }
    return caseInsensitiveMap;
  }

  /**
   * @description returns the group Id from a Queue Developer Name
   * @param queueDeveloperName string developer name of the queue to search
   * @return Id the Id of the Group or null
   */
  public static Id getGroupId(string queueDeveloperName) {
    List<Group> contactRequestGroup = new List<Group>();
    contactRequestGroup = [
      SELECT Id
      FROM group
      WHERE Type = 'Queue' AND DeveloperName = :queueDeveloperName
    ];

    if (contactRequestGroup.size() > 0) {
      return contactRequestGroup[0].Id;
    }
    return null;
  }

  /**
   * @description return the fields relevant to Case Record Type
   * @param recordTypeDeveloperName the Case record type
   * @return Set<String> return the list of Case fields
   */
  public static Set<String> getDisputeCaseFields(
    String recordTypeDeveloperName
  ) {
    Set<String> caseFields = new Set<String>();
    switch on recordTypeDeveloperName {
      when 'ATM_Dispute' {
        caseFields = getATMDisputeCaseFields();
      }
      when 'BPAY_Dispute' {
        caseFields = getBPAYDisputeCaseFields();
      }
      when 'Card_Dispute' {
        caseFields = getCardDisputeCaseFields();
      }
      when 'Direct_Debit_Dispute' {
        caseFields = getDirectDebitDisputeCaseFields();
      }
      when 'Direct_Entry_Dispute' {
        caseFields = getDirectEntryDisputeCaseFields();
      }
      when 'NPP_Dispute' {
        caseFields = getNPPDisputeCaseFields();
      }
    }
    caseFields.addAll(getDisputeCaseCommonFields());
    return caseFields;
  }

  /**
   * @description return the fields of Dispute Case records
   * @return Set<String> return the list of Case fields
   */
  private static Set<String> getDisputeCaseCommonFields() {
    Set<String> caseFields = new Set<String>();
    caseFields.add('Card_Token_Number__c');
    caseFields.add('CaseNumber');
    caseFields.add('Date_Posted__c');
    caseFields.add('Description');
    caseFields.add('Dispute_Reason__c');
    caseFields.add('Effective_Date__c');
    caseFields.add('External_System__c');
    caseFields.add('External_Case_Id__c');
    caseFields.add('Is_PayTo_Dispute__c');
    caseFields.add('IsStopped');
    caseFields.add('OCV_Id__c');
    caseFields.add('Origin');
    caseFields.add('ParentId');
    caseFields.add('Posted_Amount__c');
    caseFields.add('Posted_Currency__c');
    caseFields.add('Priority');
    caseFields.add('RecordTypeId');
    caseFields.add('Status');
    caseFields.add('StopStartDate');
    caseFields.add('Subject');
    caseFields.add('Submitted__c');
    caseFields.add('Submitted_Time__c');
    caseFields.add('SuppliedEmail');
    caseFields.add('Transaction_Authorised_Date__c');
    caseFields.add('Twilio_Channel_SID__c');
    caseFields.add('Transaction_Amount__c');
    caseFields.add('Transaction_Currency__c');
    caseFields.add('Transaction_Description__c');
    caseFields.add('Transaction_Id__c');
    caseFields.add('Transaction_UUID__c');
    caseFields.add('AccountId');
    caseFields.add('Account.OCV_ID__c');
    caseFields.add('Account.Source_System_Name__c');
    caseFields.add('Account.Source_System_ID__c');
    caseFields.add('FinServ__FinancialAccount__c');
    caseFields.add('Customer_Account_BSB__c');
    caseFields.add('Customer_Account_Number__c');
    caseFields.add('RecordType.DeveloperName');
    caseFields.add('RecordType.Name');
    return caseFields;
  }

  /**
   * @description return the fields of Case record of record type, ATM_Dispute
   * @return Set<String> return the list of Case fields
   */
  private static Set<String> getATMDisputeCaseFields() {
    Set<String> caseFields = new Set<String>();
    caseFields.add('Bank_ATM__c');
    caseFields.add('Card_In_Possession_During_Transaction__c');
    caseFields.add('Card_Number__c');
    caseFields.add('Card_Scheme__c');
    caseFields.add('Claimed_Amount__c');
    caseFields.add('Customer_Contacted_Merchant__c');
    caseFields.add('Has_The_Card_Been_Stopped__c');
    caseFields.add('Is_The_Card_Lost_Stolen__c');
    caseFields.add('Merchant_Description__c');
    caseFields.add('Location__c');
    caseFields.add('Received_Amount__c');
    return caseFields;
  }

  /**
   * @description return the fields of Case record of record type, BPAY_Dispute
   * @return Set<String> return the list of Case fields
   */
  private static Set<String> getBPAYDisputeCaseFields() {
    Set<String> caseFields = new Set<String>();
    caseFields.add('Correct_Customer_Reference_Number__c');
    caseFields.add('Customer_Reference_Number__c');
    return caseFields;
  }

  /**
   * @description return the fields of Case record of record type, Card_Dispute
   * @return Set<String> return the list of Case fields
   */
  private static Set<String> getCardDisputeCaseFields() {
    Set<String> caseFields = new Set<String>();
    caseFields.add('Amount_Of_Authorised_Transaction__c');
    caseFields.add('Amount_Of_Credit_Due__c');
    caseFields.add('Card_In_Possession_During_Transaction__c');
    caseFields.add('Card_Number__c');
    caseFields.add('Card_Scheme__c');
    caseFields.add('Customer_Contacted_Merchant__c');
    caseFields.add('Date_Goods_Were_Returned_Or_Services_can__c');
    caseFields.add('Date_Of_Expected_Delivery_Service__c');
    caseFields.add('Goods_Or_Services_Returned__c');
    caseFields.add('Has_The_Card_Been_Stopped__c');
    caseFields.add('Is_The_Card_Lost_Stolen__c');
    caseFields.add('Merchant_Description__c');
    caseFields.add('Refund_Request_Date__c');
    caseFields.add('Regular_Payment_Cancellation_Date__c');
    caseFields.add('Status');
    return caseFields;
  }

  /**
   * @description return the fields of Case record of record type, Direct_Debit_Dispute
   * @return Set<String> return the list of Case fields
   */
  private static Set<String> getDirectDebitDisputeCaseFields() {
    Set<String> caseFields = new Set<String>();
    return caseFields;
  }

  /**
   * @description return the fields of Case record of record type, Direct_Entry_Dispute
   * @return Set<String> return the list of Case fields
   */
  private static Set<String> getDirectEntryDisputeCaseFields() {
    Set<String> caseFields = new Set<String>();
    caseFields.add('Amount_Of_Authorised_Transaction__c');
    caseFields.add('Intended_Account_BSB__c');
    caseFields.add('Intended_Account_Name__c');
    caseFields.add('Intended_Account_Number__c');
    caseFields.add('Is_this_a_Business_Customer__c');
    return caseFields;
  }

  /**
   * @description return the fields of Case record of record type, NPP_Dispute
   * @return Set<String> return the list of Case fields
   */
  private static Set<String> getNPPDisputeCaseFields() {
    Set<String> caseFields = new Set<String>();
    caseFields.add('Intended_Account_BSB__c');
    caseFields.add('Intended_Account_Name__c');
    caseFields.add('Intended_Account_Number__c');
    caseFields.add('Intended_Amount__c');
    caseFields.add('Intended_Pay_Id_Type__c');
    caseFields.add('Intended_Pay_Id_Value__c');
    return caseFields;
  }

  /**
   * @description return the fields' String to be used in SOQL query
   * @return String fields' String to be used in SOQL query
   */
  public static String getCaseFieldsString() {
    Set<String> caseFields = new Set<String>();
    caseFields.addAll(getDisputeCaseCommonFields());
    caseFields.addAll(getATMDisputeCaseFields());
    caseFields.addAll(getBPAYDisputeCaseFields());
    caseFields.addAll(getCardDisputeCaseFields());
    caseFields.addAll(getDirectDebitDisputeCaseFields());
    caseFields.addAll(getDirectEntryDisputeCaseFields());
    caseFields.addAll(getNPPDisputeCaseFields());
    String fields = String.join((Iterable<String>) caseFields, ', ');
    return fields;
  }

  /**
   * @description return the fields' String to be used in SOQL query
   * @param recordTypeDeveloperName the Case record type
   * @return String fields' String to be used in SOQL query
   */
  public static String getDisputeCaseFieldsString(
    String recordTypeDeveloperName
  ) {
    Set<String> caseFields = getDisputeCaseFields(recordTypeDeveloperName);
    String fields = String.join((Iterable<String>) caseFields, ', ');
    return fields;
  }

  /**
   * @description get the Case record with creating SOQL query relevant to the Case record type
   * @param recordTypeDeveloperName the Case record type
   * @param predicate the condition to be used in filtering
   * @return Case the case record
   */
  public static Case getCaseRecordWithAllFields(
    String recordTypeDeveloperName,
    String predicate
  ) {
    String fields = getDisputeCaseFieldsString(recordTypeDeveloperName);
    List<SObject> sObjectList = Database.query(
      'Select Id, ' +
        String.escapeSingleQuotes(fields) +
        ' From Case Where ' +
        predicate
    );
    Case theCase;
    if (sObjectList.size() > 0) {
      theCase = (Case) sObjectList[0];
    }
    return theCase;
  }

  /**
   * @description throws AuraHandledException with error message
   * @param errorMsg error message to use in the exception
   */
  public static void throwException(String errorMsg) {
    // AuraHandleException is quirky, setMessage() and constructor must be invoked otherwise "Script-thrown exception" is thrown instead of actual exception message
    AuraHandledException e = new AuraHandledException(errorMsg);
    e.setMessage(errorMsg);

    Logger.error(errorMsg, e);
    Logger.saveLog();
    throw e;
  }

  /**
   * @description checks if the user is having given permission sets assigned to it
   * @param userId user Id
   * @param permissionSetNames Set of permission set that needs to be verified
   * @return Boolean if the user is having the permissions assigned to it
   */
  public static Boolean userPermissionCheck(
    Id userId,
    Set<String> permissionSetNames
  ) {
    Boolean isHavingPermission = false;
    List<PermissionSetAssignment> permissionSetAssignments = [
      SELECT PermissionSet.Name
      FROM PermissionsetAssignment
      WHERE AssigneeId = :userId
    ];
    Set<String> assignedPermissionSetGroups = new Set<String>();
    for (PermissionSetAssignment assignment : permissionSetAssignments) {
      assignedPermissionSetGroups.add(assignment.PermissionSet.Name);
    }
    for (String permissionSetName : permissionSetNames) {
      if (assignedPermissionSetGroups.contains(permissionSetName)) {
        isHavingPermission = true;
      }
    }
    return isHavingPermission;
  }

  /**
   * @description Build Trimmed and Concatenated values of Strings
   * @param items  List of Strings
   * @return Trimmed and Concatenated values of items
   */
  public static String buildTrimmedConcatenatedString(List<String> items) {
    List<String> newContents = new List<String>();
    for (String item : items) {
      if (String.isNotBlank(item?.trim())) {
        newContents.add(item.trim());
      }
    }
    return String.join(newContents, ' ');
  }

  /**
   * @description Filter cases by Record Type Id
   * @param records List of case records
   * @param recordTypId Record Type Id
   * @return List of filtered cases
   */
  public static List<Case> filterCasesByRecordTypeId(
    List<Case> records,
    Id recordTypId
  ) {
    List<Case> cases = new List<Case>();
    for (Case c : records) {
      if (c.RecordTypeId == recordTypId) {
        cases.add(c);
      }
    }
    return cases;
  }

  /**
   * @description Get SLA Process by process name
   * @param slaProceessName SLA Process name
   * @return SlaProcess
   */
  public static SlaProcess getSLAProcess(String slaProceessName) {
    if (
      String.isBlank(slaProceessName) ||
      PermissionUtils.canQuery('SlaProcess') == false
    ) {
      return null;
    }

    return [
      SELECT Id, Name
      FROM SlaProcess
      WHERE
        Name = :slaProceessName
        AND IsActive = TRUE
        AND IsVersionDefault = TRUE
      LIMIT 1
    ];
  }

  /**
   * @description Add Person Account Entitlements
   * @param accs List of Accounts
   * @param slaProceessName SLA Process name
   * @param entitlementName Entitlement Name
   * @return List of Entitlements
   */
  public static List<Entitlement> addPersonAccountEntitlements(
    List<Account> accs,
    String slaProceessName,
    String entitlementName
  ) {
    SlaProcess sla = getSLAProcess(slaProceessName);

    List<Entitlement> entitlements = new List<Entitlement>();
    for (Account acc : accs) {
      entitlements.add(
        new Entitlement(
          Name = entitlementName,
          AccountId = acc.Id,
          StartDate = System.today(),
          SlaProcessId = sla?.Id
        )
      );
    }

    return entitlements;
  }

  /**
   * @description This method returns a RecordType instance based on RecordTypeId
   * @param recordTypeId Id of the record type
   * @return RecordType instance based on RecordTypeId
   */
  public static RecordType getRecordTypeDeveloperName(Id recordTypeId) {
    if (String.isNotBlank(recordTypeId)) {
      return [
        SELECT DeveloperName, Id
        FROM RecordType
        WHERE Id = :recordTypeId
      ];
    }
    return null;
  }

  /**
   * @description Remove extra spaces of content String
   * @param content String
   * @return Removed extra spaces of content String
   */
  public static String removeExtraSpaces(String content) {
    if (content != null) {
      return buildTrimmedConcatenatedString(content.split(' '));
    }
    return null;
  }

  /**
   * @description Get Profile by Profile Name
   * @param lstOfProfileName set of name of the Profile
   * @return Map<String,Id> ids of profiles.
   */
  public static Map<String, Id> getProfileByNames(
    List<String> lstOfProfileName
  ) {
    Map<String, Id> mapOfProfileId = new Map<String, Id>();
    for (Profile prof : [
      SELECT Id, Name
      FROM Profile
      WHERE Name IN :lstOfProfileName
    ]) {
      mapOfProfileId.put(prof.Name, prof.Id);
    }

    return mapOfProfileId;
  }

  /**
   * @description Get list of street addresses by breaking street address in list of 40 each
   * @param streetAddress street address
   * @return Map<Integer,String> streets address map
   */
  public static Map<Integer, String> getStreetAddress(String streetAddress) {
    Map<Integer, String> streetAddressMap = new Map<Integer, String>{
      1 => '',
      2 => '',
      3 => ''
    };
    streetAddressMap.put(
      1,
      (streetAddress.length() >= 40
        ? streetAddress.substring(0, 39)
        : streetAddress)
    );
    streetAddressMap.put(
      2,
      (streetAddress.length() >= 80
        ? streetAddress.substring(40, 79)
        : streetAddress.length() > 40
            ? streetAddress.substring(40, (streetAddress.length() - 1))
            : null)
    );
    streetAddressMap.put(
      3,
      (streetAddress.length() >= 120
        ? streetAddress.substring(80, 119)
        : streetAddress.length() > 80
            ? streetAddress.substring(80, (streetAddress.length() - 1))
            : null)
    );
    return streetAddressMap;
  }
  /**
   * @description This function will encode the blob input to base64 url encoded
   * @param blobInput blob input to be base64URLencode
   * @return String base64 url encoded value
   */
  public static String base64URLencode(Blob blobInput) {
    String output = EncodingUtil.base64Encode(blobInput);
    output = output.replace('+', '-');
    output = output.replace('/', '_');
    while (output.endsWith('=')) {
      output = output.subString(0, output.length() - 1);
    }
    return output;
  }

  /**
   * @description This function will convert the input string into blob and then encode the blob input to base64 url encoded
   * @param stringInput string input to be base64URLencode
   * @return String base64 url encoded value
   */
  public static String base64URLencode(String stringInput) {
    return base64URLencode(Blob.valueOf(stringInput));
  }

  /**
   * @description This function will provide the RSA algorithm name for given hash
   * @param hash algorithm hash
   * @return String Algorithm for the given hash
   */
  public static string getAlgorithmNamefromHash(String hash) {
    if (hash == 'RS256') {
      return 'RSA-SHA256';
    } else if (hash == 'RS512') {
      return 'RSA-SHA512';
    }
    return '';
  }

  /**
   * @description capture field API names from a fieldset
   * @param fieldset the fieldSet to capture
   * @return Set<String> set of field API names
   */
  public static Set<String> getFieldSet(Schema.FieldSet fieldset) {
    Set<String> fields = new Set<String>();
    for (Schema.FieldSetMember field : fieldset.getFields()) {
      fields.add(field.fieldpath);
    }
    return fields;
  }

  /**
   * @description Add error on the record and log message
   * @param record record to add error
   * @param errorMsg error message to use in the addError
   */
  public static void addErrorToRecordAndLog(SObject record, String errorMsg) {
    Logger.error(errorMsg);
    Logger.saveLog();
    record.addError(errorMsg);
  }
}
