function addpkg
	for pkg in $argv
		# Add the packages to the file
		echo "Adding packages to the package.txt file"
		echo $pkg >> ~/.dotfiles/packages.txt
		echo "Rebuilding system"
		rb
	end
end
