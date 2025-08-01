#!/bin/bash

set -e

# This script prepares the prod branch for deployment.

# 1. Update renv.lock on main branch
echo "Updating renv.lock on main branch..."
Rscript -e "renv::restore()"
Rscript -e "renv::snapshot()"
if ! git diff-index --quiet HEAD -- renv.lock; then
    git add renv.lock
    git commit -m "Update renv.lock before deployment"
fi

# 2. Force update prod branch from main
echo "Updating prod branch from main..."
git checkout prod
git reset --hard main

# 3. Remove development files from prod branch
echo "Removing development files from prod branch..."
git rm -r --ignore-unmatch renv .Rprofile deploy.sh
# The commit will only happen if git rm did something
if ! git diff-index --quiet HEAD; then
    git commit -m "Remove dev files for deployment"
fi

# 4. Generate manifest.json for Posit Connect
echo "Generating manifest.json..."
Rscript -e "if(!require('rsconnect')) install.packages('rsconnect', quiet = TRUE)"
Rscript -e "rsconnect::writeManifest()"
git add manifest.json
git commit -m "Generate manifest.json"

# 5. Force push to prod
echo "Pushing to prod branch..."
git push origin prod --force

# 6. Return to main branch and restore dev environment
echo "Returning to main branch..."
git checkout main
Rscript -e "renv::restore()"
# restore dev R language server
Rscript -e "install.packages('languageserver')"

echo "Deployment to prod branch complete."
echo "You are back on the main branch."
