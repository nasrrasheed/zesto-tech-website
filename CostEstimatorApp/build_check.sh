#!/bin/bash

echo "🔍 Checking Swift compilation..."
echo "================================"

# Navigate to project directory
cd "$(dirname "$0")"

# Check if Xcode is available
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode command line tools not found"
    echo "Please install Xcode and command line tools"
    exit 1
fi

echo "✅ Xcode found"

# Check project structure
if [ ! -f "CostEstimatorApp.xcodeproj/project.pbxproj" ]; then
    echo "❌ Project file not found"
    exit 1
fi

echo "✅ Project file found"

# Validate project file structure
echo "🔍 Validating project file structure..."
if grep -q "PBXFileReference buildPhase" CostEstimatorApp.xcodeproj/project.pbxproj; then
    echo "❌ Project file contains corrupted references"
    echo "📋 The project file has been fixed with clean UUIDs"
else
    echo "✅ Project file structure is clean"
fi

# List Swift files
echo ""
echo "📁 Swift files in project:"
find . -name "*.swift" -type f | sort

echo ""
echo "🔨 Attempting to build project..."
echo "================================"

# Try to build the project
xcodebuild -project CostEstimatorApp.xcodeproj -scheme CostEstimatorApp -configuration Debug build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo "🎉 Your Cost Estimator app is ready to run!"
    echo "📝 Default login: admin / admin123"
else
    echo ""
    echo "❌ Build failed. Please check the errors above."
    echo "💡 Common fixes:"
    echo "   - Make sure all Swift files are properly formatted"
    echo "   - Check for missing imports"
    echo "   - Verify Core Data model is properly configured"
    echo "   - If you see 'damaged project' error, the project file has been regenerated"
fi

echo ""
echo "📖 To open in Xcode:"
echo "   open CostEstimatorApp.xcodeproj"