/**
 * @author Pooja Kirtishahi
 * @since 05/2025
 * @description Provides SOQL and DML helpers for Task related to ResidentialLoanApplicationActions
 */

public with sharing class LendingTaskRepository {
  /**
   * @description To query all the tasks associated with rla records Ids
   * @param rlaRecordIds set of RLA Ids
   * @return List<Task> list of RLA
   */
  public List<Task> queryActiveTaskWithRLA(Set<Id> rlaRecordIds) {
    if (rlaRecordIds.isEmpty()) {
      return new List<Task>();
    }
    // Query Task associated to Residential loan application records
    return [
      SELECT Id, Status, Sub_Status__c
      FROM Task
      WHERE WhatId IN :rlaRecordIds AND Status != 'Expired'
      WITH USER_MODE
    ];
  }
}
