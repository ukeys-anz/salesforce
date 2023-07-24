/**
 * @author Lance Shi
 * @since Jun 2023
 * @description model for SOP interest rate
 * @group Models
 */
public class SOPInterestRate {
  public string value;

  /**
   * @description return a readable interest rate value
   */
  public string readableValue {
    get {
      try {
        Decimal givenValue = Decimal.valueOf(value);
        String result = (givenValue / 100).setScale(2) + '%';
        return result;
      } catch (Exception e) {
        return 'Not Provided';
      }
    }
  }
}
