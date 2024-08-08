@IsTest
private class RecordComparisonUtilTest {
  @IsTest
  static void testAllFieldsWereChangedPositive() {
    Case oldCase = TestDataFactory.createATMDisputeCase();
    Case newCase = TestDataFactory.createATMDisputeCase();
    newCase.Received_Amount__c = oldCase.Received_Amount__c + 10;
    newCase.Submitted__c = true;

    Set<SObjectField> fields = new Set<SObjectField>{
      Case.Received_Amount__c,
      Case.Submitted__c
    };

    Boolean result = RecordComparisonUtil.allFieldsWereChanged(
      newCase,
      oldCase,
      fields
    );
    System.assertEquals(
      true,
      result,
      'All fields should have been detected as changed.'
    );
  }

  @IsTest
  static void testAllFieldsWereChangedNegative() {
    Case oldCase = TestDataFactory.createATMDisputeCase();
    Case newCase = TestDataFactory.createATMDisputeCase();
    newCase.Received_Amount__c = oldCase.Received_Amount__c + 10;

    Set<SObjectField> fields = new Set<SObjectField>{
      Case.Received_Amount__c,
      Case.Submitted__c
    };

    Boolean result = RecordComparisonUtil.allFieldsWereChanged(
      newCase,
      oldCase,
      fields
    );
    System.assertEquals(
      false,
      result,
      'All fields should not have been detected as changed.'
    );
  }

  @IsTest
  static void testAllFieldsWereChangedAndNotEqualNullPositive() {
    Case oldCase = TestDataFactory.createATMDisputeCase();
    Case newCase = TestDataFactory.createATMDisputeCase();
    newCase.Received_Amount__c = oldCase.Received_Amount__c + 10;
    newCase.Description = 'Some description';

    Set<SObjectField> fields = new Set<SObjectField>{
      Case.Received_Amount__c,
      Case.Description
    };

    Boolean result = RecordComparisonUtil.allFieldsWereChangedAndNotEqualNull(
      newCase,
      oldCase,
      fields
    );
    System.assertEquals(
      true,
      result,
      'All fields should have been detected as changed and not equal to null.'
    );
  }

  @IsTest
  static void testAllFieldsWereChangedAndNotEqualNullNegative() {
    Case oldCase = TestDataFactory.createATMDisputeCase();
    Case newCase = TestDataFactory.createATMDisputeCase();
    newCase.Received_Amount__c = oldCase.Received_Amount__c + 10;
    newCase.Description = oldCase.Description;

    Set<SObjectField> fields = new Set<SObjectField>{
      Case.Received_Amount__c,
      Case.Description
    };

    Boolean result = RecordComparisonUtil.allFieldsWereChangedAndNotEqualNull(
      newCase,
      oldCase,
      fields
    );
    System.assertEquals(
      false,
      result,
      'All fields should not have been detected as changed.'
    );
  }

  @IsTest
  static void testAtLeastOneFieldWasChangedPositive() {
    Case oldCase = TestDataFactory.createATMDisputeCase();
    Case newCase = TestDataFactory.createATMDisputeCase();
    newCase.Received_Amount__c = oldCase.Received_Amount__c + 10;

    Set<SObjectField> fields = new Set<SObjectField>{
      Case.Received_Amount__c,
      Case.Description
    };

    Boolean result = RecordComparisonUtil.atLeastOneFieldWasChanged(
      newCase,
      oldCase,
      fields
    );
    System.assertEquals(
      true,
      result,
      'At least one field should have been detected as changed.'
    );
  }

  @IsTest
  static void testAtLeastOneFieldWasChangedNegative() {
    Case newCase = TestDataFactory.createATMDisputeCase();
    Case oldCase = TestDataFactory.createATMDisputeCase();

    Set<SObjectField> fields = new Set<SObjectField>{
      Case.Received_Amount__c,
      Case.Description
    };

    Boolean result = RecordComparisonUtil.atLeastOneFieldWasChanged(
      newCase,
      oldCase,
      fields
    );
    System.assertEquals(
      false,
      result,
      'No field should have been detected as changed.'
    );
  }

