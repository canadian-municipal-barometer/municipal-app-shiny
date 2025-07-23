#!/bin/bash

# This script prepares the prod branch for deployment.

# update the renv snapshot
Rscript -e "renv::snapshot()"
git add -A && git commit -m "update renv before deployment"
git checkout prod
git merge main --no-ff -m "Merge main into prod for deployment"
# Remove renv files from prod (required for Posit Connect Cloud)
rm -rf renv .Rprofile renv.lock deploy.sh
git rm renv .Rprofile renv.lock deploy.sh
git add -A && git commit -m "Remove renv files for production deployment"
# Create the manifest file (required for Posit Connect Cloud)
Rscript -e "install.packages('rsconnect')"
Rscript -e "rsconnect::writeManifest()"
git add -A && git commit -m "manifest.json updated and committed"
echo "manifest.json updated"
git push
echo "'prod' branch pushed"
git checkout main
Rscript -e "renv::restore()"
echo "Deployment successful"
echo "'main' dev state preserved"
echo "You are on branch 'main'"

