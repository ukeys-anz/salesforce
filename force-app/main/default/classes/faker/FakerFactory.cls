/**
 * @author Igor Matkovic
 * @since 09/07/2018
 * @group faker
 * @description  Factory method to allow creating different Object instances
 */
public with sharing class FakerFactory {
  /**
   * @description Creates and returns a new object instance
   * @param newObject Instance of the FakerFactoryBase implementation representing the SObject to be created.
   * @return `SObject`
   */
  public static SObject create(FakerFactoryBase newObject) {
    return newObject.create();
  }

  /**
   * @description Returns a new object instance
   * @param newObject Instance of the FakerFactoryBase implementation representing the SObject to be created.
   * @return `SObject`
   */
  public static SObject make(FakerFactoryBase newObject) {
    return newObject.make();
  }

  /**
   * @description Creates and returns a new object instance
   * @param newObject Instance of the FakerFactoryBase implementation representing the SObject to be created.
   * @param values Map<String, Object> map of values to be pre-populated
   * @return `SObject`
   */
  public static SObject create(
    FakerFactoryBase newObject,
    Map<String, Object> values
  ) {
    return newObject.create(values);
  }

  /**
   * @description Returns a new object instance
   * @param newObject Instance of the FakerFactoryBase implementation representing the SObject to be created.
   * @param values Map<String, Object> map of values to be pre-populated
   * @return `SObject`
   */
  public static SObject make(
    FakerFactoryBase newObject,
    Map<String, Object> values
  ) {
    return newObject.make(values);
  }
}
