/**
 * @author Batya Aisman Sufrin
 * @since Aug 2024
 * @description Holds cached PublicGroup records
 */
public with sharing class QueryPublicGroup {
  public static final String GROUP_TYPE_PUBLICGROUP = 'Regular';

  private static Map<String, Group> publicGroups = new Map<String, Group>();
  static {
    for (Group g : [
      SELECT Id, Name, Type, DeveloperName
      FROM Group
      WHERE Type = :GROUP_TYPE_PUBLICGROUP
      WITH USER_MODE
    ]) {
      publicGroups.put(g.DeveloperName, g);
    }
  }

  /**
   * @description Returns a public group based on the provided name.
   * @param name The name of the public group.
   * @return The Group object associated with the provided name.
   */
  public static Group get(String name) {
    return publicGroups.get(name);
  }

  /**
   * @description Returns a map of public group records based on the provided set of names.
   * @param names A set of names of the public groups.
   * @return A map of Group objects associated with the provided names.
   */
  public static Map<String, Group> get(Iterable<String> names) {
    Map<String, Group> mapPublicGroups = new Map<String, Group>();
    for (String name : names) {
      if (publicGroups.containsKey(name)) {
        mapPublicGroups.put(name, publicGroups.get(name));
      }
    }
    return mapPublicGroups;
  }
}
