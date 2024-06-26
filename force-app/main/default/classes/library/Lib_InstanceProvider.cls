/**
 * @author Tan Phan
 * @since 06/2024
 * @description The `Lib_InstanceProvider` class provides a mechanism for resolving and managing dependencies in Apex code.
 * It allows for the registration and retrieval of instances of different types.
 * Can also be used to inject fake instance for testing purposes with the manual `register` method
 * @group Library
 */
public with sharing class Lib_InstanceProvider {
  private static Map<Type, Object> instances = new Map<Type, Object>();

  /**
   * @description Returns an instance of the specified Apex type.
   * If an instance of the type has already been created, it is returned from the cache.
   * If the type is a Service class, it is registered and retrieved from the ServiceProvider.
   * Otherwise, a new instance of the type is created and registered.
   * @param apexType The Apex type to get an instance of.
   * @return An instance of the specified Apex type.
   */
  public static Object forType(Type apexType) {
    if (instances.containsKey(apexType)) {
      return instances.get(apexType);
    }
    if (Service.class.isAssignableFrom(apexType)) {
      return register(apexType, ServiceProvider.getService(apexType));
    }
    return register(apexType, apexType.newInstance());
  }

  /**
   * @description Registers an instance of the specified Apex type.
   * @param apexType The Apex type to register.
   * @param instance The instance of the Apex type to register.
   * @return The registered instance of the Apex type.
   */
  @TestVisible
  private static Object register(Type apexType, Object instance) {
    instances.put(apexType, instance);
    return instance;
  }
}
