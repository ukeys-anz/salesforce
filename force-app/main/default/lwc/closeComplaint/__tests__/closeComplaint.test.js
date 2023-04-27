import { createElement } from "lwc";
import CloseComplaintComponent from "c/closeComplaint";
import { getRecord } from "lightning/uiRecordApi";

const CLOSED_STATUS_API_NAME = "Closed";
const DUMMY_RECORD_ID = "5002N00000Dwe1iQAB";

const mockGetCaseRecord = require("./data/getCaseRecord.json");
const mockGetCaseRecordInvalid = require("./data/getCaseRecordInvalid.json");

const validationMessage =
  "Please update Product or Service Name before closing the case.";

describe("c-close-complaint test suite", () => {
  beforeEach(() => {
    const element = createElement("c-close-complaint", {
      is: CloseComplaintComponent
    });
    document.body.appendChild(element);
  });

  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.restoreAllMocks();
  });

  it("close a complaint", () => {
    const element = document.querySelector("c-close-complaint");
    element.recordId = DUMMY_RECORD_ID;
    getRecord.emit(mockGetCaseRecord);
    return Promise.resolve().then(() => {
      const childCompElement = element.shadowRoot.querySelector(
        "c-complaints-Close-Child"
      );
      expect(childCompElement).not.toBeNull;
      expect(childCompElement).not.toBeUndefined;
      const statusSelectElement = element.shadowRoot.querySelector(
        ".statusSelect"
      );
      statusSelectElement.value = CLOSED_STATUS_API_NAME;
      statusSelectElement.dispatchEvent(new CustomEvent("change"));
      return Promise.resolve().then(() => {
        //Select Complaint Outcome
        childCompElement.dispatchEvent(
          new CustomEvent("fieldvalueupdate", {
            detail: {
              field: "IDR_Complaint_Outcome__c",
              value: "1"
            }
          })
        );
        return Promise.resolve().then(() => {
          //Input Description of Outcome
          childCompElement.dispatchEvent(
            new CustomEvent("fieldvalueupdate", {
              detail: {
                field: "IDR_Description_of_Outcome__c",
                value: "Test_Description"
              }
            })
          );
          return Promise.resolve().then(() => {
            //Select Complaint Remedy 1
            childCompElement.dispatchEvent(
              new CustomEvent("fieldvalueupdate", {
                detail: {
                  field: "IDR_Complaint_Remedy__c",
                  value: "1"
                }
              })
            );
            return Promise.resolve().then(() => {
              //Select Complaint Sub Remedy
              childCompElement.dispatchEvent(
                new CustomEvent("fieldvalueupdate", {
                  detail: {
                    field: "IDR_Complaint_Sub_Remedy__c",
                    value: "2"
                  }
                })
              );
              return Promise.resolve().then(() => {
                //Input Financial Amount
                childCompElement.dispatchEvent(
                  new CustomEvent("fieldvalueupdate", {
                    detail: {
                      field: "IDR_Financial_Compensation__c",
                      value: "1000"
                    }
                  })
                );
                return Promise.resolve().then(() => {
                  //Select Remedy 2
                  childCompElement.dispatchEvent(
                    new CustomEvent("fieldvalueupdate", {
                      detail: {
                        field: "Remedy2",
                        value: true
                      }
                    })
                  );
                  return Promise.resolve().then(() => {
                    //Select Complaint Remedy 2
                    childCompElement.dispatchEvent(
                      new CustomEvent("fieldvalueupdate", {
                        detail: {
                          field: "IDR_Complaint_Remedy_2__c",
                          value: "4"
                        }
                      })
                    );
                    return Promise.resolve().then(() => {
                      //Select Complaint Sub Remedy 2
                      childCompElement.dispatchEvent(
                        new CustomEvent("fieldvalueupdate", {
                          detail: {
                            field: "IDR_Complaint_Sub_Remedy_2__c",
                            value: "8"
                          }
                        })
                      );
                      return Promise.resolve().then(() => {
                        //Select Remedy 3
                        childCompElement.dispatchEvent(
                          new CustomEvent("fieldvalueupdate", {
                            detail: {
                              field: "Remedy3",
                              value: true
                            }
                          })
                        );
                        return Promise.resolve().then(() => {
                          //Select Complaint Remedy 3
                          childCompElement.dispatchEvent(
                            new CustomEvent("fieldvalueupdate", {
                              detail: {
                                field: "IDR_Complaint_Remedy_3__c",
                                value: "2"
                              }
                            })
                          );
                          return Promise.resolve().then(() => {
                            //Select Complaint Sub Remedy 3
                            childCompElement.dispatchEvent(
                              new CustomEvent("fieldvalueupdate", {
                                detail: {
                                  field: "IDR_Complaint_Sub_Remedy_3__c",
                                  value: "1"
                                }
                              })
                            );
                            return Promise.resolve().then(() => {
                              //Save Complaint
                              const saveButtonElement = element.shadowRoot.querySelector(
                                ".saveButton"
                              );
                              saveButtonElement.click();
                              return Promise.resolve().then(() => {
                                //Save successful without modal being popped up
                                const modalMessageElement = element.shadowRoot.querySelector(
                                  ".modalMessage"
                                );
                                expect(modalMessageElement).toBeNull();
                              });
                            });
                          });
                        });
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    });
  });

  it("Load close complaint page", () => {
    const element = document.querySelector("c-close-complaint");
    const divElement = element.shadowRoot.querySelector(".title");
    expect(divElement.textContent).toBe("Close Complaint");
  });

  it("display error for invalid case befor closure", () => {
    const element = document.querySelector("c-close-complaint");
    element.recordId = DUMMY_RECORD_ID;
    getRecord.emit(mockGetCaseRecordInvalid);
    return Promise.resolve().then(() => {
      const errorMessageDivElement = element.shadowRoot.querySelector(
        ".validationMessage"
      );
      expect(errorMessageDivElement).not.toBeNull;
      expect(errorMessageDivElement.textContent).toBe(validationMessage);
    });
  });

  it("set recordId and recordTypeId correctly and render child component", () => {
    const element = document.querySelector("c-close-complaint");
    element.recordId = DUMMY_RECORD_ID;
    getRecord.emit(mockGetCaseRecord);
    return Promise.resolve().then(() => {
      const childCompElement = element.shadowRoot.querySelectorAll(
        "c-complaints-close-child"
      );
      expect(childCompElement).not.toBeNull;
      expect(childCompElement.length).toBe(1);
    });
  });

  //********************* Negative Test Scenario **************/
  it("Display error for missing fields", () => {
    const element = document.querySelector("c-close-complaint");
    element.recordId = DUMMY_RECORD_ID;
    getRecord.emit(mockGetCaseRecord);
    return Promise.resolve().then(() => {
      const childCompElement = element.shadowRoot.querySelector(
        "c-complaints-Close-Child"
      );
      expect(childCompElement).not.toBeNull;
      expect(childCompElement).not.toBeUndefined;
      const statusSelectElement = element.shadowRoot.querySelector(
        ".statusSelect"
      );
      statusSelectElement.value = CLOSED_STATUS_API_NAME;
      statusSelectElement.dispatchEvent(new CustomEvent("change"));
      return Promise.resolve().then(() => {
        //Select Complaint Outcome
        childCompElement.dispatchEvent(
          new CustomEvent("fieldvalueupdate", {
            detail: {
              field: "IDR_Complaint_Outcome__c",
              value: "1"
            }
          })
        );
        return Promise.resolve().then(() => {
          //Input Description of Outcome
          childCompElement.dispatchEvent(
            new CustomEvent("fieldvalueupdate", {
              detail: {
                field: "IDR_Description_of_Outcome__c",
                value: "Test_Description"
              }
            })
          );
          return Promise.resolve().then(() => {
            //Select Complaint Remedy 1
            childCompElement.dispatchEvent(
              new CustomEvent("fieldvalueupdate", {
                detail: {
                  field: "IDR_Complaint_Remedy__c",
                  value: "1"
                }
              })
            );
            return Promise.resolve().then(() => {
              //Select Complaint Sub Remedy
              childCompElement.dispatchEvent(
                new CustomEvent("fieldvalueupdate", {
                  detail: {
                    field: "IDR_Complaint_Sub_Remedy__c",
                    value: "2"
                  }
                })
              );
              return Promise.resolve().then(() => {
                //Input Financial Amount
                childCompElement.dispatchEvent(
                  new CustomEvent("fieldvalueupdate", {
                    detail: {
                      field: "IDR_Financial_Compensation__c",
                      value: "1000"
                    }
                  })
                );
                return Promise.resolve().then(() => {
                  //Select Remedy 2
                  childCompElement.dispatchEvent(
                    new CustomEvent("fieldvalueupdate", {
                      detail: {
                        field: "Remedy2",
                        value: true
                      }
                    })
                  );
                  return Promise.resolve().then(() => {
                    //Select Complaint Remedy 2
                    childCompElement.dispatchEvent(
                      new CustomEvent("fieldvalueupdate", {
                        detail: {
                          field: "IDR_Complaint_Remedy_2__c",
                          value: "4"
                        }
                      })
                    );
                    return Promise.resolve().then(() => {
                      //Select Complaint Sub Remedy 2
                      childCompElement.dispatchEvent(
                        new CustomEvent("fieldvalueupdate", {
                          detail: {
                            field: "IDR_Complaint_Sub_Remedy_2__c",
                            value: "8"
                          }
                        })
                      );
                      return Promise.resolve().then(() => {
                        //Select Remedy 3
                        childCompElement.dispatchEvent(
                          new CustomEvent("fieldvalueupdate", {
                            detail: {
                              field: "Remedy3",
                              value: true
                            }
                          })
                        );
                        return Promise.resolve().then(() => {
                          //Select Complaint Remedy 3
                          childCompElement.dispatchEvent(
                            new CustomEvent("fieldvalueupdate", {
                              detail: {
                                field: "IDR_Complaint_Remedy_3__c",
                                value: "2"
                              }
                            })
                          );
                          return Promise.resolve().then(() => {
                            //Dont Select Complaint Sub Remedy 3
                            childCompElement.dispatchEvent(
                              new CustomEvent("fieldvalueupdate", {
                                detail: {
                                  field: "IDR_Complaint_Sub_Remedy_3__c",
                                  value: ""
                                }
                              })
                            );
                            return Promise.resolve().then(() => {
                              //Save Complaint
                              const saveButtonElement = element.shadowRoot.querySelector(
                                ".saveButton"
                              );
                              saveButtonElement.click();
                              return Promise.resolve().then(() => {
                                const modalMessageElement = element.shadowRoot.querySelector(
                                  ".modalMessage"
                                );
                                expect(modalMessageElement.value).toBe(
                                  "Complete Required Fields:Complaint Sub Remedy 3 ,"
                                );
                              });
                            });
                          });
                        });
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    });
  });
});
