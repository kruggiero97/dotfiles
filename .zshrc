#            _
#    _______| |__  _ __ ___
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|  \___|
#
# -----------------------------------------------------
# Modular zshrc loader
# -----------------------------------------------------
# Loads configuration from ~/.config/zshrc/*
# Allows overrides in ~/.config/zshrc/custom
# -----------------------------------------------------

# -----------------------------------------------------
# Load modular configuration
# -----------------------------------------------------

for f in ~/.config/khloe-zsh/*; do
    if [ ! -d $f ]; then
        c=`echo $f | sed -e "s=.config/khloe-zsh=.config/khloe-zsh/custom="`
        [[ -f $c ]] && source $c || source $f
    fi
done

# -----------------------------------------------------
# Load single customization file (if exists)
# -----------------------------------------------------

if [ -f ~/.zshrc_custom ]; then
    source ~/.zshrc_custom
fi
