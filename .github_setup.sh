#!/bin/bash

# GitHub Setup Script for AutoGo
# This script helps you push the project to a new GitHub repository

echo "=========================================="
echo "  AUTO GO - GitHub Setup"
echo "=========================================="
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "📦 Initializing git repository..."
    git init
fi

# Check current git status
echo "📋 Checking git status..."
git status --short | head -10
echo ""

# Ask for repository details
read -p "Enter your GitHub username: " GITHUB_USERNAME
read -p "Enter repository name (default: AutoGoFlutterApp): " REPO_NAME
REPO_NAME=${REPO_NAME:-AutoGoFlutterApp}

echo ""
echo "=========================================="
echo "  Next Steps:"
echo "=========================================="
echo ""
echo "1. Create a new repository on GitHub:"
echo "   - Go to: https://github.com/new"
echo "   - Repository name: $REPO_NAME"
echo "   - Description: Car Rental Marketplace App"
echo "   - Visibility: Private or Public (your choice)"
echo "   - DO NOT initialize with README, .gitignore, or license"
echo "   - Click 'Create repository'"
echo ""
echo "2. After creating the repository, run these commands:"
echo ""
echo "   git add ."
echo "   git commit -m 'Initial commit: AutoGo Car Rental App'"
echo "   git branch -M main"
echo "   git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
echo "   git push -u origin main"
echo ""
echo "=========================================="
echo ""
read -p "Have you created the repository on GitHub? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🚀 Setting up git and pushing to GitHub..."
    echo ""
    
    # Add all files
    echo "📦 Adding files to git..."
    git add .
    
    # Check if there are changes to commit
    if git diff --staged --quiet; then
        echo "⚠️  No changes to commit. Repository might already be up to date."
    else
        # Commit
        echo "💾 Committing changes..."
        git commit -m "Initial commit: AutoGo Car Rental App"
    fi
    
    # Set main branch
    echo "🌿 Setting main branch..."
    git branch -M main 2>/dev/null || true
    
    # Add remote
    echo "🔗 Adding remote repository..."
    git remote remove origin 2>/dev/null || true
    git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    
    echo ""
    echo "✅ Ready to push!"
    echo ""
    echo "📤 Pushing to GitHub..."
    git push -u origin main
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Successfully pushed to GitHub!"
        echo "🔗 Repository: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
    else
        echo ""
        echo "❌ Push failed. Please check:"
        echo "   1. Repository exists on GitHub"
        echo "   2. You have access permissions"
        echo "   3. GitHub credentials are configured"
        echo ""
        echo "You can manually push with:"
        echo "   git push -u origin main"
    fi
else
    echo ""
    echo "📝 Please create the repository on GitHub first, then run this script again."
    echo "   Or run the commands manually as shown above."
fi

echo ""
echo "=========================================="






