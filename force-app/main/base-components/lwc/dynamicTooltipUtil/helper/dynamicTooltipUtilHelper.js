////Moved the hardcoded tooltip data from js to the static resource
import TOOLTIP_JSON from "@salesforce/resourceUrl/financialAccountTooltips";
import { loadScript } from "lightning/platformResourceLoader";
let TOOLTIP_MAP = {};

export async function loadTooltipMap() {
  if (Object.keys(TOOLTIP_MAP).length > 0) {
    return;
  }
  await loadScript(this, TOOLTIP_JSON)
  TOOLTIP_MAP = window.tooltipData;
}

//this method is use to fetch the tooltip content dynamically based on the resourcename
export function fetchTooltipContent(resourceName, productName) {
  return resourceName
    ? populateProductName(TOOLTIP_MAP[resourceName], productName)
    : "";
}

function populateProductName(toolTipContent, productName) {
  return toolTipContent
    ? toolTipContent.replace("{productName}", productName)
    : "";
}
