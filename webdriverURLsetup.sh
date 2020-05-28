#Need function to get url from sfdx response and store in variable
getUrl()
{
    sfdx force:org:open -r | egrep -o 'https.*' | tee stderr
}
url=$(getUrl)

#Use ~ instead of / as URL contains / and is flagged as bad flag
sed -i -e "s~BASE_URL=.*~BASE_URL='${url}'~" .env
