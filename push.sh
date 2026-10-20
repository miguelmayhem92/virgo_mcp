docker builder prune -f
echo "Image build done"

BUILDX_NO_DEFAULT_ATTESTATIONS=1 docker compose build

# connect to ecr
aws ecr get-login-password --region eu-west-3 | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.eu-west-3.amazonaws.com

# build image
docker tag virgo_mcp:virgo_mcp.latest $ACCOUNT_ID.dkr.ecr.eu-west-3.amazonaws.com/virgo-mcp:virgo_mcp.latest

# export
docker push $ACCOUNT_ID.dkr.ecr.eu-west-3.amazonaws.com/virgo-mcp:virgo_mcp.latest


# cleaning space
docker rmi $ACCOUNT_ID.dkr.ecr.eu-west-3.amazonaws.com/virgo-mcp:virgo_mcp.latest
docker rmi virgo_mcp:virgo_mcp.latest


echo "push to registry done"