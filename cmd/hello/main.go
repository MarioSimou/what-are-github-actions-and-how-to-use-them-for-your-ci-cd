package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"github.com/julienschmidt/httprouter"
	"github.com/MarioSimou/what-are-github-actions-and-how-to-use-them-for-your-ci-cd/internal"
)

func main(){
	var port string
	
	flag.StringVar(&port, "port", "8080", "port used to launch the server")

	flag.Parse()


	var address = fmt.Sprintf(":%s", port)
	var router = httprouter.New()

	router.GET("/hello/:name", func(res http.ResponseWriter, req *http.Request, params httprouter.Params){
		var firstName = params.ByName("name")
		fmt.Fprintf(res, internal.Greeting(firstName))
	})

	log.Printf("The app is running on %s\n", address)
	log.Fatalln(http.ListenAndServe(address, router))
}