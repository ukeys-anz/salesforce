/**
 * @author Igor Matkovic
 * @since 22/07/2018
 * @group faker
 * @description  Class extending FakerBase which defines basic data test providers.
 */
public with sharing class Faker extends FakerBase {
  public FakerPersonProvider person;
  public FakerAddressProvider address;
  public FakerTextProvider text;
  public FakerInternetProvider internet;

  /**
   * @description Default constructor for Faker class which takes locale as a String.
   * @param locale locale as a String
   */
  public Faker(String locale) {
    // Here is where the IF will go
    this.person = new FakerUsPersonProvider();
    this.address = new FakerUsAddressProvider();
    this.text = new FakerUsTextProvider();
    this.internet = new FakerInternetProvider(this.person, this.text);
  }
}
