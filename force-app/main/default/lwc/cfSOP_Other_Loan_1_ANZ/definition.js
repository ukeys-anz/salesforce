let definition = {
  states: [
    {
      fields: [],
      conditions: {
        id: "state-condition-object",
        isParent: true,
        group: [
          {
            id: "state-new-condition-39",
            field: "debtType",
            operator: "==",
            value: "Personal Loan",
            type: "custom",
            hasMergeField: false
          }
        ]
      },
      definedActions: { actions: [] },
      name: "Active",
      isSmartAction: false,
      smartAction: {},
      styleObject: {
        padding: [{ type: "around", size: "x-small", label: "around:x-small" }],
        margin: [{ type: "around", size: "none", label: "around:none" }],
        container: { class: "slds-card" },
        size: { isResponsive: false, default: "6" },
        sizeClass: "slds-size_6-of-12 ",
        class: "slds-card slds-p-around_x-small slds-m-around_none ",
        background: {
          color: "",
          image: "",
          size: "",
          repeat: "",
          position: ""
        },
        border: { type: "", width: "", color: "", radius: "", style: "" },
        elementStyleProperties: {},
        text: { align: "", color: "" },
        inlineStyle: "",
        style: "      \n         "
      },
      components: {
        "layer-0": {
          children: [
            {
              name: "Block",
              element: "block",
              size: { isResponsive: false, default: "12" },
              stateIndex: 0,
              class: "slds-col ",
              property: {
                label: "Block",
                collapsible: false,
                record: "{record}",
                collapsedByDefault: false,
                card: "{card}"
              },
              type: "block",
              styleObject: {
                padding: [
                  { type: "around", size: "x-small", label: "around:x-small" }
                ],
                class:
                  "slds-theme_default slds-border_top slds-border_right slds-border_bottom slds-border_left slds-p-around_x-small ",
                sizeClass: "slds-size_12-of-12 ",
                size: { isResponsive: false, default: "12" },
                margin: [],
                background: {
                  color: "",
                  image: "",
                  size: "",
                  repeat: "",
                  position: ""
                },
                container: { class: "" },
                border: {
                  type: [
                    "border_top",
                    "border_right",
                    "border_bottom",
                    "border_left"
                  ],
                  width: "1",
                  color: "#cccccc",
                  radius: "5px",
                  style: ""
                },
                elementStyleProperties: {},
                text: { align: "", color: "" },
                inlineStyle: "",
                style:
                  "     border-top: #cccccc 1px solid;border-right: #cccccc 1px solid;border-bottom: #cccccc 1px solid;border-left: #cccccc 1px solid; \n    border-radius:5px;     ",
                theme: "theme_default",
                maxHeight: "",
                minHeight: "",
                height: ""
              },
              children: [
                {
                  name: "Image",
                  element: "flexImg",
                  size: { isResponsive: false, default: 4 },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    card: "{card}",
                    size: "",
                    extraclass: "slds-align_absolute-center",
                    stateImg: {
                      imgsrc:
                        "/sfc/servlet.shepherd/version/download/0688r000001BFRNAA4",
                      alternativeText: "Image description",
                      document: {
                        label: "ANZ Plus lotus (1) (Version:1)",
                        value:
                          "/sfc/servlet.shepherd/version/download/0688r000001BFRNAA4",
                        title: "ANZ Plus lotus (1)",
                        Id: "0688r000001BFRNAA4",
                        attachmentType: "ContentVersion"
                      }
                    }
                  },
                  type: "element",
                  styleObject: {
                    size: { isResponsive: false, default: 4 },
                    sizeClass: "slds-size_4-of-12"
                  },
                  elementLabel: "Block-0-Image-0",
                  key: "element_element_block_0_0_flexImg_0_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  key: "element_element_block_0_0_outputField_1_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: 8 },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%7Baccount.financialInstitution%7D%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    size: { isResponsive: false, default: 8 },
                    sizeClass: "slds-size_8-of-12 ",
                    padding: [],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "left", color: "" },
                    inlineStyle: "",
                    class: "slds-text-align_left ",
                    style: "      \n         "
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-0-Text-1",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        size: { isResponsive: false, default: 8 },
                        sizeClass: "slds-size_8-of-12 ",
                        padding: [],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        container: { class: "" },
                        border: {
                          type: "",
                          width: "",
                          color: "",
                          radius: "",
                          style: ""
                        },
                        elementStyleProperties: {},
                        text: { align: "left", color: "" },
                        inlineStyle: "",
                        class: "slds-text-align_left ",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ]
                },
                {
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "8" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField: "%3Cdiv%3EBelongs%20to%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    size: { isResponsive: false, default: "8" },
                    sizeClass: "slds-size_8-of-12 ",
                    padding: [],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "center", color: "" },
                    inlineStyle: "",
                    class: "slds-text-align_center ",
                    style: "      \n         "
                  },
                  elementLabel: "Block-0-Text-2",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        size: { isResponsive: false, default: "8" },
                        sizeClass: "slds-size_8-of-12 ",
                        padding: [],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        container: { class: "" },
                        border: {
                          type: "",
                          width: "",
                          color: "",
                          radius: "",
                          style: ""
                        },
                        elementStyleProperties: {},
                        text: { align: "center", color: "" },
                        inlineStyle: "",
                        class: "slds-text-align_center ",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ],
                  key: "element_element_block_0_0_outputField_2_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "3" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField: "%3Cdiv%3E%7BownerName%7D%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    size: { isResponsive: false, default: "3" },
                    sizeClass: "slds-size_3-of-12 ",
                    padding: [],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    class: "",
                    style: "      \n         "
                  },
                  elementLabel: "Block-0-Text-3",
                  key: "element_element_block_0_0_outputField_3_0",
                  parentElementKey: "element_block_0_0",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        size: { isResponsive: false, default: "3" },
                        sizeClass: "slds-size_3-of-12 ",
                        padding: [],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        container: { class: "" },
                        border: {
                          type: "",
                          width: "",
                          color: "",
                          radius: "",
                          style: ""
                        },
                        elementStyleProperties: {},
                        text: { align: "", color: "" },
                        inlineStyle: "",
                        class: "",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ]
                },
                {
                  name: "Field",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    placeholder: "",
                    record: "{record}",
                    type: "text",
                    card: "{card}"
                  },
                  type: "element",
                  styleObject: {
                    size: { isResponsive: false, default: "12" },
                    sizeClass: "slds-size_12-of-12 "
                  },
                  elementLabel: "Block-0-Field-4",
                  key: "element_element_block_0_0_outputField_4_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  key: "element_element_block_0_0_outputField_5_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "8" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField: "%3Cdiv%3EDebt%20Type%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_8-of-12 ",
                    padding: [],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    size: { isResponsive: false, default: "8" },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "center", color: "" },
                    inlineStyle: "",
                    class: "slds-text-align_center ",
                    style: "      \n         "
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-0-Text-5",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_8-of-12 ",
                        padding: [],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        size: { isResponsive: false, default: "8" },
                        container: { class: "" },
                        border: {
                          type: "",
                          width: "",
                          color: "",
                          radius: "",
                          style: ""
                        },
                        elementStyleProperties: {},
                        text: { align: "center", color: "" },
                        inlineStyle: "",
                        class: "slds-text-align_center ",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ]
                },
                {
                  key: "element_element_block_0_0_outputField_6_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: 4 },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField: "%3Cdiv%3EPersonal%20Loan%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    size: { isResponsive: false, default: 4 },
                    sizeClass: "slds-size_4-of-12"
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-0-Text-6"
                },
                {
                  key: "element_element_block_0_0_outputField_7_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField: "",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-0-Text-7"
                },
                {
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "8" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField: "%3Cdiv%3EInstitution%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_8-of-12 ",
                    size: { isResponsive: false, default: "8" },
                    padding: [],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "center", color: "" },
                    inlineStyle: "",
                    class: "slds-text-align_center ",
                    style: "      \n         "
                  },
                  elementLabel: "Block-0-Text-8",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_8-of-12 ",
                        size: { isResponsive: false, default: "8" },
                        padding: [],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        container: { class: "" },
                        border: {
                          type: "",
                          width: "",
                          color: "",
                          radius: "",
                          style: ""
                        },
                        elementStyleProperties: {},
                        text: { align: "center", color: "" },
                        inlineStyle: "",
                        class: "slds-text-align_center ",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ],
                  key: "element_element_block_0_0_outputField_8_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "4" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%7BinstitutionalLiability.financialInstitution%7D%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_4-of-12 ",
                    padding: [],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    size: { isResponsive: false, default: "4" },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    class: "",
                    style: "      \n         "
                  },
                  elementLabel: "Block-0-Text-9",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_4-of-12 ",
                        padding: [],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        size: { isResponsive: false, default: "4" },
                        container: { class: "" },
                        border: {
                          type: "",
                          width: "",
                          color: "",
                          radius: "",
                          style: ""
                        },
                        elementStyleProperties: {},
                        text: { align: "", color: "" },
                        inlineStyle: "",
                        class: "",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ],
                  key: "element_element_block_0_0_outputField_9_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  name: "Field",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    placeholder: "",
                    record: "{record}",
                    type: "text",
                    card: "{card}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  elementLabel: "Field-3",
                  userUpdatedElementLabel: true,
                  key: "element_element_block_0_0_outputField_10_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "8" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField: "%3Cdiv%3EScheduled%20Balance%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_8-of-12 ",
                    padding: [],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    size: { isResponsive: false, default: "8" },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "center", color: "" },
                    inlineStyle: "",
                    class: "slds-text-align_center ",
                    style: "      \n         "
                  },
                  elementLabel: "Block-0-Text-11",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_8-of-12 ",
                        padding: [],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        size: { isResponsive: false, default: "8" },
                        container: { class: "" },
                        border: {
                          type: "",
                          width: "",
                          color: "",
                          radius: "",
                          style: ""
                        },
                        elementStyleProperties: {},
                        text: { align: "center", color: "" },
                        inlineStyle: "",
                        class: "slds-text-align_center ",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ],
                  key: "element_element_block_0_0_outputField_11_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "3" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E$%7BoutstandingBalance.value%7D%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_3-of-12 ",
                    size: { isResponsive: false, default: "3" }
                  },
                  elementLabel: "Block-0-Text-2",
                  userUpdatedElementLabel: true,
                  key: "element_element_block_0_0_outputField_12_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  key: "element_element_block_0_0_outputField_13_0",
                  name: "Field",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    placeholder: "",
                    record: "{record}",
                    type: "text",
                    card: "{card}",
                    fieldName: ""
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-0-Field-2",
                  userUpdatedElementLabel: true
                },
                {
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "8" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField: "%3Cdiv%3ERemaining%20P&amp;I%20Term%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_8-of-12 ",
                    size: { isResponsive: false, default: "8" },
                    padding: [],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "center", color: "" },
                    inlineStyle: "",
                    class: "slds-text-align_center ",
                    style: "      \n         "
                  },
                  elementLabel: "Block-0-Text-3",
                  key: "element_element_block_0_0_outputField_14_0",
                  parentElementKey: "element_block_0_0",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_8-of-12 ",
                        size: { isResponsive: false, default: "8" },
                        padding: [],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        container: { class: "" },
                        border: {
                          type: "",
                          width: "",
                          color: "",
                          radius: "",
                          style: ""
                        },
                        elementStyleProperties: {},
                        text: { align: "center", color: "" },
                        inlineStyle: "",
                        class: "slds-text-align_center ",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ],
                  userUpdatedElementLabel: true
                },
                {
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "2" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%7BinstitutionalLiability.principalInterestRemainingTerm%7D%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_2-of-12 ",
                    size: { isResponsive: false, default: "2" }
                  },
                  elementLabel: "Block-0-Text-4",
                  userUpdatedElementLabel: true,
                  key: "element_element_block_0_0_outputField_15_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  name: "Field",
                  element: "outputField",
                  size: { isResponsive: false, default: 0 },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    placeholder: "",
                    record: "{record}",
                    type: "text",
                    card: "{card}"
                  },
                  type: "element",
                  styleObject: {
                    size: { isResponsive: false, default: 0 },
                    sizeClass: "slds-size_12-of-12"
                  },
                  elementLabel: "Block-0-Field-16",
                  key: "element_element_block_0_0_outputField_16_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "8" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField: "%3Cdiv%3ERepayment%20Amount%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_8-of-12 ",
                    size: { isResponsive: false, default: "8" },
                    padding: [],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "center", color: "" },
                    inlineStyle: "",
                    class: "slds-text-align_center ",
                    style: "      \n         "
                  },
                  elementLabel: "Block-0-Text-17",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_8-of-12 ",
                        size: { isResponsive: false, default: "8" },
                        padding: [],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        container: { class: "" },
                        border: {
                          type: "",
                          width: "",
                          color: "",
                          radius: "",
                          style: ""
                        },
                        elementStyleProperties: {},
                        text: { align: "center", color: "" },
                        inlineStyle: "",
                        class: "slds-text-align_center ",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ],
                  key: "element_element_block_0_0_outputField_17_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "3" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E$%7BinstitutionalLiability.repaymentAmount.value%7D%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_3-of-12 ",
                    size: { isResponsive: false, default: "3" }
                  },
                  elementLabel: "Block-0-Text-18",
                  key: "element_element_block_0_0_outputField_18_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  name: "Field",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    placeholder: "",
                    record: "{record}",
                    type: "text",
                    card: "{card}"
                  },
                  type: "element",
                  styleObject: {
                    size: { isResponsive: false, default: "12" },
                    sizeClass: "slds-size_12-of-12 "
                  },
                  elementLabel: "Block-0-Field-19",
                  key: "element_element_block_0_0_outputField_19_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "8" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField: "%3Cdiv%3ERepayment%20Frequency%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_8-of-12 ",
                    padding: [],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    size: { isResponsive: false, default: "8" },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "center", color: "" },
                    inlineStyle: "",
                    class: "slds-text-align_center ",
                    style: "      \n         "
                  },
                  elementLabel: "Block-0-Text-20",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_8-of-12 ",
                        padding: [],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        size: { isResponsive: false, default: "8" },
                        container: { class: "" },
                        border: {
                          type: "",
                          width: "",
                          color: "",
                          radius: "",
                          style: ""
                        },
                        elementStyleProperties: {},
                        text: { align: "center", color: "" },
                        inlineStyle: "",
                        class: "slds-text-align_center ",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ],
                  key: "element_element_block_0_0_outputField_20_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  key: "element_element_block_0_0_outputField_21_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: 4 },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%7BinstitutionalLiability.repaymentFrequency%7D%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    size: { isResponsive: false, default: 4 },
                    sizeClass: "slds-size_4-of-12"
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-0-Text-21"
                },
                {
                  key: "element_element_block_0_0_outputField_22_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: 12 },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField: "",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    size: { isResponsive: false, default: 12 },
                    sizeClass: "slds-size_12-of-12"
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-0-Text-22"
                },
                {
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "8" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField: "%3Cdiv%3EInterest%20Rate%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_8-of-12 ",
                    size: { isResponsive: false, default: "8" },
                    padding: [],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "center", color: "" },
                    inlineStyle: "",
                    class: "slds-text-align_center ",
                    style: "      \n         "
                  },
                  elementLabel: "Block-0-Text-23",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_8-of-12 ",
                        size: { isResponsive: false, default: "8" },
                        padding: [],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        container: { class: "" },
                        border: {
                          type: "",
                          width: "",
                          color: "",
                          radius: "",
                          style: ""
                        },
                        elementStyleProperties: {},
                        text: { align: "center", color: "" },
                        inlineStyle: "",
                        class: "slds-text-align_center ",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ],
                  key: "element_element_block_0_0_outputField_23_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  key: "element_element_block_0_0_outputField_24_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: 4 },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%7BinstitutionalLiability.interestRate%7D%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    size: { isResponsive: false, default: 4 },
                    sizeClass: "slds-size_4-of-12"
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-0-Text-24"
                },
                {
                  key: "element_element_block_0_0_outputField_25_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField: "",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-0-Text-25"
                },
                {
                  name: "Field",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    placeholder: "",
                    record: "{record}",
                    type: "text",
                    card: "{card}"
                  },
                  type: "element",
                  styleObject: {
                    size: { isResponsive: false, default: "12" },
                    sizeClass: "slds-size_12-of-12 ",
                    padding: [],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    class: "",
                    style: "      \n         "
                  },
                  elementLabel: "Block-0-Field-26",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        size: { isResponsive: false, default: "12" },
                        sizeClass: "slds-size_12-of-12 ",
                        padding: [],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        container: { class: "" },
                        border: {
                          type: "",
                          width: "",
                          color: "",
                          radius: "",
                          style: ""
                        },
                        elementStyleProperties: {},
                        text: { align: "", color: "" },
                        inlineStyle: "",
                        class: "",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ],
                  key: "element_element_block_0_0_outputField_26_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  name: "Field",
                  element: "outputField",
                  size: { isResponsive: false, default: "8" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    placeholder: "Last Modified:",
                    record: "{record}",
                    type: "text",
                    card: "{card}"
                  },
                  type: "element",
                  styleObject: {
                    sizeClass: "slds-size_8-of-12 ",
                    padding: [],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    size: { isResponsive: false, default: "8" },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "right", color: "" },
                    inlineStyle: "",
                    class: "slds-text-align_right ",
                    style: "      \n         "
                  },
                  elementLabel: "Block-0-Field-27",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_8-of-12 ",
                        padding: [],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        size: { isResponsive: false, default: "8" },
                        container: { class: "" },
                        border: {
                          type: "",
                          width: "",
                          color: "",
                          radius: "",
                          style: ""
                        },
                        elementStyleProperties: {},
                        text: { align: "right", color: "" },
                        inlineStyle: "",
                        class: "slds-text-align_right ",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ],
                  key: "element_element_block_0_0_outputField_27_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  name: "Field",
                  element: "outputField",
                  size: { isResponsive: false, default: "4" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    placeholder: "output",
                    record: "{record}",
                    type: "datetime",
                    card: "{card}",
                    format: "DD MMM YYYY| h:mm a",
                    fieldName: "updateTime"
                  },
                  type: "element",
                  styleObject: {
                    sizeClass: "slds-size_4-of-12 ",
                    padding: [],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    size: { isResponsive: false, default: "4" },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "right", color: "" },
                    inlineStyle: "",
                    class: "slds-text-align_right ",
                    style: "      \n         "
                  },
                  elementLabel: "Block-0-Field-28",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_4-of-12 ",
                        padding: [],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        size: { isResponsive: false, default: "4" },
                        container: { class: "" },
                        border: {
                          type: "",
                          width: "",
                          color: "",
                          radius: "",
                          style: ""
                        },
                        elementStyleProperties: {},
                        text: { align: "right", color: "" },
                        inlineStyle: "",
                        class: "slds-text-align_right ",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ],
                  key: "element_element_block_0_0_outputField_28_0",
                  parentElementKey: "element_block_0_0"
                }
              ],
              elementLabel: "Block-0",
              styleObjects: [
                {
                  key: 0,
                  conditions: "default",
                  styleObject: {
                    padding: [
                      {
                        type: "around",
                        size: "x-small",
                        label: "around:x-small"
                      }
                    ],
                    class:
                      "slds-theme_default slds-border_top slds-border_right slds-border_bottom slds-border_left slds-p-around_x-small ",
                    sizeClass: "slds-size_12-of-12 ",
                    size: { isResponsive: false, default: "12" },
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    container: { class: "" },
                    border: {
                      type: [
                        "border_top",
                        "border_right",
                        "border_bottom",
                        "border_left"
                      ],
                      width: "1",
                      color: "#cccccc",
                      radius: "5px",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    style:
                      "     border-top: #cccccc 1px solid;border-right: #cccccc 1px solid;border-bottom: #cccccc 1px solid;border-left: #cccccc 1px solid; \n    border-radius:5px;     ",
                    theme: "theme_default",
                    maxHeight: "",
                    minHeight: "",
                    height: ""
                  },
                  label: "Default",
                  name: "Default",
                  conditionString: "",
                  draggable: false
                }
              ]
            }
          ]
        }
      },
      childCards: [],
      actions: [],
      omniscripts: [],
      documents: [
        {
          Id: "0688r000001BFRNAA4",
          developerName: "ANZ Plus lotus (1)",
          type: "ContentVersion"
        }
      ]
    }
  ],
  dataSource: {
    type: "ApexRemote",
    value: {
      dsDelay: "",
      resultVar: '["object"]["assets"]',
      remoteClass: "ResidentialLoanApplicationController",
      remoteMethod: "getListAssets",
      vlocityAsync: false
    },
    orderBy: { name: "estimatedValue.value", isReverse: "true" },
    contextVariables: []
  },
  title: "SOP_Other_Loan",
  enableLwc: true,
  isFlex: true,
  theme: "slds",
  selectableMode: "Multi",
  dynamicCanvasWidth: { type: "desktop" },
  requiredPermission: "",
  lwc: {
    DeveloperName: "cfSOP_Other_Loan_1_ANZ",
    Id: "0Rb8s000000Wk69CAC",
    MasterLabel: "cfSOP_Other_Loan_1_ANZ",
    NamespacePrefix: "c",
    ManageableState: "unmanaged"
  },
  Id: "0ko8s0000000FGnAAM",
  OmniUiCardKey: "SOP_Other_Loan/ANZ/1.0",
  OmniUiCardType: "Child"
};
export default definition;
