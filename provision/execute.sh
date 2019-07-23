#! /bin/bash

echo "Execute plan to find out if there are changes"
terraform plan -detailedexit
tfstatus=$?

case $tfstatus in
  0)
    echo "Nothing to do, infrastructure is up-to-date."
    ;;
  1)
    echo "Exiting with error."
    exit 1
    ;;
  2)
    echo "Changes found, applying changes."
    terraform apply
    ;;
  *)
    echo "Unknown status, exiting."
    exit 1
    ;;
esac

exit 0