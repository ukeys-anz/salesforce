import EXPENSE_BLUE_CIRCLE from "@salesforce/resourceUrl/SOP_Expense_Blue_Circle";
import EXPENSE_RED_CIRCLE from "@salesforce/resourceUrl/SOP_Expense_Red_Circle";
import EXPENSE_GREY_CIRCLE from "@salesforce/resourceUrl/SOP_Expense_Grey_Circle";
import SOP_EXPENSE_ESSENTIAL from "@salesforce/resourceUrl/SOP_Expense_Essential";
import SOP_EXPENSE_GROCERIES from "@salesforce/resourceUrl/SOP_Expense_Groceries";
import SOP_EXPENSE_HOME from "@salesforce/resourceUrl/SOP_Expense_Home";
import SOP_EXPENSE_HEALTH from "@salesforce/resourceUrl/SOP_Expense_Health";
import SOP_EXPENSE_SUBSCRIPTION from "@salesforce/resourceUrl/SOP_Expense_Subscription";
import SOP_EXPENSE_TRANSPORT from "@salesforce/resourceUrl/SOP_Expense_Transport";
import SOP_EXPENSE_CLOTHING from "@salesforce/resourceUrl/SOP_Expense_Clothing";
import SOP_EXPENSE_EDUCATION from "@salesforce/resourceUrl/SOP_Expense_Education";
import SOP_EXPENSE_INSURANCE from "@salesforce/resourceUrl/SOP_Expense_Insurance";
import SOP_EXPENSE_SUPPORT from "@salesforce/resourceUrl/SOP_Expense_Support";
import SOP_EXPENSE_LIFESTYLE from "@salesforce/resourceUrl/SOP_Expense_Lifestyle";
import SOP_EXPENSE_OTHER from "@salesforce/resourceUrl/SOP_Expense_Other";

//create map for each categories description.
export const CATEGORIES_ICONS_SPENDINGS = {
  Essentials: SOP_EXPENSE_ESSENTIAL,
  Lifestyle: SOP_EXPENSE_LIFESTYLE,
  Other: SOP_EXPENSE_OTHER,
  Groceries: SOP_EXPENSE_GROCERIES,
  "Household Costs": SOP_EXPENSE_HOME,
  "Health & Wellbeing": SOP_EXPENSE_HEALTH,
  "Subscriptions, Phone & Internet": SOP_EXPENSE_SUBSCRIPTION,
  Transport: SOP_EXPENSE_TRANSPORT,
  "Clothing & Personal Care": SOP_EXPENSE_CLOTHING,
  Education: SOP_EXPENSE_EDUCATION,
  "Insurance Premiums": SOP_EXPENSE_INSURANCE,
  "Support & Care": SOP_EXPENSE_SUPPORT
};

//create map for each parent Icon.
export const CATEGORIES_ICONS_SPENDINGS_PARENT = {
  Essentials: EXPENSE_BLUE_CIRCLE,
  Lifestyle: EXPENSE_RED_CIRCLE,
  Other: EXPENSE_GREY_CIRCLE
};

//create map for each categories description.
export const CATEGORIES_DESCRIPTION_SPENDINGS = {
  Groceries:
    "Everything on the grocery list from cooking oil to bath oil, except alcohol.",
  "Household Costs":
    "Home insurance, bills, DIY supplies and other upkeep costs.",
  "Bills, Insurance & General": {
    version1:
      "Utilities, home insurance and anything spent on repairs or DIY projects.",
    version2: "Utilities, home insurance, body corporate fees and DIY projects."
  },
  "Land Tax": "Tax paid on the land you own.",
  "Owners Corp & Land Tax":
    "Body corporate and strata fees plus any tax paid on land owned.",
  Rent: "Rent paid on primary place of residence or boarding fees.",
  "Health & Wellbeing": "Whatever the spend is on physical and mental health.",
  "Subscriptions, Phone & Internet":
    "Digital subscriptions, streaming services, phone and internet plans.",
  Transport: "The monthly spending to get from A to B.",
  "Clothing & Personal Care":
    "Haircut, mani pedi, new pair of socks... this is what is spent on self care and clothing.",
  Education: "Any fees paid for school, night school or even flight school.",
  "Private Education":
    "From kinder to secondary school, this is what is spent on private supplies and activities.",
  "Public Education & Services":
    "Any fees paid for public education, as well as professional services like accounting and legal.",
  "Insurance Premiums":
    "Home insurance is already covered. Add any other insurance expense.",
  "Car, Travel & Belongings":
    "Insurance for car, any precious belongings and travel cover.",
  "Health, Life & Other":
    "Health cover and any personal insurance for when life happens.",
  "Support & Care":
    "Whether it's a baby or a fur baby, any support costs paid.",
  Childcare:
    "Everything from preschool fees to nannies and childcare services.",
  "Family Support":
    "This is what is required to be paid for child support and spousal or partner allowance.",
  "Pet Care":
    "Any spend to keep a fur baby looking and feeling their best, except pet insurance.",
  Other: "Overseas travel, pet insurance and any other regular expenses.",
  Lifestyle:
    "Domestic holidays, takeaway, retail therapy ... whatever is spent to treat yourself."
};

//create map for each parent description.
export const CATEGORIES_DESCRIPTION_SPENDINGS_PARENT = {
  Essentials:
    "This is the average monthly spendings for all essential expenses. It will be used to estimate the regular expenses.",
  Lifestyle:
    "This is the average monthly spending for all lifestyle expenses. It will be used to estimate the regular expenses.",
  Other:
    "This is the average monthly spending for all other expenses. It will be used to estimate the regular expenses."
};

export const EXPENSES_WITH_PROMPTS = [
  "Lifestyle",
  "Groceries",
  "Bills, Insurance & General",
  "Health & Wellbeing",
  "Subscriptions, Phone & Internet",
  "Transport"
];
