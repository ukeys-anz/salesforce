/**
 * @author Batya Aisman Sufrin
 * @since Aug 2024
 * @description Test class for {@link QueryPublicGroup}
 */
@IsTest
public with sharing class QueryPublicGroupTest {
  @isTest
  static void testGet() {
    List<Group> publicGroups = [
      SELECT Id, DeveloperName
      FROM Group
      WHERE Type = :QueryPublicGroup.GROUP_TYPE_PUBLICGROUP
      LIMIT 2
    ];

    Group publicGroup = QueryPublicGroup.get(publicGroups[0].Developername);
    Map<String, Group> mapPublicGroupByDevName = QueryPublicGroup.get(
      new Set<String>{
        publicGroups[0].Developername,
        publicGroups[1].Developername
      }
    );

    Assert.areEqual(
      publicGroups[0].Id,
      publicGroup.Id,
      'Public group ID should be retrieved by DeveloperName'
    );
    Assert.areEqual(
      publicGroups[0].Id,
      mapPublicGroupByDevName.get(publicGroups[0].DeveloperName).Id,
      'Public group ID should be retrieved by DeveloperName'
    );
    Assert.areEqual(
      publicGroups[1].Id,
      mapPublicGroupByDevName.get(publicGroups[1].DeveloperName).Id,
      'Public group ID should be retrieved by DeveloperName'
    );
  }
}
