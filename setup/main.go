package main

import (
	"bytes"
	"errors"
	"fmt"
	"log"
	"os"
	"os/exec"
	"os/user"
	"regexp"
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
	// Check for NVidia graphics card.
 	cmd := exec.Command("lspci", "-v")
    var outGraphics bytes.Buffer
    cmd.Stdout = &outGraphics
    err := cmd.Run()
    if err != nil {
        log.Fatal("Could not get lspci information.")
    }
    
    // Check if the output contains "nvidia" (case-insensitive)
    hasNvidiaGraphics, err := regexp.MatchString(`(?i)nvidia`, outGraphics.String())
    if err != nil {
    	log.Fatal("Could not match regexp.")
    }
    
    // Check for Full Disk Encryption
    cmd = exec.Command("lsblk")
    var outDisk bytes.Buffer
    cmd.Stdout = &outDisk
    err = cmd.Run()
    if err != nil {
        log.Fatal("Could not get lsblk information.")
    }
    
    // Check if the output contains "crypt" (case-insensitive)
    hasDiskEncryption, err := regexp.MatchString(`(?i)crypt`, outDisk.String())
    if err != nil {
       	log.Fatal("Could not match regexp.")
    }


	// Form variables.
	var (
		hostname			string
		fasterDownloads		bool
		cloneInHttpMode		bool 	= true
		createSshKey		bool 	= true
		sshPrivKeyFile		string 	= homeDir + "/.ssh/id_ed25519"
		enableNvidiaDrivers	bool	= false
		enableAutoLogin		bool = false
		packages			[]string
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
	
	// Packages to install group.
	packagesGroupsMultiSelect := huh.NewMultiSelect[string]().
		Title("Select which packages groups should be installed.").
		Options(
			huh.NewOption("Base", "base").Selected(true),
			huh.NewOption("Multimedia (DaVinci Resolve, Audacity, etc.)", "media"),
			huh.NewOption("Desktop Utils (Open Razer, Streamdeck, etc.)", "desktop"),
			huh.NewOption("Vencord", "vencord"),
		).
		Value(&packages)
	
	enableNvidiaDriversConfirm := huh.NewConfirm().
		Title("Do you want to install propietary Nvidia drivers?").
		Description("Open source drivers are already bundled.").
		Affirmative("Yes!").
		Negative("No").
		Value(&enableNvidiaDrivers).
		Validate(func(value bool) error {
			if value && !hasNvidiaGraphics {
				return errors.New("No NVidia graphics card detected.")
			}
			
			return nil
		})
	
	enableAutoLoginConfirm := huh.NewConfirm().
		Title("Do you want to enable autologin?").
		DescriptionFunc(func() string {
			if hasDiskEncryption {
				return "Full Disk Encryption detected. \"Yes!\" is recommended."
			}
			
			return "No disk encryption detected. Option not recommended."
		}, nil).
		Affirmative("Yes!").
		Negative("No").
		Value(&enableAutoLogin)
	
	additionalGroup := huh.NewGroup(
		packagesGroupsMultiSelect,
		enableNvidiaDriversConfirm,
		enableAutoLoginConfirm,
	)

	form := huh.NewForm(
		basicInfoGroup,
		sshGroup,
		additionalGroup,
	)

	form.Run()
	
	sshPrivKeyFile = strings.TrimSuffix(sshPrivKeyFile, " !")
	
	file, err2 := os.Create("setup_output.txt")
	
	if err2 != nil {
		log.Fatal(err2)
	}
	
	
	defer file.Close()
	file.WriteString(fmt.Sprintf(
		"%s\n%t\n%t\n%t\n%s\n%t\n%t\n%s",
		hostname,
		fasterDownloads,
		cloneInHttpMode,
		createSshKey,
		sshPrivKeyFile,
		enableNvidiaDrivers,
		enableAutoLogin,
		strings.Join(packages, " "),
	))
}