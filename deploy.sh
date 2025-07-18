#!/bin/bash

# This script prepares the prod branch for deployment.

# update the renv snapshot
Rscript -e "renv::snapshot()"
git add -A && git commit -m "update renv before deployment"
git checkout prod
git merge main --no-ff -m "Merge main into prod for deployment"
# Remove renv files from prod (required for Posit Connect Cloud)
rm -rf renv .Rprofile renv.lock deploy.sh
git add -A && git commit -m "Remove renv files for production deployment"
# Create the manifest file (required for Posit Connect Cloud)
Rscript -e "rsconnect::writeManifest()"
echo "manifest.json updated"
echo "'prod' branch is now ready for deployment"
echo "Push 'prod' to deploy"
