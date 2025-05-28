({
  doInit: function (cmp) {
    cmp.find("navService").navigate(
      {
        type: "standard__recordPage",
        attributes: {
          recordId: cmp.get("v.recordId"),
          actionName: "view"
        }
      },
      true
    );
  }
});
