#!/bin/bash

# Check if the number of arguments ($#) is less than 2 or if the first argument is not "--name"
if [[ $# -lt 2 || "$1" != "--name" ]]; then
  echo "Usage: $0 --name <name_of_the_app>"
  exit 1
fi

# Store the second argument as the appName
appName="$2"

# This first part is for creating a project using Vite.

# Create the app using yarn create vite with the react template
yarn create vite "$appName" --template react
# Enter the newly created folder
cd $appName

# Check if package.json exists
if [ ! -f "package.json" ]; then
  echo "package.json does not exist. Exiting..."
  exit 1
fi

# Install project dependencies
yarn install


# Once the project is set up, configure Jest and create boilerplate.

# Check if src directory exists
if [ ! -d "src" ]; then
  echo "src directory does not exist. Exiting..."
  exit 1
fi

# Create a directory for the code to be tested
mkdir -p "src/codeToTest"

# Create a dummy code file for testing
cat << EOF > src/codeToTest/dummyCode.js
export const add = (a, b) => a + b;
EOF

# Create a test directory for Jest tests
mkdir test
cat << EOF > test/dummyCode.test.js
import { add } from '../src/codeToTest/dummyCode.js';

describe('add', () => {
  test('should correctly add two positive numbers', () => {
    const result = add(3, 5);
    expect(result).toBe(8);
  });
});
EOF

# Install Jest as a development dependency
yarn add --dev jest

# Configure the script command to run Jest in watch mode
jq '.scripts.test = "jest --watchAll"' package.json > tmp.json && mv -f tmp.json package.json

# Install type definitions for Jest to provide full typing when writing tests
yarn add -D @types/jest

# Configure Babel for Jest
yarn add --dev babel-jest @babel/core @babel/preset-env

# Create Babel configuration
cat << EOF > babel.config.cjs
module.exports = {
  presets: [['@babel/preset-env', {targets: {node: 'current'}}]],
};
EOF

# Get the current working directory
cwd=$(pwd)

# Use AppleScript to open two Terminal windows
osascript <<EOD
tell application "Terminal"
    activate
    do script "cd '$cwd' && yarn dev"
    delay 1
    tell application "System Events" to keystroke "t" using {command down}
    delay 0.5
    do script "cd '$cwd' && yarn test; bash" in selected tab of the front window
end tell
EOD
