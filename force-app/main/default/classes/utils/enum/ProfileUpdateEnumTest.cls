@isTest
private class ProfileUpdateEnumTest {
  @IsTest
  static void testCaseIssueType() {
    Test.startTest();
    String sfKey = ProfileUpdateEnum.issueType.getSfKey(
      'CASE_ISSUE_TYPE_LEGAL_NAME_UPDATE'
    );
    String protoKey = ProfileUpdateEnum.issueType.getProtoKey(
      'Legal Name Update'
    );
    Test.stopTest();

    Assert.areEqual(
      'Legal Name Update',
      sfKey,
      'value should match the salesforce picklist value'
    );

    Assert.areEqual(
      'CASE_ISSUE_TYPE_LEGAL_NAME_UPDATE',
      protoKey,
      'key should match the Proto Enum key'
    );
  }
  @IsTest
  static void testCasePriority() {
    Test.startTest();
    String sfKey = ProfileUpdateEnum.priority.getSfKey('CASE_PRIORITY_HIGH');
    String protoKey = ProfileUpdateEnum.priority.getProtoKey('High');
    Test.stopTest();

    Assert.areEqual(
      'High',
      sfKey,
      'value should match the salesforce picklist value'
    );
    Assert.areEqual(
      'CASE_PRIORITY_HIGH',
      protoKey,
      'key should match the Proto Enum key'
    );
  }

  @IsTest
  static void testCaseStatus() {
    Test.startTest();
    String sfKey = ProfileUpdateEnum.status.getSfKey('CASE_STATE_OPEN');
    String protoKey = ProfileUpdateEnum.status.getProtoKey('Open');
    Test.stopTest();

    Assert.areEqual(
      'Open',
      sfKey,
      'value should match the salesforce picklist value'
    );
    Assert.areEqual(
      'CASE_STATE_OPEN',
      protoKey,
      'key should match the Proto Enum key'
    );
  }
  @IsTest
  static void testCaseSubStatus() {
    Test.startTest();
    String sfKey = ProfileUpdateEnum.subStatus.getSfKey(
      'CASE_SUB_STATE_NO_DEFECT'
    );
    String protoKey = ProfileUpdateEnum.subStatus.getProtoKey('No Defect');
    Test.stopTest();

    Assert.areEqual(
      'No Defect',
      sfKey,
      'value should match the salesforce picklist value'
    );
    Assert.areEqual(
      'CASE_SUB_STATE_NO_DEFECT',
      protoKey,
      'key should match the Proto Enum key'
    );
  }
  @IsTest
  static void testChannelReceived() {
    Test.startTest();
    String sfKey = ProfileUpdateEnum.channelReceived.getSfKey(
      'CHANNEL_RECEIVED_ANZ_PLUS_APP'
    );
    String protoKey = ProfileUpdateEnum.channelReceived.getProtoKey(
      'ANZ Plus App'
    );
    Test.stopTest();

    Assert.areEqual(
      'ANZ Plus App',
      sfKey,
      'value should match the salesforce picklist value'
    );
    Assert.areEqual(
      'CHANNEL_RECEIVED_ANZ_PLUS_APP',
      protoKey,
      'key should match the Proto Enum key'
    );
  }

  @IsTest
  static void testYesNo() {
    Test.startTest();
    String sfKey = ProfileUpdateEnum.yesNoList.getSfKey('YES_NO_LIST_YES');
    String protoKey = ProfileUpdateEnum.yesNoList.getProtoKey('No');
    Test.stopTest();

    Assert.areEqual(
      'Yes',
      sfKey,
      'value should match the salesforce picklist value'
    );
    Assert.areEqual(
      'YES_NO_LIST_NO',
      protoKey,
      'key should match the Proto Enum key'
    );
  }
}
