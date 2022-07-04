/**
 * @author Adam Smith
 * @since 20220620
 * @description class for Interaction Constants
 */
public with sharing class InteractionConstants {
  public static final String APPOINTMENTS_QUEUE = 'Appointments_Queue';
  public static final String CONTACT_REQUEST_QUEUE = 'Contact Request';
  public static final String APPOINTMENT_QUEUE_NAME = 'Appointments Queue';
  public static final String SCHEDULED_STATUS = 'Scheduled';
  public static final String ASSIGNED_STATUS = 'Assigned';
  public static final String UNASSIGNED_STATUS = 'Unassigned';
  public static final String RESCHEDULED_STATUS = 'Rescheduled';
  public static final String INPROGRESS_STATUS = 'In Progress';
  public static final String CANCELLED_STATUS = 'Cancelled';
  public static final String WALKIN_STATUS = 'Walk In';
  public static final String NEW_STATUS = 'New';
  public static final String COACHING_SUMMARY_LABEL = ' Coaching Summary';
  public static final String NO_SHOW_STATUS = 'No Show';
  public static final String OTHER_PURPOSE_NAME = 'Other';
  public static final string FINANCIAL_WELLBEING_PURPOSE_NAME = 'Financial Wellbeing';
  public static final string APPOINTMENT_RECORD_TYPE_NAME = 'Appointment';
  public static final String CALL = 'Call';
  public static final String CHAT = 'Chat';
  public static final String STORE = 'Store';
  public static final String CANCELLED = 'Cancelled';
  public static final Id APPOINTMENT_RECORD_TYPE_ID = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
    .get(InteractionConstants.APPOINTMENT_RECORD_TYPE_NAME)
    .getRecordTypeId();

  public static final Set<String> UNIQUE_STATUSES = new Set<String>{
    UNASSIGNED_STATUS,
    SCHEDULED_STATUS,
    RESCHEDULED_STATUS,
    WALKIN_STATUS
  };

  public static final Id APPOINTMENT_QUEUE_ID = CommonUtil.getGroupId(
    APPOINTMENTS_QUEUE
  );
}
