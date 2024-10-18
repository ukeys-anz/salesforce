/**
 * @author Tan Phan
 * @since 08/2024
 * @description Provide methods to handle SObject and GenericObject
 * @group Utils
 */
public abstract class ObjectHandler {
  /**
   * @description Returns the appropriate handler based on the type of records.
   * @param records The list of records to be handled.
   * @return The handler object based on the type of records.
   * @throws IllegalArgumentException if the type of records is not supported.
   */
  public static ObjectHandler of(List<Object> records) {
    if (records instanceof List<SObject>) {
      return new SObjectHandler(records);
    }
    if (records instanceof List<GenericObject>) {
      return new GenericHandler(records);
    }
    throw new IllegalArgumentException('Unsupported type');
  }

  private ObjectHandler() {
  }

  protected ObjectHandler(SObjectType objType) {
    this(objType.toString());
  }

  protected ObjectHandler(String itemTypeName) {
    this(Type.forName(itemTypeName));
  }

  protected ObjectHandler(Type itemType) {
    this.itemType = itemType;
  }

  /**
   * @description The type of item handled by the ObjectHandler.
   */
  public Type itemType { get; private set; }

  /**
   * @description Provide the list of similar type to original list.
   */
  public List<Object> emptyList {
    get {
      emptyList = emptyList ??
        (List<Object>) Type.forName('List<' + this.itemType + '>')
          .newInstance();
      return emptyList.clone();
    }
    private set;
  }

  /**
   * @description Retrieves the value of a field from an Object.
   * @param record The SObject record.
   * @param fieldName The name of the field.
   * @return The value of the field.
   */
  public abstract Object get(Object record, String fieldName);

  /**
   * @description This class extends the ObjectHandler class and provides specific handling for SObjects.
   */
  public class SObjectHandler extends ObjectHandler {
    SObjectHandler(List<Object> records) {
      super(((List<SObject>) records).getSObjectType());
    }
    public override Object get(Object record, String fieldName) {
      if (record == null || fieldName == '*') {
        return record;
      }
      SObject sobj = (SObject) record;
      if (fieldName.contains('.') == false) {
        return sobj.get(fieldName);
      }
      List<String> fields = fieldName.split('\\.', 2);
      return this.get(sobj.getSObject(fields[0]), fields[1]);
    }
  }

  /**
   * @description This class extends the ObjectHandler class and provides generic handling for objects.
   */
  public class GenericHandler extends ObjectHandler {
    //acc is dummy variable to catch exception
    @SuppressWarnings('PMD.UnusedLocalVariable')
    GenericHandler(List<Object> records) {
      if (records == null) {
        throw new NullPointerException();
      }
      try {
        Account acc = (Account) (Object) records;
      } catch (Exception ex) {
        super(ex.getMessage().substringBetween('List<', '>'));
      }
    }
    public override Object get(Object record, String fieldName) {
      return ((GenericObject) record).get(fieldName);
    }
  }
}
