import { exec } from "child_process";
import fs from "fs";

let accRecId = "";
let entitlementProcessRec = "";

const createCMOSEntitlement = (username) =>
  exec(
    "sf data import tree -p data/IDR-EntitlementAccCreate.json --json" +
      (username ? ` -o ${username}` : ""),
    (err, stdout, stderr) => {
      if (err) {
        console.log(`error: ${err.message}`);
      }
      if (stderr) {
        console.log(`stderr here: ${stderr}`);
      }
      if (stdout) {
        let insertResult = JSON.parse(stdout).result;
        if (insertResult.length) {
          accRecId = insertResult[0].id;
        }
        //extract the id of SlaProcess (I.e Entitlement Process) for complaint.
        exec(
          "sf data query -q \"Select Id from SlaProcess Where Name= 'Complaints'\" --json" +
            (username ? ` -o ${username}` : ""),
          (err, stdout, stderr) => {
            if (err) {
              console.log(`error: ${err.message}`);
            }
            if (stderr) {
              console.log(`stderr: ${stderr}`);
            }

            let result = JSON.parse(stdout).result;
            if (result.records.length) {
              entitlementProcessRec = result.records[0].Id;
            }
            //prepare entitlement record .
            if (accRecId && entitlementProcessRec) {
              let entitlementRec = {
                records: [
                  {
                    attributes: {
                      type: "Entitlement",
                      referenceId: "EntitlementRef1"
                    },
                    Name: "Complaints Entitlement",
                    AccountId: accRecId,
                    SlaProcessId: entitlementProcessRec,
                    StartDate: "2020-11-25"
                  }
                ]
              };
              //write the record to file.
              fs.writeFile(
                "data/IDR-Entitlment.json",
                JSON.stringify(entitlementRec),
                (err) => {
                  if (err) {
                    throw err;
                  }
                  //create the entitlemnt record.
                  exec(
                    "sf data import tree -p data/IDR-CreateCmosEntitlment.json --json" +
                      (username ? ` -o ${username}` : ""),
                    (err, stdout, stderr) => {
                      if (err) {
                        console.log(`error: ${err.message}`);
                      }
                      if (stderr) {
                        console.log(`stderr: ${stderr}`);
                      }
                      if (stdout) {
                        console.log(stdout);
                      }
                    }
                  );
                }
              );
            }
          }
        );
      }
    }
  );

export { createCMOSEntitlement };
