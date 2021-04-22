/**
 * @author Igor Matkovic
 * @since 09/07/2018
 * @group Faker
 * @description  Factory base class which should be extended while defining test object factories.
 */
public with sharing virtual class FakerFactoryBase implements FakerFactoryInterface {
  /**
   * @description Getter and setter method for Faker instance
   */
  public Faker faker { get; set; }

  /**
   * @description Getter and setter method for data map instance
   */
  public Map<String, Object> data { get; set; }

  /**
   * @description Default constructor
   */
  public FakerFactoryBase() {
    this.faker = new Faker(this.getLocale());
    this.data = this.define();
  }

  /**
   * @description Returns an object instance
   * @return `SObject`
   */
  public SObject make() {
    return this.getObject(null);
  }

  /**
   * @description Creates and returns an object instance
   * @return `SObject`
   */
  @SuppressWarnings('PMD.ApexCRUDViolation')
  public SObject create() {
    SObject newObject = this.getObject(null);
    if (newObject.getSObjectType().getDescribe().isCreateable()) {
      insert newObject;
    }
    return newObject;
  }

  /**
   * @description Creates and returns an object instance with pre-defined values
   * @param values Map<String, Object> map of values to be pre-polulated on object attributes
   * @return `SObject`
   */
  @SuppressWarnings('PMD.ApexCRUDViolation')
  public SObject create(Map<String, Object> values) {
    SObject newObject = this.getObject(values);
    if (newObject.getSObjectType().getDescribe().isCreateable()) {
      insert newObject;
    }
    return newObject;
  }

  /**
   * @description Returns an object instance with pre-defined values
   * @param values Map<String, Object> map of values to be pre-polulated on object attributes
   * @return `SObject`
   */
  public SObject make(Map<String, Object> values) {
    return this.getObject(values);
  }

  /**
   * @description Populates and returns an object instance with pre-defined values
   * @param values Map<String, Object> map of values to be pre-polulated on object attributes
   * @return `SObject`
   */
  public sObject getObject(Map<String, Object> values) {
    SObject newObject = this.createNewSobject(this.objectName());
    Map<String, Object> mapping = mergeMapping(values, this.data);
    for (String d : mapping.keySet()) {
      newObject.put(d, mapping.get(d));
    }
    return newObject;
  }

  /**
   * @description Merges data to be pre-populated before returining sObject instances.
   * @param map1 Map<String, Object> map of values to be pre-polulated on object attributes
   * @param map2 Map<String, Object> map of values currently available on the object instance
   * @return `Map<String, Object>`
   */
  public Map<String, Object> mergeMapping(
    Map<String, Object> map1,
    Map<String, Object> map2
  ) {
    if (map1 == null) {
      return map2;
    }

    Map<String, Object> result = new Map<String, Object>();
    for (String d : map1.keySet()) {
      result.put(d, map1.get(d));
    }

    for (String d : map2.keySet()) {
      if (!result.containsKey(d)) {
        result.put(d, map2.get(d));
      }
    }

    return result;
  }

  /**
   * @description Returns a new sObject instance.
   * @param t String representing the sObject type
   * @return `SObject`
   */
  public SObject createNewSobject(String t) {
    /* Call global describe to get the map of string to token. */
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    /* Get the token for the sobject based on the type. */
    Schema.SObjectType st = gd.get(t);
    System.assert(
      st != null,
      'Type provided: "' +
      t +
      '" doesnt map to an sobject token in this org.'
    );

    /* Instantiate the sobject from the token. */
    return st.newSobject();
  }

  /**
   * @description Skeleton interface method definition for define() method
   * @return Map<String, Object>
   */
  public virtual Map<String, Object> define() {
    return null;
  }

  /**
   * @description Skeleton interface method definition for objectName() method
   * @return String
   */
  public virtual String objectName() {
    return null;
  }

  /**
   * @description Skeleton interface method definition for getLocale() method
   * @return String
   */
  public virtual String getLocale() {
    return 'US';
  }
}
