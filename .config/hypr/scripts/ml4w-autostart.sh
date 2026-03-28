#!/bin/bash
if [ -f ~/.config/khloe/version/compare.sh ] ;then
    $HOME/.config/khloe/version/compare.sh
fi

if [ ! -f ~/.cache/khloe-post-install ] ;then
    if [ ! -f $HOME/.cache/khloe-welcome-autostart ] ;then
        echo ":: Autostart of ML4W Welcome App enabled."
        if [ -f $HOME/.config/khloe/apps/ML4W_Welcome-x86_64.AppImage ] ;then
            echo ":: Starting ML4W Welcome App ..."
            sleep 2
            $HOME/.config/khloe/apps/ML4W_Welcome-x86_64.AppImage
        else
            echo ":: ML4W Welcome App not found."
        fi

    else
        echo ":: Autostart of ML4W Welcome App disabled."
    fi
else
    rm ~/.cache/khloe-post-install
    terminal=$(cat ~/.config/khloe/settings/terminal.sh)
    $terminal --class dotfiles-floating -e ~/.config/khloe/postinstall.sh
    $HOME/.config/khloe/apps/ML4W_Welcome-x86_64.AppImage
fi
