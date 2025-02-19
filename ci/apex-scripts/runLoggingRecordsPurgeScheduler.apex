String cronExpression = '0 0 0 ? * 7'; // Runs every Saturday at 12 AM
String jobName = 'LoggingRecordsPurgeScheduler';

// Schedule the job
System.schedule(jobName, cronExpression, new LoggingRecordsPurgeScheduler());
