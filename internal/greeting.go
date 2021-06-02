package internal

import (
	"fmt"
	"strings"
)

func Greeting(firstName string) string {
	if firstName == "" {
		return "Hello World"
	}
	return fmt.Sprintf("Hello %s", strings.Title(firstName))
}
