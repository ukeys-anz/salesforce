/**
 * @description AzureTestRefreshToken class which hold Azure Dummy refresh token which needs to be replaced with real one by Admins in the sandboxs/ scratchorgs for Fabric intergrations to work
 * @author Pavan Kumar Ananta
 * @since 2021
 */
public without sharing class AzureTestRefreshToken {
  private AzureTestRefreshToken() {
    // restrict instantiation
  }

  //refresh token replace this with real token in non prod environments when we need to integrate Fabric services.
  public final static String REFRESHTESTVALUE = '0.ASUA94gHfzQ2m0G_dLvk.AgABAAAAAAD--DLnft0yO0ie8RRd1KWdzLhLZHsl-NiEA6iKH18NrAohPeFO3GKMGXA55l6TpyGPmKd2n7Vgtzm-9lYppUU5DdlL7t2fap-uvzCGKqjuaRYhrxBKUKMEOhflM0oojOor_DC_fJpNEzB2nIgurSM2Js_q5ap_4DSaTZRFgeaDmVJ8Ng2tTWRTKimWv-pP19FXNV96EWW8SHPgrlLwDchru34_AZOSjzbBcb4cpu3JQwWkzy-kG4-bJn1mbhrBzAJC47xjvZldAcS3HAFk5xWUyPVr10V1BR7pf7ygpuTVg4hgBuzsI9F_4r8EVmRWiXGS_6-VZ723_sz1-em5ISlG6wK2KXVCGcU0roplUgiH2jauGXqtRW2OXD6xSHdvU3MbFYPTfi3wz-OP017yNE27PWQHuuz1ygPT9rKijM0TESjAp4MDbYwvJOcRxedKOb6M4fak9er2_AELO5AsLKRZ9je4w9zfJwGuTciOqA3Ki8xKRwfuZfKNyZEW8B4USDhzDotQOmLmcOFeZjHvehGE1btOBb0PeBGIXgniRPyoW1anLsn-QYbZkMIZdCILe8qZ6VHmOLO6-1F-_HLecuxHz1sZCtyxoMG4rq2wzg_D6DJTpiOvgtAX90F6tINAgHAZWZs85-a5qpC5W3DbPfGQCfrJa36ueRoFwplxO0JMLzkXagHq_M-I9v9Pym-RTGawtFSlm-2vvQbxlvanMIvjMQQADfo99QRovZu-1Xdi_GIVmLHzCWC84dzkiO1V40zxMKE8btZ8J2klTq8jf3_WBtHEGJ4e9rC1tg1PJnFFzcfb8eeMS8Hp3J6jdpgCVNPpz4KqQ';
}
