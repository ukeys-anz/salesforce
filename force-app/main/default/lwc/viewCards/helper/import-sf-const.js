import card_images from "@salesforce/resourceUrl/card_images";
import hasLockCardsPermission from "@salesforce/customPermission/ANZx_Temp_Lock_Card";
import hasFraudLockCardsPermission from "@salesforce/customPermission/ANZx_Fraud_Lock_Card";
import hasReplaceCardsPermission from "@salesforce/customPermission/ANZx_Replace_Card";
import hasViewCardsPermission from "@salesforce/customPermission/ANZx_View_Cards";

export const CARD_IMAGES = {
    default: `${card_images}/card_active.png`,
    active: `${card_images}/card_active.png`,
    locked: `${card_images}/card_locked.png`,
    disabled: `${card_images}/card_disabled.png`
};

export const USER_PERMISSION = {
    hasLockPermission: hasLockCardsPermission,
    hasFraudPermission: hasFraudLockCardsPermission,
    hasReplacePermission: hasReplaceCardsPermission,
    hasViewPermission: hasViewCardsPermission
};
