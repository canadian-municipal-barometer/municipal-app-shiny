#!/bin/bash

# This script prepares the prod branch for deployment.

# update the renv snapshot
Rscript -e "renv::snapshot()"

# Switch to the 'prod' branch
git checkout prod

# Merge changes from 'main'
git merge main --no-ff -m "Merge main into prod for deployment"

# Remove renv files
rm -rf renv .Rprofile renv.lock deploy.sh

# Commit the changes
git add -A && git commit -m "Remove renv files for production deployment"

# Create the manifest file
Rscript -e "rsconnect::writeManifest()"

echo "manifest.json updated"
echo "'prod' branch is now ready for deployment"
echo "Push 'prod' to deploy"
