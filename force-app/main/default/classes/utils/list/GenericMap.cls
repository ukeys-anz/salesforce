/**
 * @author Tan Phan
 * @since 07/2024
 * @description An abstract class that represents a generic map.
 * @group Utils
 */
public abstract class GenericMap {
  private static final Map<Type, Type> MAP_TYPE_HANDLER = new Map<Type, Type>{
    Id.class => MapById.class,
    String.class => MapByString.class,
    Integer.class => MapByInteger.class,
    Decimal.class => MapByDecimal.class,
    Date.class => MapByDate.class,
    Time.class => MapByTime.class,
    DateTime.class => MapByDateTime.class,
    Boolean.class => MapByBoolean.class
  };

  /**
   * @description Creates a new instance of a GenericMap based on the provided key and value types.
   * @param keyType The type of the map's keys.
   * @param valueType The type of the map's values.
   * @return A new instance of a GenericMap.
   */
  public static GenericMap of(Type keyType, Type valueType) {
    if (MAP_TYPE_HANDLER.containsKey(keyType) == false) {
      throw new IllegalArgumentException('Unsupported key type: ' + keyType);
    }
    GenericMap handler = (GenericMap) MAP_TYPE_HANDLER.get(keyType)
      .newInstance();
    handler.init(
      Type.forName('Map<' + keyType + ',' + valueType + '>').newInstance()
    );
    return handler;
  }

  private Object mapInstance;

  /**
   * @description Initializes the GenericMap with the provided map instance.
   * @param mapInstance The map instance to be initialized.
   */
  public abstract void init(Object mapInstance);

  /**
   * @description Checks if the map contains the specified key.
   * @param key The key to check.
   * @return True if the map contains the key, false otherwise.
   */
  public abstract Boolean containsKey(Object key);

  /**
   * @description Retrieves the value associated with the specified key.
   * @param key The key to retrieve the value for.
   * @return The value associated with the key.
   */
  public abstract Object get(Object key);

  /**
   * @description Retrieves the set of keys in the map.
   * @return The set of keys in the map.
   */
  public abstract Object keySet();

  /**
   * @description Associates the specified value with the specified key in the map.
   * @param key The key to associate the value with.
   * @param value The value to be associated with the key.
   */
  public abstract void put(Object key, Object value);

  /**
   * @description Converts the GenericMap instance to a standard map.
   * @return The map instance.
   */
  public Object toMap() {
    return this.mapInstance;
  }

  /**
   * @description A concrete implementation of GenericMap that uses Id as the key type.
   */
  public class MapById extends GenericMap {
    Map<Id, Object> mapInstance;
    public override void init(Object mapInstance) {
      super.mapInstance = this.mapInstance = (Map<Id, Object>) mapInstance;
    }
    public override Object get(Object key) {
      return this.mapInstance.get((Id) key);
    }
    public override Boolean containsKey(Object key) {
      return this.mapInstance.containsKey((Id) key);
    }
    public override Object keySet() {
      return this.mapInstance.keySet();
    }
    public override void put(Object key, Object value) {
      this.mapInstance.put((Id) key, value);
    }
  }

  /**
   * @description A concrete implementation of GenericMap that uses String as the key type.
   */
  public class MapByString extends GenericMap {
    Map<String, Object> mapInstance;
    public override void init(Object mapInstance) {
      super.mapInstance = this.mapInstance = (Map<String, Object>) mapInstance;
    }
    public override Object get(Object key) {
      return this.mapInstance.get(String.valueOf(key));
    }
    public override Boolean containsKey(Object key) {
      return this.mapInstance.containsKey(String.valueOf(key));
    }
    public override Object keySet() {
      return this.mapInstance.keySet();
    }
    public override void put(Object key, Object value) {
      this.mapInstance.put(String.valueOf(key), value);
    }
  }

