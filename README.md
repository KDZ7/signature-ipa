Script de re signature ipa pour IOS

 exemple: 
 
 ./resign.sh -c "Apple Development: Name (XXXXXXXXXX)" -p XXXXXXXXX.mobileprovision -i youtube 
______________________________________________________________________________________________

En cas de présence de nouvelles couches à resigner

./resign.sh -c "Apple Development: Name (XXXXXXXXXX)" -p XXXXXXXXX.mobileprovision -i youtube -e "*.appex","*.dylib" 
____________________________________________________________________________________________________________________

-c: nom du certificat 
-p: profil d'approvisionnement 
-i: nom du fichier .ipa ! sans extension .ipa à la fin
-e: ajouter d'autres nouvelles couches à resigner (optionnel) 
