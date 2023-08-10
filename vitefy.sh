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
// This function takes two numbers as arguments and returns their sum.
export const add = (a, b) => a + b;
EOF

# Create a test directory for Jest tests
mkdir test
cat << EOF > test/dummyCode.test.js
// Import the 'add' function from the specified module.
import { add } from '../src/codeToTest/dummyCode.js';

// Create a test suite using the describe function to group related tests.
describe('add', () => {
  // Create a test case using the test function to specify the expected behavior.
  test('should correctly add two positive numbers', () => {
    // Call the 'add' function with arguments 3 and 5, and assign the result to 'result'.
    const result = add(3, 5);
    
    // Use the 'expect' function to make assertions about the behavior of the code under test.
    // Check if the 'result' is equal to the expected value 8.
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
yarn add --dev @babel/preset-react

#  Configure jest environment for react dom
yarn add -D jest-environment-jsdom

# Create Babel configuration
cat << EOF > babel.config.cjs
module.exports = {
  presets: [
    [ '@babel/preset-env', { targets: { esmodules: true } } ],
    [ '@babel/preset-react', { runtime: 'automatic' } ],
  ],
};
EOF

# Create Jest configuration.
cat << EOF > jest.config.cjs
module.exports = {
  testEnvironment: 'jest-environment-jsdom',
  setupFiles: ['./jest.setup.js']
};
EOF

# Add whatwg-fetch
yarn add -D whatwg-fetch

# Create Jest Setup.
cat << EOF > jest.setup.js
import 'whatwg-fetch';
EOF

# Install react testing library
yarn add --dev @testing-library/react

cat << EOF > src/codeToTest/asyncDummyCode.js
// This function fetches comment data from a JSONPlaceholder API.
// It returns an array containing userId, id, title, and body of the comment.
export const fetchComment = async () => {
    try {
        // Use the fetch function to make an asynchronous request to the API.
        const response = await fetch('https://jsonplaceholder.typicode.com/posts/1');
        
        // Parse the JSON response body into an object.
        const { userId, id, title, body } = await response.json();

        // Return an array containing the extracted data.
        return [userId, id, title, body];

    } catch (error) {
        // If an error occurs during the fetch or JSON parsing, log the error and return an error message.
        console.log(error);
        return 'Error while fetching comment.';
    }
}
EOF

cat << EOF > test/asyncDummyCode.test.js
// Import the fetchComment function from the specified module.
import { fetchComment } from "../src/codeToTest/asyncDummyCode";

// Create a test suite using the describe function to group related tests.
describe('Testing fetchComment function', () => { 
    // Create a test case using the test function to specify the expected behavior.
    test('should fetch a comment and return its properties in a list', async() => {
        // Call the fetchComment function asynchronously and await its result.
        const commentProps = await fetchComment();
        
        // Use the expect function to make assertions about the behavior of the code under test.
        // Check if the returned value (commentProps) is an array.
        expect(Array.isArray(commentProps)).toBe(true);
    });
});
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

