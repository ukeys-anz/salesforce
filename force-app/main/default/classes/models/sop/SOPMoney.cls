/**
 * @author @fangl6(Lei Fang)
 * @since April 2023
 * @description model for money type
 * @group Models
 */
public class SOPMoney {
  public String currencyCode;
  public String units;
  public Integer nanos;
  /**
   * @description calculated value
   */
  public Decimal value {
    get {
      //Need to check if units and nanos exist as they aren't always returned
      Decimal unitValue = String.isNotBlank(this.units)
        ? decimal.valueOf(this.units)
        : 0;
      Decimal nanoValue = this.nanos != null ? this.nanos : 0;
      return unitValue + (nanoValue / 1000000000);
    }
  }

  /**
   * @description calculated minus value used for debts
   */
  public Decimal minusValue {
    get {
      if (value > 0) {
        return -value;
      } else {
        return value;
      }
    }
  }
}
