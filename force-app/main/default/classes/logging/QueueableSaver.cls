/**
 * @author Jasmine Nguyen
 * @since June 2022
 * @group Logging
 * @description  A logging class for publishing log entries via the Queueable interface.
 */
public class QueueableSaver implements Queueable {
  public List<SObject> logEntryEvents = new List<SObject>();

  /**
   * @description Constructor of QueueableSaver class
   * @param logEntryEvents Log entry events to publish
   */
  public QueueableSaver(List<SObject> logEntryEvents) {
    this.logEntryEvents = logEntryEvents;
  }

  /**
   * @description Required by the Queueable interface, this method contains the logic executed when the current instance of the queue runs.
   * @param queueableContext The context of the current queue.
   */
  public void execute(System.QueueableContext queueableContext) {
    PlatformEventUtils.publishEvents(logEntryEvents);
  }
}
