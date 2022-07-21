/**
 * @author Igor Matkovic
 * @since 09/07/2018
 * @group Faker
 * @description Class having Person related fake data population methods
 * ExcessivePublicCount Surpressed : FakerPersonProvider to have all the public methods and attributes together.
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing virtual class FakerPersonProvider extends FakerBase {
  public List<String> nameFormatsMale;
  public List<String> nameFormatsFemale;
  public List<String> firstNameMale;
  public List<String> firstNameFemale;
  public List<String> lastName;
  public List<String> suffix;
  public List<String> gender;
  public List<String> titleMale;
  public List<String> titleFemale;
  public List<String> jobTitle;

  /**
   * @description Init method which does value map initialisation
   */
  public void init() {
    this.mapValues = new Map<String, List<String>>();
    this.mapValues.put('firstNameMale', this.firstNameMale);
    this.mapValues.put('firstNameFemale', this.firstNameFemale);
    this.mapValues.put('lastName', this.lastName);
    this.mapValues.put('jobTitle', this.jobTitle);
    this.mapValues.put('gender', this.gender);
    this.mapValues.put('suffix', this.suffix);
    this.mapValues.put('titleMale', this.titleMale);
    this.mapValues.put('titleFemale', this.titleFemale);
  }

  /**
   * @description Returns a random name
   * @return `String`
   */
  public String name() {
    return this.name(this.gender());
  }

  /**
   * @description Returns a random name which belongs to passed in gender
   * @param gender String gender
   * @return `String`
   */
  public String name(String gender) {
    return this.generate(
      this.randomElement(
        gender == 'female' ? this.nameFormatsFemale : this.nameFormatsMale
      )
    );
  }

  /**
   * @description Returns a random suffix
   * @return `String`
   */
  public String suffix() {
    return this.generate(this.randomElement(this.suffix));
  }

  /**
   * @description Returns a random first name
   * @return `String`
   */
  public String firstName() {
    return this.firstName(this.gender());
  }

  /**
   * @description Returns a random first name which belongs to passed in gender
   * @param gender String gender
   * @return `String`
   */
  public String firstName(String gender) {
    return this.randomElement(
      gender == 'female' ? this.firstNameFemale : this.firstNameMale
    );
  }

  /**
   * @description Returns a random last name
   * @return `String`
   */
  public String lastName() {
    return this.randomElement(this.lastName);
  }

  /**
   * @description Returns a random title
   * @return `String`
   */
  public String title() {
    return this.title(this.gender());
  }

  /**
   * @description Returns a random title related to passed in gender
   * @param gender String gender
   * @return `String`
   */
  public String title(String gender) {
    return this.randomElement(
      gender == 'female' ? this.titleFemale : this.titleMale
    );
  }

  /**
   * @description Returns a random job title
   * @return `String`
   */
  public String jobTitle() {
    return this.randomElement(this.jobTitle);
  }

  /**
   * @description Returns a random SSN
   * @return `String`
   */
  public String ssn() {
    return String.valueOf(Math.random()).substring(2, 5) +
      '-' +
      String.valueOf(Math.random()).substring(2, 4) +
      '-' +
      String.valueOf(Math.random()).substring(2, 6);
  }

  /**
   * @description Returns a random gender
   * @return `String`
   */
  public String gender() {
    return this.randomElement(this.gender);
  }

  /**
   * @description Returns a random phone number
   * @return `String`
   */
  public String phone() {
    return '(' +
      String.valueOf(Math.random()).substring(2, 5) +
      ') ' +
      String.valueOf(Math.random()).substring(2, 5) +
      '-' +
      String.valueOf(Math.random()).substring(2, 6);
  }

  /**
   * @description Returns a random phone number based on area code
   * @param areaCode Integer area code
   * @return `String`
   */
  public String phone(Integer areaCode) {
    return '(' +
      String.valueOf(areaCode) +
      ') ' +
      String.valueOf(Math.random()).substring(2, 5) +
      '-' +
      String.valueOf(Math.random()).substring(2, 6);
  }

  /**
   * @description Returns a random birthdate
   * @return `Date`
   */
  public Date birthday() {
    return this.randomPastDate();
  }

  /**
   * @description Returns a random picture
   * @param width Integer width
   * @param height Integer height
   * @return `String`
   */
  public String picture(Integer width, Integer height) {
    return 'https://picsum.photos/' +
      String.valueOf(width) +
      '/' +
      String.valueOf(height) +
      '/?random';
  }
}
