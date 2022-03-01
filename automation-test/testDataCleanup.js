require("dotenv").config();

export function cleanupTestData() {
  console.log("CLEANING UP TEST DATA");
  var jsforce = require("jsforce");
  var conn = new jsforce.Connection({
    loginUrl: process.env.TESTURL
  });

  conn.login(
    process.env.USERNAME,
    process.env.PASSWORD,
    function (err, userInfo) {
      if (err) {
        return console.error(err);
      }
      var userId;
      conn.query(
        "SELECT Id FROM User WHERE Username =" +
          "'" +
          process.env.USERNAME +
          "'",
        function (err, result) {
          if (err) {
            return console.error(err);
          }
          if (result.totalSize == 1) {
            userId = result.records[0].Id;
          }

          deleteTestCases(userId); // Delete test cases
          // Only cases are created by the tests at the moment, we will need to clean up other
          // types of data e.g. accounts, contacts if they are created by the tests in the future
        }
      );
    }
  );
}

var deleteTestCases = (userId) => {
  console.log("DELETING CASES");
  conn
    .sobject("Case")
    .find({ CreatedById: userId })
    .destroy(function (err, rets) {
      if (err) {
        return console.error(err);
      }
      let numberOfDeletedCase = 0;
      rets.forEach((ret) => {
        if (ret.success) {
          numberOfDeletedCase++;
        }
      });
      console.log("Number of deleted cases: " + numberOfDeletedCase);
    });
};
