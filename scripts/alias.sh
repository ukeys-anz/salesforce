#!/bin/bash
#usage source ./scripts/alias.sh 
# you can also add the alias to the .bash_profile so its is executed for login shells
# or add it to .bashrc for non-login shells.

alias dxdelete="sfdx force:org:delete -p -u"
alias dxdisplay="sfdx force:org:display"
alias dxol="sfdx force:org:list"
alias dxopen="sfdx force:org:open -u"
alias dxsc="sfdx force:source:convert"
alias dxso="sfdx force:source:open"
alias dxpull="sfdx force:source:pull"
alias dxpush="sfdx force:source:push"
alias dxforcepush="sfdx force:source:push -f"
alias dxss="sfdx force:source:status"
alias dxlimit="sfdx force:limits:api:display"
#alias dxtest="sfdx force:apex:test:run -c -w 60 -r human"
alias dxquery="sfdx force:data:soql:query --query -r "
alias dxretrieve="sfdx force:source:retrieve -m"
alias dxdeploy="sfdx force:source:deploy -p"
alias dxdevhub="sfdx force:auth:web:login -d -a"
alias dxpwd="sfdx force:user:password:generate"
alias dxlwc="sfdx force:lightning:lwc:start"
