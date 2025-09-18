/**
 * @author Hitesh
 * @since 02/2024
 * @description Test Class for ContentDocDeleteQueueable
 */
@isTest
public class ContentDocDeleteQueueableTest {
  static Lib_MockProvider cdRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    cdRepoMock = Lib_MockProvider.forType(ContentDocumentLinkRepository.class);
  }

  @isTest
  static void testExecute() {
    registerMocks();

    List<ContentDocument> cdList = new List<ContentDocument>();
    cdList.add(
      new ContentDocument(
        Id = Lib_FakeIdGenerator.getMockId(ContentDocument.getSobjectType())
      )
    );
    cdList.add(
      new ContentDocument(
        Id = Lib_FakeIdGenerator.getMockId(ContentDocument.getSobjectType())
      )
    );
    cdRepoMock.mock('getContentDocuments', cdList);

    //WHEN calling a method
    Test.startTest();
    ContentDocDeleteQueueable q = new ContentDocDeleteQueueable(
      new List<id>{
        Lib_FakeIdGenerator.getMockId(ContentDocument.getSobjectType())
      }
    );
    q.execute(null);
    Test.stopTest();

    //THEN it should delete content document record.
    Assert.areEqual(
      2,
      ((List<ContentDocument>) dmlRepoMock.getHistory('doDelete')
          .getParam('records'))
        .size(),
      'ContentDocDeleteQueueable is not deleting content documents'
    );
  }
}