  /**
   * @description A concrete implementation of GenericMap that uses Integer as the key type.
   */
  public class MapByInteger extends GenericMap {
    Map<Integer, Object> mapInstance;
    public override void init(Object mapInstance) {
      super.mapInstance = this.mapInstance = (Map<Integer, Object>) mapInstance;
    }
    public override Object get(Object key) {
      return this.mapInstance.get((Integer) key);
    }
    public override Boolean containsKey(Object key) {
      return this.mapInstance.containsKey((Integer) key);
    }
    public override Object keySet() {
      return this.mapInstance.keySet();
    }
    public override void put(Object key, Object value) {
      this.mapInstance.put((Integer) key, value);
    }
  }

  /**
   * @description A concrete implementation of GenericMap that uses Decimal as the key type.
   */
  public class MapByDecimal extends GenericMap {
    Map<Decimal, Object> mapInstance;
    public override void init(Object mapInstance) {
      super.mapInstance = this.mapInstance = (Map<Decimal, Object>) mapInstance;
    }
    public override Object get(Object key) {
      return this.mapInstance.get((Decimal) key);
    }
    public override Boolean containsKey(Object key) {
      return this.mapInstance.containsKey((Decimal) key);
    }
    public override Object keySet() {
      return this.mapInstance.keySet();
    }
    public override void put(Object key, Object value) {
      this.mapInstance.put((Decimal) key, value);
    }
  }

  /**
   * @description A concrete implementation of GenericMap that uses Date as the key type.
   */
  public class MapByDate extends GenericMap {
    Map<Date, Object> mapInstance;
    public override void init(Object mapInstance) {
      super.mapInstance = this.mapInstance = (Map<Date, Object>) mapInstance;
    }
    public override Object get(Object key) {
      return this.mapInstance.get((Date) key);
    }
    public override Boolean containsKey(Object key) {
      return this.mapInstance.containsKey((Date) key);
    }
    public override Object keySet() {
      return this.mapInstance.keySet();
    }
    public override void put(Object key, Object value) {
      this.mapInstance.put((Date) key, value);
    }
  }

  /**
   * @description A concrete implementation of GenericMap that uses Time as the key type.
   */
  public class MapByTime extends GenericMap {
    Map<Time, Object> mapInstance;
    public override void init(Object mapInstance) {
      super.mapInstance = this.mapInstance = (Map<Time, Object>) mapInstance;
    }
    public override Object get(Object key) {
      return this.mapInstance.get((Time) key);
    }
    public override Boolean containsKey(Object key) {
      return this.mapInstance.containsKey((Time) key);
    }
    public override Object keySet() {
      return this.mapInstance.keySet();
    }
    public override void put(Object key, Object value) {
      this.mapInstance.put((Time) key, value);
    }
  }

  /**
   * @description A concrete implementation of GenericMap that uses DateTime as the key type.
   */
  public class MapByDateTime extends GenericMap {
    Map<DateTime, Object> mapInstance;
    public override void init(Object mapInstance) {
      super.mapInstance = this.mapInstance = (Map<DateTime, Object>) mapInstance;
    }
    public override Object get(Object key) {
      return this.mapInstance.get((DateTime) key);
    }
    public override Boolean containsKey(Object key) {
      return this.mapInstance.containsKey((DateTime) key);
    }
    public override Object keySet() {
      return this.mapInstance.keySet();
    }
    public override void put(Object key, Object value) {
      this.mapInstance.put((DateTime) key, value);
    }
  }

  /**
   * @description A concrete implementation of GenericMap that uses Boolean as the key type.
   */
  public class MapByBoolean extends GenericMap {
    Map<Boolean, Object> mapInstance;
    public override void init(Object mapInstance) {
      super.mapInstance = this.mapInstance = (Map<Boolean, Object>) mapInstance;
    }
    public override Object get(Object key) {
      return this.mapInstance.get((Boolean) key);
    }
    public override Boolean containsKey(Object key) {
      return this.mapInstance.containsKey((Boolean) key);
    }
    public override Object keySet() {
      return this.mapInstance.keySet();
    }
    public override void put(Object key, Object value) {
      this.mapInstance.put((Boolean) key, value);
    }
  }
}
