// Script to add Disable_MFA permission set to Engineer Permission Set Group in non-prod environments

// Determine if this is a production environment
Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

// Only run in non-prod
if (!isSandbox) {
  System.debug('SKIPPED: This script only runs in non-production environments');
  return;
}

System.debug('Non-prod: Adding Disable_MFA to Engineer Permission Set Group');

try {
  // Get the Disable_MFA permission set
  PermissionSet disableMFAPermSet = [
    SELECT Id, Name
    FROM PermissionSet
    WHERE Name = 'Disable_MFA'
    LIMIT 1
  ];
  System.debug('Found Disable_MFA permission set: ' + disableMFAPermSet.Id);

  // Get the Engineer Permission Set Group
  PermissionSetGroup engineerPSG = [
    SELECT Id, DeveloperName
    FROM PermissionSetGroup
    WHERE DeveloperName = 'Engineer'
    LIMIT 1
  ];
  System.debug('Found Engineer PSG: ' + engineerPSG.Id);

  // Check if Disable_MFA is already in the Engineer PSG
  List<PermissionSetGroupComponent> existingComponents = [
    SELECT Id
    FROM PermissionSetGroupComponent
    WHERE
      PermissionSetGroupId = :engineerPSG.Id
      AND PermissionSetId = :disableMFAPermSet.Id
  ];

  if (existingComponents.isEmpty()) {
    // Add Disable_MFA to Engineer PSG
    PermissionSetGroupComponent newComponent = new PermissionSetGroupComponent(
      PermissionSetGroupId = engineerPSG.Id,
      PermissionSetId = disableMFAPermSet.Id
    );
    insert newComponent;
    System.debug('SUCCESS: Added Disable_MFA to Engineer Permission Set Group');
  } else {
    System.debug(
      'Disable_MFA is already part of Engineer Permission Set Group'
    );
  }
} catch (Exception e) {
  System.debug(
    'ERROR: Failed to add Disable_MFA to Engineer PSG: ' + e.getMessage()
  );
  throw e;
}
