if [[ $# -lt 2 || "$1" != "--name" ]]; then
  echo "Usage: $0 --name <name_of_the_app>"
  exit 1
fi

appName="$2"

# This first part is for the project creation with vite.
# Create the app
yarn create vite "$appName" --template react
# Create enter to the new folder.
cd $appName
# Check if package.json exists
if [ ! -f "package.json" ]; then
  echo "package.json does not exist. Exiting..."
  exit 1
fi
# Install dependencies
yarn install


# Once the project is up. Set jest configurations and boilerpate.
# Check if src directory exists
if [ ! -d "src" ]; then
  echo "src directory does not exist. Exiting..."
  exit 1
fi
# Create codeToTest directory within src
mkdir -p "src/codeToTest"
# Create a dummy code for testing.
cat << EOF > src/codeToTest/dummyCode.js
export const add = (a, b) => a + b;
EOF

# Create test directory where the jest test resides.
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

# Install jest as development dependency
yarn add --dev jest

# Configure script command to make a jest --watchAll
jq '.scripts.test = "jest --watchAll"' package.json > tmp.json && mv -f tmp.json package.json

# Type definitions. Yhe @types/jest module provide full typing when writing tests.
yarn add -D @types/jest

# Babel configurations.
yarn add --dev babel-jest @babel/core @babel/preset-env

cat << EOF > babel.config.cjs
module.exports = {
  presets: [['@babel/preset-env', {targets: {node: 'current'}}]],
};
EOF

cwd=$(pwd)
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