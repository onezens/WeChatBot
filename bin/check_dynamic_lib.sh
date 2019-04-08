TWEAK_NAME=WeChatBot
dylibPath=Libraries/dynamic
cydiaLibPath=/Library/MobileSubstrate/DynamicLibraries/$TWEAK_NAME
oriDylibPath=$dylibPath/ori
tweakLayoutPath=layout$cydiaLibPath

echo $tweakLayoutPath

if [[ ! -d $oriDylibPath ]]; then
	mkdir $oriDylibPath
fi

if [[ ! -d $tweakLayoutPath ]]; then
	mkdir $tweakLayoutPath
fi

checkDylibID() {
	path=$1
	libFullPath=$2
	ckLibId=$(otool -L $path | grep rpath)
	if [[ -n $ckLibId ]]; then
		cp -r $libFullPath $oriDylibPath
		ckLibId=${ckLibId%' ('*}
		ckLibId=${ckLibId#*/}
		install_name_tool -id $cydiaLibPath/$ckLibId $path
		otool -L $path
	fi
	cp -r $libFullPath $tweakLayoutPath

}


for file in $dylibPath/*; do
	if [[ $file =~ ".dylib" ]]; then
		checkDylibID $file $file
	elif [[ $file =~ ".framework" ]]; then
		name=${file##*/}
		name=${name%.*}
		checkDylibID $file/$name $file
	fi
done




# libPath='./Libraries/WCBDyLib/libWCBDyLib.dylib'
# libName=${libPath##*/}
# libInfo=$(otool -L $libPath | grep 'rpath')
# if [[ -n $libInfo ]]; then
# 	libInfo=${libInfo%' ('*}
# 	echo $libInfo
# 	echo ${install_name_tool -change $libInfo  /Library/MobileSubstrate/DynamicLibraries/$libName $libPath}
# 	otool -L $libPath
# fi

# echo "check dynamic lib dependency"
# target='.theos/_/Library/MobileSubstrate/DynamicLibraries/WeChatBot.dylib'
# libs=$(otool -L $target | grep rpath)
# for rel in $libs; do
# 	if [[ $rel =~ "rpath" ]]; then
# 		libPath=$rel
# 		echo $libPath
# 		libName=${libPath#*/}
# 		install_name_tool -change $libPath /Library/MobileSubstrate/DynamicLibraries/$libName $target
# 	fi
# done
# otool -L $target



