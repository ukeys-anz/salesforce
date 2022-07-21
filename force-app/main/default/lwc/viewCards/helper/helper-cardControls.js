import { CARD_CONTROLS_DEFINITION } from "./model";

// This function will map the controls applied on the card and
// set flag showing whether temp lock (GCT Global) is applied
export function mapCardControls(card) {
  let controls = CARD_CONTROLS_DEFINITION.map((definition) => ({
    ...definition
  }));

  if (card.cardControlsList) {
    //compare definition with customer controls
    controls.forEach((control) => {
      card.cardControlsList.forEach((customer_control) => {
        if (control.key === customer_control.control_type) {
          // this is checking whether control is MCT Gambling for status
          if (!control.type) {
            control.value = "Disabled";
            if (control.key === "MCT_GAMBLING") {
              control.value = "On";
            }
          } else {
            switch (control.key) {
              case "MCT_GAMBLING":
                if (customer_control.impulse_delay_period)
                  assignGamblingBlockValues(control, customer_control);
              default:
                break;
            }
          }
        }
      });
    });
  }
  card.controls = controls;
  return card;
}

//assigns values when gambling block is on and calculates countdown timer
function assignGamblingBlockValues(control, customer_control) {
  const IMPULSE_PERIOD = parseInt(
    customer_control.impulse_delay_period.replace("s", "")
  );

  let impulseStart = new Date(customer_control.impulse_delay_start);
  let impulseEnd = impulseStart.setSeconds(IMPULSE_PERIOD);
  let impulsePassed = new Date(impulseEnd) - new Date();

  if (new Date() >= impulseEnd) {
    control.value = "Gambling block can now be turned off";
  } else {
    let hours = Math.floor(impulsePassed / 1000 / 3600);
    let minutes = Math.floor((impulsePassed / 1000 / 60) % 60);
    control.value = `${hours}hr ${minutes}min remaining to enable transactions`;
  }
}

// Sets cardIsTempLocked on card if GCT_Global control type (Temp Lock) is applied
export function mapTempLockOnACard(card) {
  let cardIsTempLocked = false;

  if (card.cardControlsList != null) {
    card.cardControlsList.forEach((control) => {
      if (cardIsTempLocked) return;

      if (control.control_type == "GCT_GLOBAL") {
        cardIsTempLocked = true;
      }
    });
  }
  card.cardIsTempLocked = cardIsTempLocked;
  return card;
}
