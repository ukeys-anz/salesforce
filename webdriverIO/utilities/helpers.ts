class helpers {
  doClick(element: WebdriverIO.Element) {
    element.waitForDisplayed({ timeout: 3000 });
    element.waitForClickable({ timeout: 3000 });
    element.click();
  }

  doJSClick(element: WebdriverIO.Element) {
    element.waitForDisplayed({ timeout: 3000 });
    browser.execute("arguments[0].click();", element);
  }

  enterText(element: WebdriverIO.Element, value: any) {
    element.waitForDisplayed({ timeout: 10000 });
    element.clearValue();
    element.setValue(value);
  }

  enterJSText(element: WebdriverIO.Element, textval: any) {
    element.waitForDisplayed({ timeout: 3000 });
    element.clearValue();
    browser.execute("arguments[0].value=textval;", element);
  }

  waitAndRetry(
    elementToClick: WebdriverIO.Element,
    elementToValidate: WebdriverIO.Element,
    value: any
  ) {
    browser.waitUntil(
      function () {
        elementToClick.click();
        return elementToValidate.getText() == value;
      },
      { timeout: 120000, interval: 2000 }
    );
  }
}

export default new helpers();
