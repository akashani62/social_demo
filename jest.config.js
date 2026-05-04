/** @type {import("jest").Config} */
export default {
  testEnvironment: "jsdom",
  roots: ["<rootDir>/test/javascript"],
  testMatch: ["**/*.test.js"],
  setupFilesAfterEnv: ["<rootDir>/test/javascript/setup.js"],
  extensionsToTreatAsEsm: [".js"],
  transform: {},
  moduleNameMapper: {
    "^(\\.{1,2}/.*)\\.js$": "$1"
  }
}
