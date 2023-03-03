#!/bin/bash

# .ipa

IPA_NAME=$1

# Account

CERTIFICATE_NAME="Apple Development: Name (XXXXXXXXXX)"
PROVISION_PROFIL=XXXXXXXXX.mobileprovision

# .plist

PROVISION_PLIST=provision.plist
ENTITLEMENTS_PLIST=entitlements.plist



# ================================================================================================================================


while getopts "hc:p:i:e:" opt
do
    case $opt in
        h)
            echo " exemple: "
            echo ' ./resign.sh -c "Apple Development: Name (XXXXXXXXXX)" -p XXXXXXXXX.mobileprovision -i youtube '
            echo " exemple en cas de présence de nouvelles couches à resigner: "
            echo ' ./resign.sh -c "Apple Development: Name (XXXXXXXXXX)" -p XXXXXXXXX.mobileprovision -i youtube -e "*.appex","*.dylib" '
            echo " -c: nom du certificat "
            echo " -p: profil d'approvisionnement "
            echo " -i: nom du fichier .ipa ! sans extension .ipa à la fin "
            echo " -e: ajouter d'autres nouvelles couches à resigner (optionnel) "
            exit 1
            ;;
        c)
            echo "nom du certificat: ${OPTARG}"
            CERTIFICATE_NAME=$OPTARG
            ;;
        p)
            echo "profil d'approvisionnement: ${OPTARG}"
            PROVISION_PROFIL=$OPTARG
            ;;
        i)
            echo "nom du fichier .ipa: ${OPTARG}"
            IPA_NAME=$OPTARG
            ;;
        e)
            IFS="," read -r -a array_exts <<< "$OPTARG"
            ;;
    esac
done


sign()
{

    all_paths=($(find $IPA_NAME -name "$1"))
    
    echo "$1"
    for (( i=0; i<${#all_paths[@]}; i++ ))
    do
        
        if [ "$1" == "*.app" ] || [ "$1" == "*.framework" ]
        then
            echo "Delete: $((i + 1))/${#all_paths[@]} --- ${all_paths[$i]}/_CodeSignature"
            rm -rf ${all_paths[$i]}/_CodeSignature
        fi
        
        /usr/bin/codesign -f -s "$CERTIFICATE_NAME" --entitlements $ENTITLEMENTS_PLIST ${all_paths[$i]}
        
        if [ $? -eq 0 ]
        then
            echo "codesign succeded: $((i + 1))/${#all_paths[@]} ===> ${all_paths[$i]}"
        else
            echo "codesign failed: $((i + 1))/${#all_paths[@]} ===> ${all_paths[$i]}"
        fi
        
    done
    
}
# ================================================================================================================================


# START

/usr/bin/security cms -D -i $PROVISION_PROFIL > $PROVISION_PLIST

/usr/libexec/PlistBuddy -x -c "Print :Entitlements" $PROVISION_PLIST > $ENTITLEMENTS_PLIST

unzip $IPA_NAME.ipa -d $IPA_NAME/ || exit

path_app=($(find $IPA_NAME -name "*.app"))

rm -rf $path_app/embedded.mobileprovision

cp $PROVISION_PROFIL $path_app/embedded.mobileprovision

# >>>>>>>>>>>>>>>>

sign "*.appex"
sign "*.framework"
sign "*.dylib"

for ext in "${array_exts[@]}"
do
    sign "${ext}"
done

sign "*.app"

# >>>>>>>>>>>>>>>>

if [ -f "${IPA_NAME}_new.ipa" ]
then
    rm -rf ./$IPA_NAME"_new".ipa
fi

cd $IPA_NAME/ && zip -r ../$IPA_NAME"_new".ipa ./*  && cd ..

# clean

rm -rf *.plist && rm -rf ./$IPA_NAME





















