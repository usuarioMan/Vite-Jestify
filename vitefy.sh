#!/bin/bash

if [[ $# -lt 2 || "$1" != "--name" ]]; then
  echo "Usage: $0 --name <name_of_the_app>"
  exit 1
fi

appName="$2"

# Create the app
yarn create react-app "$appName" --template react

cd "$appName"

# Install dependencies
yarn install
yarn add --dev jest

# Create directory and files for testing
mkdir src/codeToTest
echo 'export function add(a, b) {\n  return a + b;\n}\n\nmodule.exports = { add };' > src/codeToTest/dummyCode.js

mkdir test
echo "import { add } from '../src/codeToTest/dummyCode.js'; describe('add', () => { test('should correctly add two positive numbers', () => { const result = add(3, 5); expect(result).toBe(8); });

test('should correctly add a negative and a positive number', () => { const result = add(-7, 3); expect(result).toBe(-4); }); test('should return the same number when adding zero', () => { const 
result$

# Update package.json scripts
jq '.scripts.test = "jest --watchAll"' package.json > tmp.json && mv -f tmp.json package.json

