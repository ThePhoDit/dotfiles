package main

import (
	"errors"
	"log"
	"os"
	"os/user"
	"strconv"
	"strings"
	"syscall"

	"github.com/charmbracelet/huh"
)

// Env variables.
var (
	homeDir	string
	currentUser *user.User
	err error
)


func init() {
        homeDir, err = os.UserHomeDir()
        if err != nil {
            log.Fatal(err)
        }
        
        currentUser, err = user.Current()
        if err != nil {
        	log.Fatal(err)
         	
        }
}

func hasReadWritePermissions(fileInfo os.FileInfo) bool {
        uid := fileInfo.Sys().(*syscall.Stat_t).Uid
        gid := fileInfo.Sys().(*syscall.Stat_t).Gid
        fileMode := fileInfo.Mode()

        // Check if current user is the owner
        if strconv.Itoa(int(uid)) == currentUser.Uid {
                return fileMode.Perm()&0600 != 0
        }

        // Check group permissions
        currentGroupIDs, err := currentUser.GroupIds()
        if err != nil {
                return false // Unable to determine current user's groups
        }
        for _, groupID := range currentGroupIDs {
                if strconv.Itoa(int(gid)) == groupID {
                        return fileMode.Perm()&0060 != 0
                }
        }

        // Check other permissions
        return fileMode.Perm()&0006 != 0
}

func hasReadPermissions(fileInfo os.FileInfo) bool {
        uid := fileInfo.Sys().(*syscall.Stat_t).Uid
        gid := fileInfo.Sys().(*syscall.Stat_t).Gid
        fileMode := fileInfo.Mode()

        // Check if current user is the owner
        if strconv.Itoa(int(uid)) == currentUser.Uid {
                return fileMode.Perm()&0600 != 0
        }

        // Check group permissions
        currentGroupIDs, err := currentUser.GroupIds()
        if err != nil {
                return false // Unable to determine current user's groups
        }
        for _, groupID := range currentGroupIDs {
                if strconv.Itoa(int(gid)) == groupID {
                        return fileMode.Perm()&0060 != 0
                }
        }

        // Check other permissions
        return fileMode.Perm()&0006 != 0
}

func main() {
	// Form variables.
	var (
		hostname		string
		fasterDownloads	bool
		cloneInHttpMode	bool = true
		createSshKey	bool = true
		sshPrivKeyFile	string = homeDir + "/.ssh/id_ed25519"
	)
	// Start defining the first group.
	introductionNote := huh.NewNote().
		Title("Fedora Setup Script").
		Description(
			"Welcome to ThePhoDit's Fedora post-install script.\n" +
			"You will be prompted several script customization options.",
		)
	
	hostnameInput := huh.NewInput().
		Title("Set your desired hostname").
		Description("The name that will appear in your prompt and network activity.").
		Value(&hostname).
		Validate(func(str string) error {
			if str == "" {
				return errors.New("The hostname cannot be empty.")
			}
			return nil
		})
	
	fasterDownloadsConfirm := huh.NewConfirm().
		Title("Do you want to enable faster DNF downloads?").
		Description("Enable concurrent downloads and fastest mirror selection.").
		Affirmative("Yes!").
		Negative("No").
		Value(&fasterDownloads)
	
	cloneInHttpModeConfirm := huh.NewConfirm().
		Title("Do you want to clone the repository in HTTP mode?").
		Description(
			"Note that if you choose not to, SSH mode will be used. No pushing can be done without proper repo access.",
		).
		Affirmative("Clone in HTTP mode").
		Negative("Clone in SHH mode").
		Value(&cloneInHttpMode)	
	
	basicInfoGroup := huh.NewGroup(
		introductionNote,
		hostnameInput,
		fasterDownloadsConfirm,
		cloneInHttpModeConfirm,
	)
	
	// Create SSH key group.
	createSshKeyConfirm := huh.NewConfirm().
			Title("Do you want to create a ed25519 SSH key?").
			Description("You can set to \"No\" if you already have one.").
			Affirmative("Yes!").
			Negative("No").
			Value(&createSshKey)
	
	sshPrivKeyFileInput := huh.NewInput().
		Title("SSH private key path.").
		Description("Enter the location for your SSH private key (where it will be created or where it already is located.").
		Value(&sshPrivKeyFile).
		Validate(func(filePath string) error {
			info, err := os.Lstat(filePath)
			
			// You want to create a new SSH key.
			if createSshKey {
				// If the file already exists.
				if err == nil {
					// If you don't want to overwrite.
					if !strings.HasSuffix(filePath, " !") {
						return errors.New(
							"A key already exists in that location.\n" +
							"If you want to overwrite it with a new one add \" !\" to the end.",
						)
					} else {
						filePath = strings.TrimSuffix(filePath, " !")
					}				
					
					// Check read/write permissions.
					if !hasReadWritePermissions(info) {
						return errors.New("No read/write permissions for the current user over the given file.")
					}
					
				}
			} else {
				// If not exists.
				if err != nil {
					return errors.New("No private key found.")
				}
				
				// Check read permissions for the public key.
				if !hasReadPermissions(info) {
					return errors.New("No read permissions for the current user over the given file.")
				}
			}
			
			return nil
		})
	
	sshGroup := huh.NewGroup(
		createSshKeyConfirm,
		sshPrivKeyFileInput,
	).
	WithHideFunc(func() bool { return cloneInHttpMode })
	


	form := huh.NewForm(
		basicInfoGroup,
		sshGroup,
	)
	
	form.Run()
}