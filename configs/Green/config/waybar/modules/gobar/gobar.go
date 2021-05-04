// Package gobar is some small utils for supporting my waybar go scripts
package gobar

import (
	"encoding/json"
	"io"

	"github.com/esiqveland/notify"
	"github.com/godbus/dbus/v5"
)

// JSONOutput defines the fields waybar expects from custom modules
// when return-type is set to json
type JSONOutput struct {
	Text       string `json:"text,omitempty"`
	Alt        string `json:"alt,omitempty"`
	Tooltip    string `json:"tooltip,omitempty"`
	Class      string `json:"class,omitempty"`
	Percentage int    `json:"percentage,omitempty"`
}

func (j JSONOutput) Write(o io.Writer) error {
	return json.NewEncoder(o).Encode(j)
}

// Module wraps summary and json data
type Module struct {
	Name    string
	Summary string
	JSON    JSONOutput
}

// Notify via DBUS
func (m Module) Notify(body string, expire int32) error {
	conn, err := dbus.SessionBusPrivate()
	if err != nil {
		return err
	}
	defer conn.Close()

	if err = conn.Auth(nil); err != nil {
		return err
	}

	if err = conn.Hello(); err != nil {
		return err
	}

	// Send notification
	_, err = notify.SendNotification(conn, notify.Notification{
		AppName:       m.Name,
		ReplacesID:    uint32(0),
		AppIcon:       "mail-message-new",
		Summary:       m.Summary,
		Body:          body,
		Hints:         map[string]dbus.Variant{},
		ExpireTimeout: expire,
	})

	return err
}
