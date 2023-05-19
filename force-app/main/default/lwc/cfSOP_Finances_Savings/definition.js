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
        padding: [{ type: "around", size: "x-small" }],
        margin: [{ type: "bottom", size: "x-small" }],
        container: { class: "slds-card" },
        size: { isResponsive: false, default: "12" },
        sizeClass: "slds-size_12-of-12",
        class: "slds-card slds-p-around_x-small slds-m-bottom_x-small"
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
                  size: { isResponsive: false, default: "9" },
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
                    sizeClass: "slds-size_9-of-12 ",
                    size: { isResponsive: false, default: "9" }
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-0-Text-0"
                },
                {
                  key: "element_element_block_0_0_action_1_0",
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
                    displayAsButton: true
                  },
                  type: "element",
                  styleObject: {
                    sizeClass: "slds-size_2-of-12 ",
                    size: { isResponsive: false, default: "2" }
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-0-Action-1"
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
                  key: "element_element_block_1_0_outputField_0_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3EThis%20includes%20any%20cash%20and%20money%20in%20your%20account%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Text-0"
                },
                {
                  key: "element_element_block_1_0_outputField_1_0",
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
                  elementLabel: "Your Savings-Field-1"
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
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cspan%20style=%22color:%20#236fa1;%22%3E%3Cstrong%3EANZ%20Plus%3C/strong%3E%3C/span%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Text-3"
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
                    cardNode: ""
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  elementLabel: "FlexCard-1",
                  key: "element_element_block_1_0_childCardPreview_4_0",
                  parentElementKey: "element_block_1_0",
                  userUpdatedElementLabel: true
                },
                {
                  key: "element_element_block_1_0_outputField_5_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cspan%20style=%22color:%20#236fa1;%22%3E%3Cstrong%3EANZ%3C/strong%3E%3C/span%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Text-5"
                },
                {
                  key: "element_element_block_1_0_childCardPreview_6_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_ANZ3",
                    recordId: "{recordId}",
                    cardNode: "",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-FlexCard-6"
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
                      "%3Cdiv%3E%3Cstrong%3EOther%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Text-7"
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
                    cardNode: "",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  elementLabel: "Your Savings-FlexCard-8",
                  key: "element_element_block_1_0_childCardPreview_8_0",
                  parentElementKey: "element_block_1_0"
                },
                {
                  key: "element_element_block_1_0_childCardPreview_9_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Message_Flex",
                    recordId: "{recordId}",
                    cardNode: "",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-FlexCard-9"
                }
              ],
              elementLabel: "Your Savings",
              userUpdatedElementLabel: true
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
                padding: [{ type: "around", size: "x-small" }],
                class: "slds-p-around_x-small",
                sizeClass: "slds-size_12-of-12"
              },
              children: [],
              elementLabel: "Your Assets",
              userUpdatedElementLabel: true
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
                padding: [{ type: "around", size: "x-small" }],
                class: "slds-p-around_x-small",
                sizeClass: "slds-size_12-of-12"
              },
              children: [],
              elementLabel: "Debts",
              userUpdatedElementLabel: true
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
                padding: [{ type: "around", size: "x-small" }],
                class: "slds-p-around_x-small",
                sizeClass: "slds-size_12-of-12"
              },
              children: [],
              elementLabel: "Income",
              userUpdatedElementLabel: true
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
                padding: [{ type: "around", size: "x-small" }],
                class: "slds-p-around_x-small",
                sizeClass: "slds-size_12-of-12"
              },
              children: [],
              elementLabel: "Spending",
              userUpdatedElementLabel: true
            }
          ]
        }
      },
      childCards: ["SOP_ANZPlus", "SOP_ANZ3", "SOP_Other", "SOP_Message_Flex"],
      actions: [],
      omniscripts: [],
      documents: []
    }
  ],
  dataSource: {
    type: "ApexRemote",
    value: {
      dsDelay: "",
      resultVar: '["object"]["assets"]',
      remoteClass: "ResidentialLoanApplicationController",
      remoteMethod: "getListAssets",
      vlocityAsync: false,
      optionsMap: { "": "", vlcClass: "ResidentialLoanApplicationController" }
    },
    orderBy: { name: "", isReverse: "" },
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
  isRepeatable: false,
  osSupport: true,
  Name: "SOP_Finances_Savings",
  uniqueKey: "SOP_Finances_Savings",
  Id: "0ko8r0000000I6bAAE",
  OmniUiCardKey: "SOP_Finances_Savings/ANZ/1.0",
  OmniUiCardType: "Parent"
};
export default definition;
