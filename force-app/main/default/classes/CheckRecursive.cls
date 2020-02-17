/**
 * @description check resursion for triggers.
 * Add the ID's to the set and check if we are dealing with the same ID's in the same transaction
 * @see CaseTriggerHandler for example
 * @author Pavan Kumar Ananta
 * @since 02/2020
 */
public with sharing class CheckRecursive {
  public static Set<Id> setOfIDs = new Set<Id>();
}
