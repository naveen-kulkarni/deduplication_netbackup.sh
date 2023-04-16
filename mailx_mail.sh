
 IFS=$'\n';
 file="$PWD/bb"
vars=$(cat "$file")
( echo "to: naveenvk88@gmail.com"
  echo "subject: Message from the server"
  echo "mime-version: 1.0"
  echo "content-type: multipart/related; boundary=messageBoundary"
  echo
  echo "--messageBoundary"
  echo "content-type: text/plain"
  echo
  echo "$(cat /home/naveen/AutoNaveen/backupScritp/bb)"
  echo
  echo "--messageBoundary"
  echo "content-type: text; name=test.txt"
  echo "content-transfer-encoding: base64"
  echo
  openssl base64 < $PWD/info.txt
  echo "--messageBoundary"
  echo "content-type: text; name=fry.txt"
  echo "content-transfer-encoding: base64"
  echo
  openssl base64 < $PWD/bb	) | sendmail -t -i
