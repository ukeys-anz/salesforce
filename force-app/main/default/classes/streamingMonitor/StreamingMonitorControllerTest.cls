@isTest
private class StreamingMonitorControllerTest {
  @isTest
  static void publishPlatformEventshouldfailwheneventNameisunknownsObject() {
    try {
      StreamingMonitorController.publishEvent('PlatformEvent', 'unknown', null);
      System.assert(false, 'Exception was expected');
    } catch (Exception e) {
      System.assert(e instanceof AuraHandledException);
    }
  }

  @isTest
  static void publishPlatformEventshouldfailwheneventNameisnotplatformevent() {
    try {
      StreamingMonitorController.publishEvent('PlatformEvent', 'Account', '{}');
      System.assert(false, 'Exception was expected');
    } catch (Exception e) {
      System.assert(e instanceof AuraHandledException);
    }
  }

  @isTest
  static void publishPlatformEventshouldfailwhenpayloadisinvalidjson() {
    try {
      StreamingMonitorController.publishEvent(
        'PlatformEvent',
        'Account',
        'invalid'
      );
      System.assert(false, 'Exception was expected');
    } catch (Exception e) {
      System.assert(e instanceof AuraHandledException);
    }
  }

  @isTest
  static void publishGenericEventshouldfailwheninvalideventName() {
    try {
      StreamingMonitorController.publishEvent('GenericEvent', 'unknown', null);
      System.assert(false, 'Exception was expected');
    } catch (Exception e) {
      System.assert(e instanceof AuraHandledException);
    }
  }

  @isTest
  static void publishGenericEventshouldwork() {
    Test.setMock(HttpCalloutMock.class, new MockHttpMulesoftCallouts(200, ''));
    insert new StreamingChannel(Name = '/u/TestSC');

    StreamingMonitorController.publishEvent(
      'GenericEvent',
      'TestSC',
      'TestPayload'
    );

    List<AsyncApexJob> jobs = [SELECT Status, NumberOfErrors FROM AsyncApexJob];
    System.assertEquals(1, jobs.size(), 'Expected an AsyncApexJob');
  }

  @isTest
  static void queueableGenericEventPostshouldfailwhenrestcallfails() {
    Test.setMock(HttpCalloutMock.class, new MockHttpMulesoftCallouts(500, ''));
    StreamingMonitorController.QueueableGenericEventPost post = new StreamingMonitorController.QueueableGenericEventPost(
      '/u/TestSC',
      'TestPayload'
    );

    try {
      post.execute(null);
      System.assert(false, 'Exception was expected');
    } catch (Exception e) {
      System.assert(e instanceof CalloutException);
    }
  }

  @isTest
  static void getAllEventChannelsshouldwork() {
    Map<String, List<StreamingMonitorController.ComboBoxItem>> channels = StreamingMonitorController.getAllEventChannels();
    System.assert(channels.size() > 0, 'Expected a list of channels');
  }

  @isTest
  static void getPushTopicEventChannelsshouldwork() {
    PushTopic pushTopic = new PushTopic();
    pushTopic.Name = 'TestPT';
    pushTopic.Query = 'SELECT Id, Name FROM Account';
    pushTopic.ApiVersion = 56.0;
    pushTopic.NotifyForOperationCreate = true;
    pushTopic.NotifyForOperationUpdate = true;
    pushTopic.NotifyForOperationUndelete = true;
    pushTopic.NotifyForOperationDelete = true;
    pushTopic.NotifyForFields = 'Referenced';
    insert pushTopic;

    List<StreamingMonitorController.ComboBoxItem> channels = StreamingMonitorController.getPushTopicEventChannels();
    System.assertEquals(1, channels.size());
    System.assertEquals('TestPT', channels.get(0).value);
  }

  @isTest
  static void getGenericEventChannelsshouldwork() {
    insert new StreamingChannel(Name = '/u/TestSC');
    List<StreamingMonitorController.ComboBoxItem> channels = StreamingMonitorController.getGenericEventChannels();
    System.assertEquals(1, channels.size());
    System.assertEquals('TestSC', channels.get(0).value);
  }
}
