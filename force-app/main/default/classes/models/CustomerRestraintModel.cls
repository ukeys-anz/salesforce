/**
 * @author Tan Phan
 * @since 09/2024
 * @description This class represents a customer restraint model.
 */
public with sharing class CustomerRestraintModel {
  public String accountNumber;
  public String productCode;
  public Restraint restraints = new Restraint();

  /**
   * @description Represents restraint details.
   */
  public class Restraint {
    public Integer restraintClass;
    public Integer restraintType;
    public String datePlaced;
    public String dateExpires;
    public String specialComment1;
    public String specialComment2;
    public String specialComment3;
    public Integer sequence;
  }
}
