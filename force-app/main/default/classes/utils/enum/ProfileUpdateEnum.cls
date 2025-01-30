/**
 * @author Mani
 * @since 01/2025
 * @description This acts as a Proto Enum Mapper service, convert the salesforce picklist value to Proto Enum and vice versa
 * refer https://github.com/anzx/apis/blob/main/anz/salesforceapis/salesforce/service/profileupdate/v1alpha1/profileupdate_type.proto
 */
public with sharing class ProfileUpdateEnum {
  private static final string VERSION = 'salesforce.service.profileupdate.v1alpha1';
  private static final string SOURCE = 'enum_ProfileUpdate_v1alpha1';
  public static EnumAPI issueType = new EnumAPI(
    SOURCE,
    VERSION,
    'CaseIssueType'
  );
  public static EnumAPI priority = new EnumAPI(SOURCE, VERSION, 'CasePriority');
  public static EnumAPI status = new EnumAPI(SOURCE, VERSION, 'CaseState');
  public static EnumAPI subStatus = new EnumAPI(
    SOURCE,
    VERSION,
    'CaseSubState'
  );
  public static EnumAPI channelReceived = new EnumAPI(
    SOURCE,
    VERSION,
    'ChannelReceived'
  );
  public static EnumAPI yesNoList = new EnumAPI(SOURCE, VERSION, 'YesNoList');
}
