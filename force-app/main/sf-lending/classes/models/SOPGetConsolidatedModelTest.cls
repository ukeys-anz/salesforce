/**
 * @author Lance Shi
 * @since Nov 2024
 * @description Test class for SOP GetConsolidated model
 */
@IsTest
public class SOPGetConsolidatedModelTest {
  @isTest
  static void testModelParsing() {
    StaticResource sr = [
      SELECT body
      FROM StaticResource
      WHERE Name = 'mock_getConsolidateSOP'
    ];
    SOPGetConsolidatedModel obj = SOPGetConsolidatedModel.parse(
      sr.body.toString()
    );
    System.assert(
      obj.sop.parties.size() == 2,
      'The Parties size should be as expected.'
    );

    for (SOPGetConsolidatedModel.Incomes income : obj.incomesSummary.incomes) {
      SOPGetConsolidatedModel.StartDate sd = income.employment.startDate;
      System.assertEquals(
        sd.getStartDateStr(),
        sd.year + '/' + sd.month + '/' + sd.day,
        'The date format should be correct'
      );
    }

    for (SOPGetConsolidatedModel.Parties party : obj.sop.parties) {
      if (party.get('id') == 'ea1d6d5d-c498-43a9-8a10-91518b6d46e4') {
        System.assertEquals(
          (String) party.get('ocvId'),
          '1000991493',
          'Ocv Id should be matching with the Id'
        );
      }
    }
  }
}
