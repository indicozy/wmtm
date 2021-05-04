package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"regexp"
	"strings"

	"github.com/google/go-github/github"
	"github.com/mikkeloscar/aur"
	"github.com/nboughton/dotfiles/waybar/modules/gobar"
)

const (
	npm         = "npm"
	ghub        = "github"
	errClass    = "error"
	npmRegistry = "https://registry.npmjs.org/"
)

var outfile = fmt.Sprintf("%s/tmp/auroch.json", os.Getenv("HOME"))

var packages = []*pkg{
	{
		AurName:      "quasar-cli",
		UpstreamName: "@quasar/cli",
		UpstreamType: npm,
	},
	{
		AurName:      "quasar-icongenie",
		UpstreamName: "@quasar/icongenie",
		UpstreamType: npm,
	},
	{
		AurName:      "swnt",
		UpstreamName: "nboughton/swnt",
		UpstreamType: ghub,
	},
	{
		AurName:      "myzt",
		UpstreamName: "nboughton/myzt",
		UpstreamType: ghub,
	},
	{
		AurName:      "plymouth-theme-arch-charge-gdm",
		UpstreamName: "nboughton/plymouth-theme-arch-charge-gdm",
		UpstreamType: ghub,
	},
	{
		AurName:      "devd",
		UpstreamName: "cortesi/devd",
		UpstreamType: ghub,
	},
}

func main() {
	// Write temp json while checking to indicate
	f, err := os.Create(outfile)
	if err != nil {
		log.Fatalf("could not open %s for writing", outfile)
	}

	t := gobar.JSONOutput{
		Text:       "",
		Alt:        "",
		Tooltip:    "Checking for updates",
		Class:      "checking",
		Percentage: 0,
	}
	t.Write(f)
	f.Close()

	var (
		out   []string
		class string
	)

	class = "no-updates"
	for _, p := range packages {
		if err = p.getAurVer(); err != nil {
			class = errClass
			break

		}

		if p.UpstreamType == npm {
			if err = p.getNpmVer(); err != nil {
				class = errClass
				break
			}
		} else if p.UpstreamType == ghub {
			if err = p.getGithubVer(); err != nil {
				class = errClass
				break
			}
		}

		log.Printf("%s %s -> %s\n", p.AurName, p.AurVer, p.UpstreamVer)
		if p.AurVer != p.UpstreamVer {
			out = append(out, fmt.Sprintf("%s %s -> %s", p.AurName, p.AurVer, p.UpstreamVer))
		}
	}

	n := len(out)

	txt := fmt.Sprintf("%d", n)
	if class == errClass {
		txt = "!"
	}

	if n > 0 {
		class = "updates"
	}

	m := gobar.Module{
		Name:    "AUROCH",
		Summary: "Outdated AUR Packages",
		JSON: gobar.JSONOutput{
			Text:       txt,
			Alt:        txt,
			Class:      class,
			Tooltip:    strings.Join(out, "\n"),
			Percentage: n,
		},
	}

	if n > 0 {
		log.Println("Sending DBUS Notification")
		m.Notify(m.JSON.Tooltip, 10000)
	}

	log.Println("Writing JSON data")
	f, err = os.Create(outfile)
	if err != nil {
		log.Fatalf("could not open %s for writing", outfile)
	}
	defer f.Close()
	m.JSON.Write(f)
}

// Define relevant package data
type pkg struct {
	AurName      string `json:"aur_name,omitempty"` // Name on the AUR (i.e vue-cli)
	AurVer       string `json:"aur_ver,omitempty"`
	UpstreamName string `json:"upstream_name,omitempty"` // Name on the upstream source (i.e @vue/cli)
	UpstreamType string `json:"upstream_type,omitempty"` // Upstream type: npm|github
	UpstreamVer  string `json:"upstream_ver,omitempty"`
}

// Just the bit of NPM registry info that I care about
type npmInfo struct {
	DistTags struct {
		Latest string `json:"latest,omitempty"`
	} `json:"dist-tags,omitempty"`
}

// Retrieve the version of the current AUR package
func (p *pkg) getAurVer() error {
	// Request pkg info
	res, err := aur.Info([]string{p.AurName})
	if err != nil {
		return err
	}

	// Copy it to pkg struct
	p.AurVer = res[0].Version

	// Strip revision
	p.AurVer = regexp.MustCompile(`-\d$`).ReplaceAllString(p.AurVer, "")

	return nil
}

func (p *pkg) getNpmVer() error {
	// Request and decode the versions list
	n := npmInfo{}
	resp, err := http.Get(fmt.Sprintf("%s/%s", npmRegistry, p.UpstreamName))
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if err = json.NewDecoder(resp.Body).Decode(&n); err != nil {
		return err
	}

	p.UpstreamVer = n.DistTags.Latest

	return nil
}

func (p *pkg) getGithubVer() error {
	c := github.NewClient(nil)

	// Get repo owner and repo name
	parts := strings.Split(p.UpstreamName, "/")
	owner, repo := parts[0], parts[1]

	rel, _, err := c.Repositories.GetLatestRelease(context.Background(), owner, repo)
	if err != nil {
		return err
	}

	// Strip "v" prefix if there is one
	p.UpstreamVer = regexp.MustCompile(`^v`).ReplaceAllString(rel.GetTagName(), "")

	return nil
}
