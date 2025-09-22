#!/bin/bash

pkgs_to_install="make git zsh xclip fzf"
sudo apt install -y $pkgs_to_install

echo "Copiando .vimrc"
cp ./resources/.vimrc $HOME/.vimrc

# Una funcion para modificar algun valor de los ficheros de configuracion por un nuevo valor.
# Si no esta el valor, se anade.
ensure_line() {
	local pattern=$1
	local newline=$2
	local file=$3

    if [[ $# -ne 3 ]]; then
        echo "Bad usage of ensure_line()";
        exit 1;
    fi

	if [[ ! -f "$file" ]]; then
		touch "$file"
	else
		cp "$file" "${file}.bak"
	fi

	if LC_ALL=C grep -q "$pattern" "$file"; then
		sed -i "/$pattern/ c $newline" "$file"
	else
		printf "%s\n" "$newline" >> $file
	fi

}

# Oh-my-zsh
if [[ ! -d $HOME/.oh-my-zsh  ]]; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
	echo "Oh-my-zsh installed already!"
fi

ensure_line "ZSH_THEME=\"" "ZSH_THEME=\"josh\"" "$HOME/.zshrc"
ensure_line "^plugins" "plugins=(git fzf)" "$HOME/.zshrc"
source $HOME/.zshrc

# Oh-my-tmux
if [[ ! -f $HOME/.tmux.conf.local ]]; then
	echo "Installing Oh-my-tmux..."
	pwd=$PWD
	cd $HOME
	git clone --single-branch https://github.com/gpakosz/.tmux.git
	ln -s -f .tmux/.tmux.conf
	cp .tmux/.tmux.conf.local .
	cd $pwd
	echo "Installed Oh-my-tmux!"
else
	echo "Oh-my-tmux installed already!"
fi

ensure_line "tmux_conf_copy_to_os_clipboard=" "tmux_conf_copy_to_os_clipboard=true " "$HOME/.tmux.conf.local"
ensure_line "mode-keys vi" "set -g mode-keys vi" "$HOME/.tmux.conf.local"
tmux source-file ~/.tmux.conf
ensure_line "bind -T copy-mode-vi H" "bind -T copy-mode-vi H send -X top-line" "$HOME/.tmux.conf"
ensure_line "bind -T copy-mode-vi L" "bind -T copy-mode-vi L send -X bottom-line" "$HOME/.tmux.conf"
