/**
 *
 * @author Lance Shi
 * @since 04/2020
 * @description CaseDurationServerControllerTest is the test class to cover tests for {@link CaseDurationServerController}
 */
@isTest
public class CaseDurationServerControllerTest {
  /**
   * @description testCalculateDuration is to test the functionality of lwc caseDuration's server controller
   */
  @isTest
  public static void testCalculateDuration() {
    Case newCase = new Case();
    newCase.Status = 'Open';
    insert newCase;

    newCase.Status = 'Under Investigation';
    update newCase;

    CaseDurationServerController.DurationTime durationTime = CaseDurationServerController.getCaseDurationTime(
      newCase.Id
    );
    System.assertEquals(0, durationTime.durationHours);
  }
}
