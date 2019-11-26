trigger lib_ApplicationLoggingEventTrigger on Application_Logging__e(
  after insert
) {
  lib_ApplicationLoggingEvents handler = new lib_ApplicationLoggingEvents();
}
