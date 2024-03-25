/**
 * @author Batya Aisman Sufrin
 * @since February 2024
 * @description test class for COBRASErrorModel class
 * @group Models
 */
@isTest
private class COBRASErrorModelTest {
  @isTest
  static void testParse() {
    String json =
      '{' +
      '    \"code\": \"failed_precondition\",' +
      '    \"message\": \"assisted request not expected\", ' +
      '    \"details\": [' +
      '        {' +
      '            \"type\": \"ribbon.service.assistance.v1alpha1.ErrorDetails\",' +
      '            \"value\": \"CAI\",' +
      '            \"debug\": {' +
      '                \"@type\": \"type.googleapis.com/ribbon.service.assistance.v1alpha1.ErrorDetails\",' +
      '                \"cxOnboardingStage\": \"STAGE_TNC\" ' +
      '            }' +
      '        }' +
      '    ]' +
      '}';

    COBRASErrorModel obj;
    try {
      obj = COBRASErrorModel.parse(json);
    } catch (Exception e) {
      System.debug('#### Exception: ' + e);
    }
    Assert.areEqual(
      'STAGE_TNC',
      obj.details[0].debug.cxOnboardingStage,
      'The cxOnboardingStage should be STAGE_TNC.'
    );
  }
}
