let definition = {
  states: [
    {
      fields: [],
      conditions: { id: "state-condition-object", isParent: true, group: [] },
      definedActions: { actions: [] },
      name: "Active",
      isSmartAction: false,
      smartAction: {},
      styleObject: {
        padding: [{ type: "around", size: "x-small", label: "around:x-small" }],
        margin: [],
        container: { class: "slds-card" },
        size: { isResponsive: false, default: "12" },
        sizeClass: "slds-size_12-of-12 ",
        class: "slds-card slds-p-around_x-small ",
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
                padding: [{ type: "around", size: "x-small" }],
                class: "slds-p-around_x-small",
                sizeClass: "slds-size_12-of-12"
              },
              children: [
                {
                  key: "element_element_block_0_0_outputField_0_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "10" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cspan%20style=%22font-size:%2018pt;%22%3E%3Cstrong%3EFinances%3C/strong%3E%3C/span%3E%3C/div%3E%0A%3Cdiv%3E&nbsp;%3C/div%3E%0A%3Cdiv%3E%3Cspan%20style=%22font-size:%2010pt;%22%3ESome%20details%20are%20pre-filled%20from%20the%20customer's%20account%20and%20they%20will%20need%20to%20review%20and%20confirm%20each%20section.%3C/span%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_10-of-12 ",
                    size: { isResponsive: false, default: "10" }
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-0-Text-0"
                },
                {
                  name: "Action",
                  element: "action",
                  size: { isResponsive: false, default: "2" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    label: "Refresh all balances",
                    iconName: "standard-default",
                    record: "{record}",
                    card: "{card}",
                    stateObj: "{record}",
                    actionList: [
                      {
                        stateAction: {
                          id: "flex-action-1684285592124",
                          type: "cardAction",
                          targetType: "Web Page",
                          openUrlIn: "Current Window",
                          "Web Page": { targetName: "/apex" },
                          eventName: "reload"
                        },
                        key: "1684285539094-nz5ktqjrg",
                        label: "Action",
                        draggable: false,
                        isOpen: true,
                        actionIndex: 0
                      }
                    ],
                    showSpinner: "false",
                    flyoutDetails: {},
                    hideActionIcon: true,
                    displayAsButton: true,
                    buttonVariant: "neutral"
                  },
                  type: "element",
                  styleObject: {
                    sizeClass: "slds-size_2-of-12 ",
                    size: { isResponsive: false, default: "2" },
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
                    text: { align: "right", color: "" },
                    inlineStyle: "",
                    class: "slds-text-align_right ",
                    style: "      \n         "
                  },
                  elementLabel: "Block-0-Action-1",
                  key: "element_element_block_0_0_action_1_0",
                  parentElementKey: "element_block_0_0",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_2-of-12 ",
                        size: { isResponsive: false, default: "2" },
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
                  ]
                }
              ],
              elementLabel: "Block-0"
            },
            {
              name: "Block",
              element: "block",
              size: { isResponsive: false, default: "12" },
              stateIndex: 0,
              class: "slds-col ",
              property: {
                label: "Savings",
                collapsible: true,
                record: "{record}",
                collapsedByDefault: true,
                card: "{card}",
                styles: { label: { textDecoration: "", color: "" } },
                action: null
              },
              type: "block",
              styleObject: {
                padding: [
                  { type: "around", size: "x-small", label: "around:x-small" }
                ],
                class: " slds-p-around_x-small title_color",
                sizeClass: "slds-size_12-of-12 ",
                margin: [],
                background: {
                  color: "",
                  image: "",
                  size: "",
                  repeat: "",
                  position: ""
                },
                size: { isResponsive: false, default: "12" },
                container: { class: "" },
                border: {
                  type: [],
                  width: "",
                  color: "#cccccc",
                  radius: "",
                  style: ""
                },
                elementStyleProperties: {
                  styles: { label: { textDecoration: "", color: "" } }
                },
                text: { align: "", color: "" },
                inlineStyle: "",
                style: "      \n         ",
                customClass: "title_color"
              },
              children: [
                {
                  key: "element_element_block_1_0_outputField_0_0",
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
                    label: ""
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Field-0"
                },
                {
                  key: "element_element_block_1_0_outputField_1_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3EThis%20includes%20any%20cash%20and%20money%20in%20your%20bank%20accounts.%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Text-1"
                },
                {
                  key: "element_element_block_1_0_outputField_2_0",
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
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Field-2"
                },
                {
                  key: "element_element_block_1_0_outputField_3_0",
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
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Field-3"
                },
                {
                  key: "element_element_block_1_0_outputField_4_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cspan%20style=%22color:%20#000000;%20font-family:%20'Salesforce%20Sans',%20Arial,%20sans-serif;%22%3E%3Cstrong%3EANZ%20Plus%3C/strong%3E%3C/span%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_12-of-12 ",
                    padding: [
                      { type: "left", size: "medium", label: "left:medium" }
                    ],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    size: { isResponsive: false, default: "12" },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "", color: "#000000" },
                    inlineStyle: "",
                    class: "slds-p-left_medium ",
                    style: "      \n        color:#000000; "
                  },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Text-4",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_12-of-12 ",
                        padding: [
                          { type: "left", size: "medium", label: "left:medium" }
                        ],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        size: { isResponsive: false, default: "12" },
                        container: { class: "" },
                        border: {
                          type: "",
                          width: "",
                          color: "",
                          radius: "",
                          style: ""
                        },
                        elementStyleProperties: {},
                        text: { align: "", color: "#000000" },
                        inlineStyle: "",
                        class: "slds-p-left_medium ",
                        style: "      \n        color:#000000; "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ]
                },
                {
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_ANZPlus",
                    recordId: "{recordId}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false,
                    cardNode: "{record.assets}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  elementLabel: "FlexCard-1",
                  key: "element_element_block_1_0_childCardPreview_5_0",
                  parentElementKey: "element_block_1_0",
                  userUpdatedElementLabel: true
                },
                {
                  key: "element_element_block_1_0_outputField_6_0",
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
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Field-6"
                },
                {
                  key: "element_element_block_1_0_outputField_7_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cspan%20style=%22color:%20#000000;%22%3E%3Cstrong%3EANZ%3C/strong%3E%3C/span%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_12-of-12 ",
                    padding: [
                      { type: "left", size: "medium", label: "left:medium" }
                    ],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    size: { isResponsive: false, default: "12" },
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
                    class: "slds-p-left_medium ",
                    style: "      \n         "
                  },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Text-7",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_12-of-12 ",
                        padding: [
                          { type: "left", size: "medium", label: "left:medium" }
                        ],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        size: { isResponsive: false, default: "12" },
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
                        class: "slds-p-left_medium ",
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
                  key: "element_element_block_1_0_childCardPreview_8_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_ANZ3",
                    recordId: "{recordId}",
                    cardNode: "{record.assets}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false
                  },
                  type: "element",
                  styleObject: {
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
                    size: { isResponsive: false, default: "12" },
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
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-FlexCard-8",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
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
                        size: { isResponsive: false, default: "12" },
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
                  key: "element_element_block_1_0_outputField_9_0",
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
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Field-9"
                },
                {
                  key: "element_element_block_1_0_outputField_10_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3EOther%20Institutions%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_12-of-12 ",
                    padding: [
                      { type: "left", size: "medium", label: "left:medium" }
                    ],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    size: { isResponsive: false, default: "12" },
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
                    class: "slds-p-left_medium ",
                    style: "      \n         "
                  },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Text-10",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_12-of-12 ",
                        padding: [
                          { type: "left", size: "medium", label: "left:medium" }
                        ],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        size: { isResponsive: false, default: "12" },
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
                        class: "slds-p-left_medium ",
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
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Other_Banks",
                    recordId: "{recordId}",
                    cardNode: "{record.assets}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  elementLabel: "Your Savings-FlexCard-11",
                  key: "element_element_block_1_0_childCardPreview_11_0",
                  parentElementKey: "element_block_1_0"
                },
                {
                  key: "element_element_block_1_0_outputField_12_0",
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
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Field-12"
                },
                {
                  key: "element_element_block_1_0_outputField_13_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3ECash%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_12-of-12 ",
                    padding: [
                      { type: "left", size: "medium", label: "left:medium" }
                    ],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    size: { isResponsive: false, default: "12" },
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
                    class: "slds-p-left_medium ",
                    style: "      \n         "
                  },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Text-13",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_12-of-12 ",
                        padding: [
                          { type: "left", size: "medium", label: "left:medium" }
                        ],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        size: { isResponsive: false, default: "12" },
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
                        class: "slds-p-left_medium ",
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
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Other",
                    recordId: "{recordId}",
                    cardNode: "{record.assets}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false
                  },
                  type: "element",
                  styleObject: {
                    sizeClass: "slds-size_12-of-12 ",
                    padding: [],
                    margin: [
                      { type: "right", size: "large", label: "right:large" }
                    ],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    size: { isResponsive: false, default: "12" },
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
                    class: "slds-m-right_large ",
                    style: "      \n         "
                  },
                  elementLabel: "Your Savings-FlexCard-14",
                  key: "element_element_block_1_0_childCardPreview_14_0",
                  parentElementKey: "element_block_1_0",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_12-of-12 ",
                        padding: [],
                        margin: [
                          { type: "right", size: "large", label: "right:large" }
                        ],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        size: { isResponsive: false, default: "12" },
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
                        class: "slds-m-right_large ",
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
                  key: "element_element_block_1_0_childCardPreview_15_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Message_Flex",
                    recordId: "{recordId}",
                    cardNode: "{record.assets}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-FlexCard-15"
                }
              ],
              elementLabel: "Your Savings",
              userUpdatedElementLabel: true,
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
                    class: " slds-p-around_x-small title_color",
                    sizeClass: "slds-size_12-of-12 ",
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    size: { isResponsive: false, default: "12" },
                    container: { class: "" },
                    border: {
                      type: [],
                      width: "",
                      color: "#cccccc",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {
                      styles: { label: { textDecoration: "", color: "" } }
                    },
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    style: "      \n         ",
                    customClass: "title_color"
                  },
                  label: "Default",
                  name: "Default",
                  conditionString: "",
                  draggable: false
                }
              ]
            },
            {
              name: "Block",
              element: "block",
              size: { isResponsive: false, default: "12" },
              stateIndex: 0,
              class: "slds-col ",
              property: {
                label: "Assets",
                collapsible: true,
                record: "{record}",
                collapsedByDefault: true,
                card: "{card}"
              },
              type: "block",
              styleObject: {
                padding: [
                  { type: "around", size: "x-small", label: "around:x-small" }
                ],
                class: "slds-p-around_x-small title_color",
                sizeClass: "slds-size_12-of-12 ",
                margin: [],
                background: {
                  color: "",
                  image: "",
                  size: "",
                  repeat: "",
                  position: ""
                },
                size: { isResponsive: false, default: "12" },
                container: { class: "" },
                border: {
                  type: "",
                  width: "",
                  color: "#cccccc",
                  radius: "",
                  style: ""
                },
                elementStyleProperties: {},
                text: { align: "", color: "" },
                inlineStyle: "",
                customClass: "title_color",
                style: "      \n         "
              },
              children: [
                {
                  key: "element_element_block_2_0_outputField_0_0",
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
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-Field-0"
                },
                {
                  key: "element_element_block_2_0_outputField_1_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3EThese%20are%20all%20the%20assets%20-%20including%20any%20properties,%20vehicles,%20investments%20or%20any%20other%20asset%20owned.%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-Text-1"
                },
                {
                  key: "element_element_block_2_0_outputField_2_0",
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
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-Field-2"
                },
                {
                  key: "element_element_block_2_0_outputField_3_0",
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
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-Field-3"
                },
                {
                  key: "element_element_block_2_0_outputField_4_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3EProperty%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-Text-4"
                },
                {
                  key: "element_element_block_2_0_childCardPreview_5_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Assets_Property",
                    recordId: "{recordId}",
                    cardNode: "{record.assets}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-FlexCard-5"
                },
                {
                  key: "element_element_block_2_0_outputField_6_0",
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
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-Field-6"
                },
                {
                  key: "element_element_block_2_0_outputField_7_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3ESuper%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-Text-7"
                },
                {
                  key: "element_element_block_2_0_childCardPreview_8_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Assets_Super",
                    recordId: "{recordId}",
                    cardNode: "{record.assets}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-FlexCard-8"
                },
                {
                  key: "element_element_block_2_0_outputField_9_0",
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
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-Field-9"
                },
                {
                  key: "element_element_block_2_0_outputField_10_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3EVehicles%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-Text-10"
                },
                {
                  key: "element_element_block_2_0_childCardPreview_11_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Vehicles",
                    recordId: "{recordId}",
                    cardNode: "{record.assets}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-FlexCard-11"
                },
                {
                  key: "element_element_block_2_0_outputField_12_0",
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
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-Field-12"
                },
                {
                  key: "element_element_block_2_0_outputField_13_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3EOther%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-Text-13"
                },
                {
                  key: "element_element_block_2_0_childCardPreview_14_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Assets_Other",
                    recordId: "{recordId}",
                    cardNode: "{record.assets}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-FlexCard-14"
                },
                {
                  key: "element_element_block_2_0_outputField_15_0",
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
                    label: ""
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-Field-15"
                },
                {
                  key: "element_element_block_2_0_outputField_16_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3EContents%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-Text-16"
                },
                {
                  key: "element_element_block_2_0_childCardPreview_17_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Assets_Content",
                    recordId: "{recordId}",
                    cardNode: "{record.assets}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-FlexCard-17"
                },
                {
                  key: "element_element_block_2_0_outputField_18_0",
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
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-Field-18"
                },
                {
                  key: "element_element_block_2_0_outputField_19_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3EInvestments%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-Text-19"
                },
                {
                  key: "element_element_block_2_0_childCardPreview_20_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Asset_Shares",
                    recordId: "{recordId}",
                    cardNode: "{record.assets}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-FlexCard-20"
                },
                {
                  key: "element_element_block_2_0_childCardPreview_21_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Message_Flex",
                    recordId: "{recordId}",
                    cardNode: "{record.assets}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_2_0",
                  elementLabel: "Your Assets-FlexCard-21"
                }
              ],
              elementLabel: "Your Assets",
              userUpdatedElementLabel: true,
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
                    class: "slds-p-around_x-small title_color",
                    sizeClass: "slds-size_12-of-12 ",
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    size: { isResponsive: false, default: "12" },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "#cccccc",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    customClass: "title_color",
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
              name: "Block",
              element: "block",
              size: { isResponsive: false, default: "12" },
              stateIndex: 0,
              class: "slds-col ",
              property: {
                label: "Debts",
                collapsible: true,
                record: "{record}",
                collapsedByDefault: true,
                card: "{card}"
              },
              type: "block",
              styleObject: {
                padding: [
                  { type: "around", size: "x-small", label: "around:x-small" }
                ],
                class: "slds-p-around_x-small title_color",
                sizeClass: "slds-size_12-of-12 ",
                margin: [],
                background: {
                  color: "",
                  image: "",
                  size: "",
                  repeat: "",
                  position: ""
                },
                size: { isResponsive: false, default: "12" },
                container: { class: "" },
                border: {
                  type: "",
                  width: "",
                  color: "#cccccc",
                  radius: "",
                  style: ""
                },
                elementStyleProperties: {},
                text: { align: "", color: "" },
                inlineStyle: "",
                customClass: "title_color",
                style: "      \n         "
              },
              children: [
                {
                  key: "element_element_block_3_0_outputField_0_0",
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
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-Text-0"
                },
                {
                  key: "element_element_block_3_0_outputField_1_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3EThese%20are%20the%20debts%20including%20any%20loans,%20credit%20cards,%20buy%20now%20pay%20later%20or%20other%20lines%20of%20credit%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-Text-1"
                },
                {
                  key: "element_element_block_3_0_outputField_2_0",
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
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-Text-2"
                },
                {
                  key: "element_element_block_3_0_outputField_3_0",
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
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-Text-3"
                },
                {
                  key: "element_element_block_3_0_outputField_4_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3EHome%20Loans%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-Text-4"
                },
                {
                  key: "element_element_block_3_0_childCardPreview_5_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Home_Loan",
                    recordId: "{recordId}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false,
                    cardNode: "{record.liabilities}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-FlexCard-5"
                },
                {
                  key: "element_element_block_3_0_outputField_6_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3EVehicle%20Loans%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-Text-6"
                },
                {
                  key: "element_element_block_3_0_childCardPreview_7_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Vehicle_Loan",
                    recordId: "{recordId}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false,
                    cardNode: "{record.liabilities}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-FlexCard-7"
                },
                {
                  key: "element_element_block_3_0_outputField_8_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3EStudent%20Loans%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-Text-8"
                },
                {
                  key: "element_element_block_3_0_childCardPreview_9_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Student_Loan",
                    recordId: "{recordId}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false,
                    cardNode: "{record.liabilities}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-FlexCard-9"
                },
                {
                  key: "element_element_block_3_0_outputField_10_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3EPersonal%20Loans%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-Text-10"
                },
                {
                  key: "element_element_block_3_0_childCardPreview_11_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Personal_Loan",
                    recordId: "{recordId}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false,
                    cardNode: "{record.liabilities}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-FlexCard-11"
                },
                {
                  key: "element_element_block_3_0_outputField_12_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3ECredit%20Cards%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-Text-12"
                },
                {
                  key: "element_element_block_3_0_childCardPreview_13_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Credit_Card",
                    recordId: "{recordId}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false,
                    cardNode: "{record.liabilities}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-FlexCard-13"
                },
                {
                  key: "element_element_block_3_0_outputField_14_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3EOther%20Limit%20Liability%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-Text-14"
                },
                {
                  key: "element_element_block_3_0_childCardPreview_15_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Other_Limit_Liability",
                    recordId: "{recordId}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false,
                    cardNode: "{record.liabilities}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-FlexCard-15"
                },
                {
                  key: "element_element_block_3_0_outputField_16_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3EOther%20Loans%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-Text-16"
                },
                {
                  key: "element_element_block_3_0_childCardPreview_17_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Other_Loan",
                    recordId: "{recordId}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false,
                    cardNode: "{record.liabilities}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-FlexCard-17"
                },
                {
                  key: "element_element_block_3_0_outputField_18_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3ELease/Hire%20Purchase%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-Text-18"
                },
                {
                  key: "element_element_block_3_0_childCardPreview_19_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Lease_Hire_Purchase",
                    recordId: "{recordId}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false,
                    cardNode: "{record.liabilities}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-FlexCard-19"
                },
                {
                  key: "element_element_block_3_0_outputField_20_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3EOverdraft%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-Text-20"
                },
                {
                  key: "element_element_block_3_0_childCardPreview_21_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Overdraft",
                    recordId: "{recordId}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false,
                    cardNode: "{record.liabilities}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-FlexCard-21"
                },
                {
                  key: "element_element_block_3_0_outputField_22_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3EMargin%20Loans%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-Text-22"
                },
                {
                  key: "element_element_block_3_0_childCardPreview_23_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Margin_Loan",
                    recordId: "{recordId}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false,
                    cardNode: "{record.liabilities}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-FlexCard-23"
                },
                {
                  key: "element_element_block_3_0_outputField_24_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3ELine%20of%20Credit%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-Text-24"
                },
                {
                  key: "element_element_block_3_0_childCardPreview_25_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Line_of_Credit",
                    recordId: "{recordId}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false,
                    cardNode: "{record.liabilities}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-FlexCard-25"
                },
                {
                  key: "element_element_block_3_0_outputField_26_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3EBuy%20Now%20Pay%20Later%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-Text-26"
                },
                {
                  key: "element_element_block_3_0_childCardPreview_27_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Buy_Now_Pay_Later",
                    recordId: "{recordId}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false,
                    cardNode: "{record.liabilities}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_3_0",
                  elementLabel: "Debts-FlexCard-27"
                }
              ],
              elementLabel: "Debts",
              userUpdatedElementLabel: true,
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
                    class: "slds-p-around_x-small title_color",
                    sizeClass: "slds-size_12-of-12 ",
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    size: { isResponsive: false, default: "12" },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "#cccccc",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    customClass: "title_color",
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
              name: "Block",
              element: "block",
              size: { isResponsive: false, default: "12" },
              stateIndex: 0,
              class: "slds-col ",
              property: {
                label: "Income",
                collapsible: true,
                record: "{record}",
                collapsedByDefault: true,
                card: "{card}"
              },
              type: "block",
              styleObject: {
                padding: [
                  { type: "around", size: "x-small", label: "around:x-small" }
                ],
                class: "slds-p-around_x-small title_color",
                sizeClass: "slds-size_12-of-12 ",
                margin: [],
                background: {
                  color: "",
                  image: "",
                  size: "",
                  repeat: "",
                  position: ""
                },
                size: { isResponsive: false, default: "12" },
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
                customClass: "title_color",
                style: "      \n         "
              },
              children: [],
              elementLabel: "Income",
              userUpdatedElementLabel: true,
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
                    class: "slds-p-around_x-small title_color",
                    sizeClass: "slds-size_12-of-12 ",
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    size: { isResponsive: false, default: "12" },
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
                    customClass: "title_color",
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
              name: "Block",
              element: "block",
              size: { isResponsive: false, default: "12" },
              stateIndex: 0,
              class: "slds-col ",
              property: {
                label: "Spending",
                collapsible: true,
                record: "{record}",
                collapsedByDefault: true,
                card: "{card}"
              },
              type: "block",
              styleObject: {
                padding: [
                  { type: "around", size: "x-small", label: "around:x-small" }
                ],
                class: "slds-p-around_x-small title_color",
                sizeClass: "slds-size_12-of-12 ",
                margin: [],
                background: {
                  color: "",
                  image: "",
                  size: "",
                  repeat: "",
                  position: ""
                },
                size: { isResponsive: false, default: "12" },
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
                customClass: "title_color",
                style: "      \n         "
              },
              children: [],
              elementLabel: "Spending",
              userUpdatedElementLabel: true,
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
                    class: "slds-p-around_x-small title_color",
                    sizeClass: "slds-size_12-of-12 ",
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    size: { isResponsive: false, default: "12" },
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
                    customClass: "title_color",
                    style: "      \n         "
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
      childCards: [
        "SOP_ANZPlus",
        "SOP_ANZ3",
        "SOP_Other_Banks",
        "SOP_Other",
        "SOP_Message_Flex",
        "SOP_Assets_Property",
        "SOP_Assets_Super",
        "SOP_Vehicles",
        "SOP_Assets_Other",
        "SOP_Assets_Content",
        "SOP_Asset_Shares",
        "SOP_Message_Flex",
        "SOP_Home_Loan",
        "SOP_Vehicle_Loan",
        "SOP_Student_Loan",
        "SOP_Personal_Loan",
        "SOP_Credit_Card",
        "SOP_Other_Limit_Liability",
        "SOP_Other_Loan",
        "SOP_Lease_Hire_Purchase",
        "SOP_Overdraft",
        "SOP_Margin_Loan",
        "SOP_Line_of_Credit",
        "SOP_Buy_Now_Pay_Later"
      ],
      actions: [],
      omniscripts: [],
      documents: []
    }
  ],
  dataSource: {
    type: "ApexRemote",
    value: {
      dsDelay: "",
      resultVar: '["object"]',
      remoteClass: "ResidentialLoanApplicationController",
      remoteMethod: "getListAssets",
      vlocityAsync: false
    },
    orderBy: { name: "estimatedValue.value", isReverse: "true" },
    contextVariables: []
  },
  title: "SOP_Finances_Savings",
  enableLwc: true,
  isFlex: true,
  theme: "slds",
  selectableMode: "Multi",
  lwc: {
    DeveloperName: "cfSOP_Finances_Savings_1_ANZ",
    Id: "0Rb8r000000F1JxCAK",
    MasterLabel: "cfSOP_Finances_Savings_1_ANZ",
    NamespacePrefix: "c",
    ManageableState: "unmanaged"
  },
  isRepeatable: true,
  osSupport: true,
  globalCSS: true,
  Id: "0ko8s0000000CqnAAE",
  OmniUiCardKey: "SOP_Finances_Savings/ANZ/1.0",
  OmniUiCardType: "Parent"
};
export default definition;