  @IsTest
  static void testAtLeastOneFieldWasChangedAndNotEqualNullPositive() {
    Case oldCase = TestDataFactory.createATMDisputeCase();
    Case newCase = TestDataFactory.createATMDisputeCase();
    newCase.Received_Amount__c = oldCase.Received_Amount__c + 10;

    Set<SObjectField> fields = new Set<SObjectField>{
      Case.Received_Amount__c,
      Case.Description
    };

    Boolean result = RecordComparisonUtil.atLeastOneFieldWasChangedAndNotEqualNull(
      newCase,
      oldCase,
      fields
    );
    System.assertEquals(
      true,
      result,
      'At least one field should have been detected as changed and not null.'
    );
  }

  @IsTest
  static void testAtLeastOneFieldWasChangedAndNotEqualNullNegative() {
    Case oldCase = TestDataFactory.createATMDisputeCase();
    Case newCase = TestDataFactory.createATMDisputeCase();
    newCase.Received_Amount__c = null;

    Set<SObjectField> fields = new Set<SObjectField>{
      Case.Received_Amount__c,
      Case.Description
    };

    Boolean result = RecordComparisonUtil.atLeastOneFieldWasChangedAndNotEqualNull(
      newCase,
      oldCase,
      fields
    );
    System.assertEquals(
      false,
      result,
      'No field should have been detected as changed and not null.'
    );
  }

  @IsTest
  static void testFieldWasChanged() {
    Case oldCase = TestDataFactory.createATMDisputeCase();
    Case newCase = TestDataFactory.createATMDisputeCase();
    newCase.Received_Amount__c = null;

    Boolean result = RecordComparisonUtil.fieldWasChanged(
      newCase,
      oldCase,
      Case.Received_Amount__c
    );
    System.assertEquals(
      true,
      result,
      'The Received_Amount__c field should have been detected as changed.'
    );
  }

  @IsTest
  static void testFieldWasChangedAndNotEqualNull() {
    Case oldCase = TestDataFactory.createATMDisputeCase();
    Case newCase = TestDataFactory.createATMDisputeCase();
    newCase.Received_Amount__c = oldCase.Received_Amount__c + 10;

    Boolean result = RecordComparisonUtil.fieldWasChangedAndNotEqualNull(
      newCase,
      oldCase,
      Case.Received_Amount__c
    );
    System.assertEquals(
      true,
      result,
      'The Received_Amount__c field should have been detected as changed and not equal to null.'
    );
  }

  @IsTest
  static void testDetectWhichFieldWasChangedAndNotEqualNullPositive() {
    Case oldCase = TestDataFactory.createATMDisputeCase();
    Case newCase = TestDataFactory.createATMDisputeCase();
    newCase.Received_Amount__c = oldCase.Received_Amount__c + 10;

    List<SObjectField> result = RecordComparisonUtil.detectWhichFieldWasChangedAndNotEqualNull(
      newCase,
      oldCase,
      new Set<SObjectField>{
        Case.Received_Amount__c.getDescribe().getSObjectField()
      }
    );
    System.assertEquals(
      'Received_Amount__c',
      String.ValueOf(result[0]),
      'The Received_Amount__c field is changed on above record'
    );
  }

  @IsTest
  static void testDetectWhichFieldWasChangedAndNotEqualNullNegative() {
    Case oldCase = TestDataFactory.createATMDisputeCase();
    Case newCase = TestDataFactory.createATMDisputeCase();
    newCase.Description = 'Test on New Record';

    List<SObjectField> result = RecordComparisonUtil.detectWhichFieldWasChangedAndNotEqualNull(
      newCase,
      oldCase,
      new Set<SObjectField>{
        Case.Received_Amount__c.getDescribe().getSObjectField()
      }
    );
    System.assertNotEquals(
      'Description',
      String.ValueOf(result.isEmpty()),
      'No field from the provided set has been updated'
    );
  }
}
