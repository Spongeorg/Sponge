import ProjectDescription
import ProjectDescriptionHelpers

let commonUI = Project.feature(
  name: "COCommonUI",
  products: [.framework(.dynamic)],
  dependencies: [
    .external(name: "SnapKit"),
    .external(name: "FlexLayout"),
    .external(name: "PinLayout"),
    .external(name: "Then")
  ]
)