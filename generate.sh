rm -rf sources && mkdir sources && cd sources

page=1
while true; do
  echo "Page $page..."
  repos=$(curl --retry 10 -s "https://api.github.com/users/vimaster/repos?page=$page&per_page=100")

  if [ $(echo $repos | jq '. | length') -eq 0 ]; then
    break
  fi

  repoURLs=$(echo $repos | jq -r '.[] | select(.name | startswith("p300-") | not) | select(.name | startswith("p400-") | not) | .clone_url')  
  for repo in $repoURLs; do
    echo "Cloning $repo..."
    git clone $repo
  done
  page=$((page+1))
done

dotnet tool install ScorecardGenerator --global
rm -rf ../dist && mkdir ../dist
ScorecardGenerator --azure-pat $AZURE_PAT --output-path ../dist