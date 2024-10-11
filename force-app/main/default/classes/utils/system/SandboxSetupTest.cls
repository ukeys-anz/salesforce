/**
 * @author Alan Hillgemann
 * @since September 2024
 *  @description Test class for {@link SandboxSetup}
 */
@isTest
private class SandboxSetupTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider ssRepoMock;
  static Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
  static PermissionSet disableMfaPs = QueryPS.get('Disable_MFA');
  static PermissionSet enforceSsoPs = QueryPS.get('Enforce_SSO');

  static void registerMocks() {
  dmlRepoMock = Lib_MockProvider.forType(
    DmlRepository.class
  );
  ssRepoMock = Lib_MockProvider.forType(
    SandboxSetupRepository.class
  );
    User user = new User(
      Id = userId,
      ProfileId = QueryProfile.minimumAccessSalesforce.Id,
      email = 'test@anz.com',
      IsActive = true
    );
    ssRepoMock.mock('getUser', user);
  }

  @isTest
  static void testRunApexClassUserWithNoPsas() {
    registerMocks();
    ssRepoMock.mock('getPsas', new List<PermissionSetAssignment>());
    Test.startTest();
    Test.testSandboxPostCopyScript(
      new SandboxSetup(),
      UserInfo.getOrganizationId(),
      UserInfo.getOrganizationId(),
      UserInfo.getOrganizationName(),
      true
    );
    Test.stopTest();
    User user = (User) dmlRepoMock.getHistory('doUpdate').getParam('record');
    Assert.areEqual(
      QueryProfile.systemAdmin.Id,
      user.ProfileId,
      'System Administrator profile should be assigned'
    );
    List<PermissionSetAssignment> psasToAdd = (List<PermissionSetAssignment>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      psasToAdd.size(),
      'There should be one permission set assignment to add'
    );
    Assert.areEqual(
      disableMfaPs.Id,
      psasToAdd[0].PermissionSetId,
      'Permission set assignment to add should be Disable_MFA'
    );
    List<PermissionSetAssignment> psasToRemove = (List<PermissionSetAssignment>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      0,
      psasToRemove.size(),
      'There should be no permission set assignments to remove'
    );
  }
  @isTest
  static void testRunApexClassUserWithPsas() {
    registerMocks();
    List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>{
      new PermissionSetAssignment(
        AssigneeId = userId,
        PermissionSet = disableMfaPs,
        PermissionSetId = disableMfaPs.Id
      ),
      new PermissionSetAssignment(
        AssigneeId = userId,
        PermissionSet = enforceSsoPs,
        PermissionSetId = enforceSsoPs.Id
      )
    };
    ssRepoMock.mock('getPsas', psas);
    Test.startTest();
    Test.testSandboxPostCopyScript(
      new SandboxSetup(),
      UserInfo.getOrganizationId(),
      UserInfo.getOrganizationId(),
      UserInfo.getOrganizationName(),
      true
    );
    Test.stopTest();
    List<PermissionSetAssignment> psasToAdd = (List<PermissionSetAssignment>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      0,
      psasToAdd.size(),
      'There should be no permission set assignments to add'
    );
    List<PermissionSetAssignment> psasToRemove = (List<PermissionSetAssignment>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      psasToRemove.size(),
      'There should be one permission set assignment to remove'
    );
    Assert.areEqual(
      enforceSsoPs.Id,
      psasToRemove[0].PermissionSetId,
      'Permission set assignment to remove should be Enforce_SSO'
    );
  }
  @isTest
  static void testPsasToAddWithPsas() {
    Map<String, PermissionSetAssignment> psasByName = new Map<String, PermissionSetAssignment>{
      'Disable_MFA' => new PermissionSetAssignment(),
      'Enforce_SSO' => new PermissionSetAssignment()
    };
    Test.startTest();
    List<PermissionSetAssignment> psasToAdd = SandboxSetup.psasToAdd(
      psasByName,
      userId
    );
    Test.stopTest();
    Assert.areEqual(
      0,
      psasToAdd.size(),
      'There should be no permission set assignments to add'
    );
  }
  @isTest
  static void testPsasToAddWithNoPsas() {
    Map<String, PermissionSetAssignment> psasByName = new Map<String, PermissionSetAssignment>();
    Test.startTest();
    List<PermissionSetAssignment> psasToAdd = SandboxSetup.psasToAdd(
      psasByName,
      userId
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      psasToAdd.size(),
      'There should be one permission set assignment to add'
    );
    Assert.areEqual(
      disableMfaPs.Id,
      psasToAdd[0].PermissionSetId,
      'Permission set assignment to add should be Disable_MFA'
    );
  }
  @isTest
  static void testPsasToRemoveWithPsas() {
    Map<String, PermissionSetAssignment> psasByName = new Map<String, PermissionSetAssignment>{
      'Disable_MFA' => new PermissionSetAssignment(),
      'Enforce_SSO' => new PermissionSetAssignment(
        PermissionSetId = enforceSsoPs.Id
      )
    };
    Test.startTest();
    List<PermissionSetAssignment> psasToRemove = SandboxSetup.psasToRemove(
      psasByName
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      psasToRemove.size(),
      'There should be one permission set assignment to remove'
    );
    Assert.areEqual(
      enforceSsoPs.Id,
      psasToRemove[0].PermissionSetId,
      'Permission set assignment to remove should be Enforce_SSO'
    );
  }
  @isTest
  static void testPsasToRemoveWithNoPsas() {
    Map<String, PermissionSetAssignment> psasByName = new Map<String, PermissionSetAssignment>();
    Test.startTest();
    List<PermissionSetAssignment> psasToRemove = SandboxSetup.psasToRemove(
      psasByName
    );
    Test.stopTest();
    Assert.areEqual(
      0,
      psasToRemove.size(),
      'There should be no permission set assignments to remove'
    );
  }
}
