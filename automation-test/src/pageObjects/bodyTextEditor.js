"use strict";

var core = require("@utam/core");

class BodyTextEditor extends core.UtamBaseRootPageObject {
  constructor(driver, element, locator = core.By.css(`body`)) {
    super(driver, element, locator);
  }

  async getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = core.createUtamMixinCtor(
      core.EditableUtamElement
    );
    return new EditableUtamElement(driver, root);
  }

  async editBody(content) {
    const _statement0 = await this.getRoot();
    await _statement0.setText(content);
  }
}

module.exports = BodyTextEditor;
