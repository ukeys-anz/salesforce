/**
 * @author Alan Hillgemann
 * @since September 2024
 * @description Sets up the sandbox after initialization.
 * @runTests SandboxSetupTest
 */
public without sharing class SandboxSetup implements SandboxPostCopy {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final SandboxSetupRepository SS_REPOSITORY = (SandboxSetupRepository) Lib_InstanceProvider.forType(
    SandboxSetupRepository.class
  );
  private static final Set<String> PS_NAMES_TO_ASSIGN = new Set<String>{
    'Disable_MFA'
  };
  private static final Set<String> PS_NAMES_TO_UNASSIGN = new Set<String>{
    'Enforce_SSO'
  };
  /**
   * @description Sets the user who created, cloned or refreshed the sandbox as a System Administrator that can log in via password.
   * @param context Org Id, sandbox Id and sandbox name.
   */
  public void runApexClass(SandboxContext context) {
    User user = SS_REPOSITORY.getUser();
    user.ProfileId = QueryProfile.systemAdmin.Id;
    DML_REPOSITORY.doUpdate(user, new DmlConfig().systemMode());
    Set<String> psNames = new Set<String>();
    psNames.addAll(PS_NAMES_TO_ASSIGN);
    psNames.addAll(PS_NAMES_TO_UNASSIGN);
    List<PermissionSetAssignment> psas = SS_REPOSITORY.getPsas(
      psNames,
      user.Id
    );
    Map<String, PermissionSetAssignment> psasByName = new Map<String, PermissionSetAssignment>();
    for (PermissionSetAssignment psa : psas) {
      psasByName.put(psa.PermissionSet.Name, psa);
    }
    List<PermissionSetAssignment> psasToAdd = psasToAdd(psasByName, user.Id);
    DML_REPOSITORY.doInsert(psasToAdd, new DmlConfig().systemMode());
    List<PermissionSetAssignment> psasToRemove = psasToRemove(psasByName);
    DML_REPOSITORY.doDelete(psasToRemove, new DmlConfig().systemMode());
  }
  /**
   * @description Returns the permission set assignments to add.
   * @param psasByName Permission set assignments by name.
   * @param userId User Id.
   * @return Permission set assignments to add.
   */
  @TestVisible
  private static List<PermissionSetAssignment> psasToAdd(
    Map<String, PermissionSetAssignment> psasByName,
    Id userId
  ) {
    List<PermissionSetAssignment> psasToAdd = new List<PermissionSetAssignment>();
    for (String psName : PS_NAMES_TO_ASSIGN) {
      if (!psasByName.containsKey(psName)) {
        psasToAdd.add(
          new PermissionSetAssignment(
            PermissionSetId = QueryPs.get(psName).Id,
            AssigneeId = userId
          )
        );
      }
    }
    return psasToAdd;
  }
  /**
   * @description Returns the permission set assignments to remove.
   * @param psasByName Permission set assignments by name.
   * @return Permission set assignments to remove.
   */
  @TestVisible
  private static List<PermissionSetAssignment> psasToRemove(
    Map<String, PermissionSetAssignment> psasByName
  ) {
    List<PermissionSetAssignment> psasToRemove = new List<PermissionSetAssignment>();
    for (String psName : PS_NAMES_TO_UNASSIGN) {
      if (psasByName.containsKey(psName)) {
        psasToRemove.add(psasByName.get(psName));
      }
    }
    return psasToRemove;
  }
}
