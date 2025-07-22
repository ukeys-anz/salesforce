////Moved the hardcoded tooltip data from js to the static resource
import TOOLTIP_JSON from "@salesforce/resourceUrl/tooltipData";

let TOOLTIP_MAP = {};

export async function loadTooltipMap() {
  if (Object.keys(TOOLTIP_MAP).length > 0) {
    return;
  }

  const response = await fetch(TOOLTIP_JSON);
  const data = await response.json();
  TOOLTIP_MAP = data;
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
