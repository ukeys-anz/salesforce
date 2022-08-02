/**
 * @author Lance Shi
 * @since July 2022
 * @description InteractionRelatedListController is apex side controller for interaction related list LWC
 */
public with sharing class InteractionRelatedListController {
  /**
   * @description get interaction list to be displayed on interaction tab in lwc
   * @param sId Id to pass through to gather a records object context
   * @param maxNumber max number of records displayed in main page
   * @return list of interactions wrapped in a wrapper class
   */
  @AuraEnabled
  public static List<InteractionWrapper> getInteractions(
    Id sId,
    Integer maxNumber
  ) {
    String interactionQuery = buildQueryStr(sId);
    //To avoid dynamic query error
    interactionQuery +=
      ' AND RecordTypeId != \'' +
      InteractionConstants.APPOINTMENT_RECORD_TYPE_ID +
      '\'';

    interactionQuery += ' ORDER BY CreatedDate desc';
    interactionQuery += ' LIMIT ' + maxNumber;
    List<Interaction> interactionList = new List<Interaction>();
    if (PermissionUtils.canQuery('Interaction')) {
      interactionList = (List<Interaction>) Database.query(interactionQuery);
    }

    List<InteractionWrapper> wrapperList = new List<InteractionWrapper>();
    for (Interaction record : interactionList) {
      wrapperList.add(new InteractionWrapper(record));
    }
    return wrapperList;
  }

  /**
   * @description get appointments list to be displayed on appointment tab in lwc
   * @param sId Id to pass through to gather a records object context
   * @param maxNumber max number of records displayed in main page
   * @return list of appointments wrapped in a wrapper class
   */
  @AuraEnabled
  public static List<InteractionWrapper> getAppointments(
    Id sId,
    Integer maxNumber
  ) {
    String interactionQuery = buildQueryStr(sId);
    interactionQuery +=
      ' AND RecordTypeId = \'' +
      InteractionConstants.APPOINTMENT_RECORD_TYPE_ID +
      '\'';
    interactionQuery += ' ORDER BY CreatedDate desc';
    interactionQuery += ' LIMIT ' + maxNumber;
    List<Interaction> interactionList = new List<Interaction>();
    if (PermissionUtils.canQuery('Interaction')) {
      interactionList = (List<Interaction>) Database.query(interactionQuery);
    }
    List<InteractionWrapper> wrapperList = new List<InteractionWrapper>();
    for (Interaction record : interactionList) {
      wrapperList.add(new InteractionWrapper(record));
    }
    return wrapperList;
  }

  /**
   * @description get related lookup field name and record type id of the current context
   * @param sId Id to pass through to gather a records object context
   * @param isAppointment check whether current tab is appointment
   * @return field name and record type id in a wrapper class
   */
  @AuraEnabled
  public static NewRecordWrapper getNewRecordInfo(
    Id sId,
    Boolean isAppointment
  ) {
    String sobjectType = sId.getSObjectType().getDescribe().getName();
    String fieldName = '';
    switch on sobjectType {
      when 'Account' {
        fieldName = 'AccountId';
      }
      when 'Case' {
        fieldName = 'CaseId__c';
      }
      when 'Coaching_Summary__c' {
        fieldName = 'Coaching_Summary__c';
      }
      when 'Interaction' {
        fieldName = 'Appointment__c';
      }
      when 'Lead' {
        fieldName = 'Lead__c';
      }
    }

    NewRecordWrapper nrWrapper = new NewRecordWrapper();
    nrWrapper.fieldName = fieldName;

    if (isAppointment) {
      nrWrapper.recordTypeInfo = GetHelpConstants.INTERACTION_APPT_RT_ID;
    } else {
      nrWrapper.recordTypeInfo = GetHelpConstants.INTERACTION_GENERAL_RT_ID;
    }

    return nrWrapper;
  }

  /**
   * @description get sobject type of the current context
   * @param sId Id to pass through to gather a records object context
   * @return sobject type
   */
  @AuraEnabled
  public static String getSObjectType(Id sId) {
    return sId.getSObjectType().getDescribe().getName();
  }

  /**
   * @description private method to build query string for interactions and appointments
   * @param sId Id to pass through to gather a records object context
   * @return query string to be used in appointments and interactions query
   */
  private static String buildQueryStr(Id sId) {
    String interactionQuery = 'SELECT Id, Name, Owner.Name, StartTime FROM Interaction WHERE ';
    String sobjectType = sId.getSObjectType().getDescribe().getName();
    switch on sobjectType {
      when 'Account' {
        interactionQuery += 'AccountId = :sId';
      }
      when 'Case' {
        interactionQuery += 'CaseId__c = :sId';
      }
      when 'Coaching_Summary__c' {
        interactionQuery += 'Coaching_Summary__c = :sId';
      }
      when 'Interaction' {
        interactionQuery += 'Appointment__c = :sId';
      }
      when 'Lead' {
        interactionQuery += 'Lead__c = :sId';
      }
    }
    return interactionQuery;
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

    /**
     * @description constructor of wrapper class to turn an interaction sobject into wrapper record
     * @param record Interaction record to be converted into wrapper record
     */
    public InteractionWrapper(Interaction record) {
      this.interactId = record.Id;
      this.interactName = record.Name;
      this.ownerName = record.Owner.Name;
      if (record.StartTime != null) {
        this.interactTime = record.StartTime.format('dd/MM/yyyy h:mm a');
      } else {
        this.interactTime = '';
      }
    }
  }

  /**
   * @description wrapper class to wrap new interaction record information
   */
  public with sharing class NewRecordWrapper {
    @AuraEnabled
    public String fieldName;
    @AuraEnabled
    public String recordTypeInfo;
  }
}
