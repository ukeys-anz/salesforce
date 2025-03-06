/**
 * @author Hitesh
 * @since 02/2024
 * @description Test Class for MLCRMContentDocDeleteQueueable
 */
@isTest
public class MLCRMContentDocDeleteQueueableTest {
  static Lib_MockProvider cdRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    cdRepoMock = Lib_MockProvider.forType(
      CCRMContentDocumentLinkRepository.class
    );
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
    MLCRMContentDocDeleteQueueable q = new MLCRMContentDocDeleteQueueable(
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
      'MLCRMContentDocDeleteQueueable is not deleting content documents'
    );
  }
}
