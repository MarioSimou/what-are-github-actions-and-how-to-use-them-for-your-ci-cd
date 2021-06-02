package internal

import (
	"testing"
)

func TestGreeting(t *testing.T){
	var table = []struct{
		firstName string
		expectedGreeting string
	}{
		{
			firstName: "",
			expectedGreeting: "Hello World",
		},
		{
			firstName: "john",
			expectedGreeting: "Hello John",
		},
	}

	for _, row := range table {
		if greeting := Greeting(row.firstName); greeting != row.expectedGreeting {
			t.Errorf("Expected message '%s' rather than '%s'\n", row.expectedGreeting, greeting)
		}
	}
}