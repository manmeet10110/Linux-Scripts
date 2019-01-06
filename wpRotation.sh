#!/bin/bash
user=$(whoami)
fl=$(find /proc -maxdepth 2 -user $user -name environ -print -quit)
while [ -z $(grep -z DBUS_SESSION_BUS_ADDRESS "$fl" | cut -d '=' -f 2- | tr -d '\000' ) ]
do
  fl=$(find /proc -maxdepth 2 -user $user -name environ -newer "$fl" -print -quit)
done
export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS "$fl" | cut -d '=' -f 2-)

DIR=`ls -d ~/* | grep Wallpapers`
if [ -z "$DIR" ]; then 
    mkdir ~/Wallpapers
    zenity --title="Wallpaper rotation failed." \
    --width=300 --height=200 \
    --info --text "<b>Directory 'Wallpaper' is missing<\b>\nScript has created the directory. Please add wallpapers to it." 
    exit 2
fi
WPPR=( $(ls $DIR/ | grep -E '([.]jpg)|([.]JPEG)|([.]jpeg)|([.]png)|([.]PNG)') )
if [ "${#WPPR[@]}" -eq 0 ]; then
    echo "no wallpaers found. Add wallpapers to the directory: $DIR"
    exit 1
fi
INIT=`ls $DIR/ | grep "~"` 
if [ -z "$INIT" ]; then
    echo "Script initiated at `date`"
    mv $DIR/"${WPPR[0]}" $DIR/"~${WPPR[0]}"
    bash `realpath $0`
fi
for i in `seq 0 ${#WPPR[@]}`
do 
    CURRWP=`echo $DIR/"${WPPR[$i]}" | grep -E '(~)'`
    if [ -z "$CURRWP" ]; then
        continue
    else
        PREWP=`echo "$CURRWP" | sed -r "s/~//g"`
        mv "$CURRWP" "$PREWP"
        k=$(($i+1))
        if [ "$k" -eq "${#WPPR[@]}" ]; then
            k=0
        fi
        NEXTWP=`echo $DIR/"~${WPPR[$k]}"`
        mv $DIR/${WPPR[$k]} $NEXTWP
        notify-send -t 3000 Wallpaper\ Changed "Current wallpaper: `echo "$NEXTWP" | sed -r "s|$DIR/~||g"`" 
        gsettings set org.gnome.desktop.background picture-uri file://$NEXTWP
        echo "wallpaper changed at `date`"
        exit 0
    fi
done