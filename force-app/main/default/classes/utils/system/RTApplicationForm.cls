/**
 * @author       : Advait Yermalkar
 * @since        : 12-19-2024
 * @description  : Holds cached ApplicationForm Record Types.
 **/

public with sharing class RTApplicationForm {
  static QueryRT base = QueryRT.of(ApplicationForm.SObjectType);

  public static Id ambitApplication = base.getId('AMBIT');
  public static Id bbdApplication = base.getId('BBD');
  public static Id acmApplication = base.getId('ACM');
  public static Id internalApplication = base.getId('Internal_Application');
  public static String ambitApplicationName = base.get(ambitApplication).Name;
  public static String bbdApplicationName = base.get(bbdApplication).Name;
  public static String acmApplicationName = base.get(acmApplication).Name;
  public static String internalApplicationName = base.get(internalApplication)
    .Name;
}
