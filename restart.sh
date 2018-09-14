docker stop smokeping
docker run --name smokeping -h smokeping_google -d --rm -p 80:80 -v /data/smokeping/data:/opt/smokeping/data -v /data/smokeping/ssmtp:/etc/ssmtp -v /data/smokeping/etc:/opt/smokeping/etc morphyhu/smokeping:v2.7.2
docker logs -f smokeping
