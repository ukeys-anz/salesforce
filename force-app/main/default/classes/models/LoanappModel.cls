/**
 * @author Prahlad Bhadani
 * @since  November 2024
 * @group  Platform
 * @description Create Application JSON request model wrapper.
 */
@SuppressWarnings('PMD.FieldNamingConventions')
public class LoanappModel {
  public loan_application loan_application;
  public String request_id;
  public String target;
  /**
   * @description model for Year
   */
  public class Year {
    public Integer value;
  }
  /**
   * @description model for Properties
   */
  public class Properties {
    public Boolean approval_in_principle;
  }
  /**
   * @description model for Preferences
   */
  public class Preferences {
    public expected_settlement_date expected_settlement_date;
    public String rba_lending_purpose;
    public list<funds> funds;
  }
  /**
   * @description model for Originator
   */
  public class Originator {
    public String tpmi;
  }
  /**
   * @description model for Month
   */
  public class Month {
    public Integer value;
  }
  /**
   * @description model for Loan_writer
   */
  public class Loan_writer {
    public String uid;
    public String lan_id;
  }
  /**
   * @description model for Loan_application
   */
  public class Loan_application {
    public List<preferences> preferences;
    public loan_writer loan_writer;
    public List<properties> properties;
    public originator originator;
    public List<households> households;
    public branch branch;
    public String name;
  }
  /**
   * @description model for Households
   */
  public class Households {
    public list<applicants> applicants;
  }
  /**
   * @description model for Funds
   */
  public class Funds {
    public amount amount;
  }
  /**
   * @description model for Expected_settlement_date
   */
  public class Expected_settlement_date {
    public year year;
    public day day;
    public month month;
  }
  /**
   * @description model for Day
   */
  public class Day {
    public Integer value;
  }
  /**
   * @description model for Branch
   */
  public class Branch {
    public String bsb;
  }
  /**
   * @description model for Applicants
   */
  public class Applicants {
    public List<String> external_references;
    public String type;
    public String uid;
  }
  /**
   * @description model for Amount
   */
  public class Amount {
    public String currency_code;
    public Decimal units;
  }
}
