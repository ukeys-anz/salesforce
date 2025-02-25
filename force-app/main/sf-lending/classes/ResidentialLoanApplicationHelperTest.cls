@isTest
private class ResidentialLoanApplicationHelperTest {
  static Lib_MockProvider rlarRepoMock;

  static void registerMocks() {
    rlarRepoMock = Lib_MockProvider.forType(
        ResidentialLoanApplicationRepository.class
      )
      .mock(
        'queryRelatedProperties',
        new List<LoanApplicationProperty>{ relatedProperty }
      );
  }

  static Id rlaIds = Lib_FakeIdGenerator.getMockId(
    ResidentialLoanApplication.SObjectType
  );
  static Id lapIds = Lib_FakeIdGenerator.getMockId(
    LoanApplicationProperty.SObjectType
  );

  static List<SOPAsset> sopAssets {
    get {
      List<SOPAsset> assets = new List<SOPAsset>();
      SOPAsset asset = new SOPAsset();
      asset.type = 'ASSET_TYPE_PROPERTY';
      asset.propertyId = lapIds;
      assets.add(asset);
      SOPAsset asset1 = new SOPAsset();
      asset1.type = 'Anothertype';
      assets.add(asset1);

      return assets;
    }
  }

  static LoanApplicationProperty relatedProperty {
    get {
      return new LoanApplicationProperty(
        Id = Lib_FakeIdGenerator.getMockId(LoanApplicationProperty.SObjectType),
        Property_ID__c = lapIds,
        PropertyValue = 5000000.01,
        LoanApplicationId = rlaIds,
        Name = '639 collins st docklands vic 3000'
      );
    }
  }

  @isTest
  static void testGetPropertyIdMap() {
    Map<String, SOPAsset> assetMap = ResidentialLoanApplicationHelper.getPropertyIdMap(
      sopAssets
    );
    System.assertEquals(
      1,
      assetMap.size(),
      'only the property asset should be in the map'
    );
  }

  @isTest
  static void testUpdateTheAssets() {
    List<SOPAsset> updatedAssets = ResidentialLoanApplicationHelper.updateTheAssets(
      new List<LoanApplicationProperty>{ relatedProperty },
      sopAssets
    );
    System.assertEquals(
      2,
      updatedAssets.size(),
      'the asset size should not change'
    );
    System.assertEquals(
      5000000.01,
      updatedAssets[0].propertyValue,
      'the property asset should have value now'
    );
  }

  @isTest
  static void testOverwritePropertyAssetData() {
    registerMocks();

    Test.startTest();
    List<SOPAsset> assets = ResidentialLoanApplicationHelper.overwritePropertyAssetData(
      rlaIds,
      sopAssets
    );
    Test.stopTest();

    System.assertEquals(
      '639 collins st docklands vic 3000',
      assets[0].propertyAddress,
      'address should be from related property record'
    );
    System.assertNotEquals(
      '639 collins st docklands vic 3000',
      assets[1].propertyAddress,
      'address should not be from related property record'
    );
  }
}
