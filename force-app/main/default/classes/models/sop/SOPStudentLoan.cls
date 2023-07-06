/**
 * @author Lance Shi
 * @since Jun 2023
 * @description model for SOP student loan
 * @group Models
 */
public class SOPStudentLoan {
    public Boolean hecsWithheldPayment;

    /**
     * @description return Yes or No for withheld value
     */
    public String outputWithheld {
      get {
        if (hecsWithheldPayment) {
          return 'Yes';
        } else {
          return 'No';
        }
      }
    }
  }