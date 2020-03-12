# Trigger Framework

At ANZx we use a trigger framework to centralise and standardise all trigger based operations.

# Framework

## Trigger

Each Trigger should only contain:

- The hook methods (e.g. after insert, before update etc)
- An instantiation of the relevant Trigger Handler (which extends the trigger base class)

```
trigger SObjectTrigger on SObject(
before insert,
after insert,
after update,
before delete
) {
	SObjectTriggerHandler handler = new SObjectTriggerHandler();
}
```

## Handler Class

The handler class should extend the base class, and then overwriite the methods that are applicable.

A hollow handler class looks as follows:

```java
public with sharing class SObjectTriggerHandler extends Lib_TriggerHandler {

  public SObjectTriggerHandler() {
    super();
  }

}

```

Now that we have the hollow handler class, we need to overwrite the relevant methods.

| Hook            | Method to Override | Argument(s)               |
| --------------- |:------------------:|:-------------------------:|
| before insert   | onBeforeInsert     |                           |
| after insert    | onAfterInsert      |                           |
| before update   | onBeforeUpdate     | Map<Id, SObject> oldMap() |
| after update    | onAfterUpdate      | Map<Id, SObject> oldMap() |
| before delete   | onBeforeDelete     |                           |
| after delete    | onAfterDelete      |                           |
| before undelete | onBeforeUndelete   |                           |
| after undelete  | onAfterUndelete    |                           |

As well as there are two other methods that can be overriden:

| Method Name     | Argument(s)               | Description                                                         |
| --------------- |:-------------------------:|:-------------------------------------------------------------------:|
| onValidate      |                           | Run validtion logic (only on current trigger context)               |
| onValidate      | Map<Id, SObject> oldMap() | Run validation logic (where prior value is required for comparison) |
| onApplyDefaults |                           | Set default values progrmmatically                                  |

If you want to see the order in which these run, you can look at the `Lib_TriggerHandler.cls` file within the `library/` directory in `classes/`.

Once a handler has been established with the relevant overrides, we should be *calling well name methods* from a `CommonActions` class so that the orchestration within each hook is very easy to establish and read.

So an example handler class:

```java
public with sharing class SObjectTriggerHandler extends Lib_TriggerHandler {

  public SObjectTriggerHandler() {
    super();
  }

  public override void onApplyDefaults() {
    SObjectCommonActions.applyDefaults((List<SObject>) records);
  }

  public override void onValidate() {
    SObjectCommonActions.validateRecords((List<SObject>) records);
  }

  public override void onBeforeDelete() {
    SObjectCommonActions.deleteMasterRecord(records);
  }
}
```

and an example actions class:

```java
public with sharing class SObjectCommonActions{

  public static void applyDefaults(List<SObject> records) {
    for(SObject record : records){
		record.Field_A__c = 'Default Value';
	}
  }

  public static void validateRecords(List<SObject> records) {
	for(SObject record : records){
	  if(record.Field_B__c != 'Expected value'){
			record.addError('This field should not have this value');
	  }
	}
  }

  public static void deleteMasterRecord(List<SObject> records) {
    // Logic to lookup and delete parent record
  }
}
```