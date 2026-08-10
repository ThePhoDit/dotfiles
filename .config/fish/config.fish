if status is-interactive
	# Commands to run in interactive sessions can go here
end

# Remove greeting text (can be redifined with a function with the same name and echo commands)
set -g fish_greeting

# System update command
function update
	bash $HOME/.local/bin/update
end

function pkg_sync
	bash $HOME/.local/bin/pkg_sync
end
