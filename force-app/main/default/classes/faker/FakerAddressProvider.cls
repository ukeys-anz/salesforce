/**
 * @author Igor Matkovic
 * @since 09/07/2018
 * @group Faker
 * @description  Class extending FakerBase which defines FakerAddressProvider.
 * ExcessivePublicCount Surpressed : FakerAddressProvider to have all the public methods and attributes together.
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing virtual class FakerAddressProvider extends FakerBase {
  public List<String> streetSuffix;
  public List<String> streetPrefix;
  public List<String> country;
  public List<String> state;
  public List<String> stateCode;
  public List<String> street;
  public List<String> city;

  public List<String> streetAddressFormats = new List<String>{
    '### {{streetPrefix}} {{street}}',
    '## {{street}}',
    '{{buildingNumber}} {{street}} {{streetSuffix}} ?##',
    '### {{streetPrefix}} {{street}} {{streetSuffix}}'
  };

  public List<String> addressFormats = new List<String>{
    '### {{street}}, {{city}} {{zip}}',
    '##  {{streetPrefix}} {{street}} {{unit}}, {{city}} #####',
    '### {{streetPrefix}} {{street}}, {{city}} #####',
    '### {{street}} {{streetSuffix}}, {{city}} #####-###',
    '##  {{street}} {{streetSuffix}} {{unit}}, {{city}} #####-###',
    '### {{streetPrefix}} {{street}} {{streetSuffix}}, {{city}} #####'
  };

  /**
   * @description Initialise address related attributes
   */
  public void init() {
    this.mapValues = new Map<String, List<String>>();
    this.mapValues.put('city', this.city);
    this.mapValues.put('country', this.country);
    this.mapValues.put('state', this.state);
    this.mapValues.put('stateCode', this.stateCode);
    this.mapValues.put('street', this.street);
    this.mapValues.put('streetPrefix', this.streetPrefix);
    this.mapValues.put('streetSuffix', this.streetSuffix);
  }

  /**
   * @description Replaces address attribute placeholders on the input String with fake generated values
   * @param element String with attribute placeholders to replace with respective (fake) values
   * @return `String` String with generated values
   */
  public override String generate(String element) {
    element = element.replace('{{zip}}', String.valueOf(this.zip()));
    element = element.replace('{{buildingNumber}}', this.buildingNumber());
    element = element.replace('{{unit}}', this.unit());

    return element;
  }

  /**
   * @description Generates a random city.
   * @return `String` Random city
   */
  public String city() {
    return this.randomElement(this.city);
  }

  /**
   * @description Generates a random country.
   * @return `String` Random country
   */
  public String country() {
    return this.randomElement(this.country);
  }

  /**
   * @description Generates a random state.
   * @return `String` Random state
   */
  public String state() {
    return this.randomElement(this.state);
  }

  /**
   * @description Generates a random street.
   * @return `String` Random street
   */
  public String street() {
    return this.generate(this.randomElement(this.streetAddressFormats));
  }

  /**
   * @description Generates a random street prefix.
   * @return `String` Random street prefix
   */
  public String streetPrefix() {
    return this.randomElement(this.streetPrefix);
  }

  /**
   * @description Generates a random street suffix.
   * @return `String` Random street suffix
   */
  public String streetSuffix() {
    return this.randomElement(this.streetSuffix);
  }

  /**
   * @description Generates a random unit number.
   * @return `String` Random unit number
   */
  public String unit() {
    return this.randomString(1) + String.valueOf(this.randomInteger(3));
  }

  /**
   * @description Generates a random building number.
   * @return `String` Random building number
   */
  public String buildingNumber() {
    return String.valueOf(this.randomInteger(3));
  }

  /**
   * @description Generates a random address.
   * @return `String` Random address
   */
  public String address() {
    return this.generate(this.randomElement(this.addressFormats));
  }

  /**
   * @description Generates a random state code.
   * @return `String` Random state code
   */
  public String stateCode() {
    return this.randomElement(this.stateCode);
  }

  /**
   * @description Generates a random zip code.
   * @return `Integer` Random zip code
   */
  public Integer zip() {
    return this.randomInteger(5);
  }

  /**
   * @description Generates a random coordinate.
   * @param fromInt Starting integer
   * @param toInt Ending integer
   * @return `Decimal` Random coordinate
   */
  public Decimal coordinate(Integer fromInt, Integer toInt) {
    Decimal coordinate = Decimal.valueOf(
      this.randomIntegerBetween(fromInt, toInt)
    );
    coordinate =
      (coordinate + this.randomDecimal(0, 6)) * (this.randomBoolean() ? -1 : 1);
    return coordinate;
  }

  /**
   * @description Generates a random latitude.
   * @return `Decimal` Random latitude
   */
  public Decimal latitude() {
    return this.coordinate(0, 90);
  }

  /**
   * @description Generates a random longitude.
   * @return `Decimal` Random longitude
   */
  public Decimal longitude() {
    return this.coordinate(0, 180);
  }
}
