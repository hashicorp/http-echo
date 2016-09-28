package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
)

const (
	version = "0.1.0"
)

var (
	listenFlag  = flag.String("listen", ":5678", "address and port to listen")
	textFlag    = flag.String("text", "", "text to put on the webpage")
	versionFlag = flag.Bool("version", false, "display version information")
)

func main() {
	flag.Parse()

	// Asking for the version?
	if *versionFlag {
		printError(formattedVersion())
		os.Exit(0)
	}

	// Validation
	if *textFlag == "" {
		printError("Missing -text option!")
		os.Exit(127)
	}

	args := flag.Args()
	if len(args) > 0 {
		printError("Extra arguments!")
		os.Exit(127)
	}

	// Extra args get printed to the HTML page
	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, *textFlag)
	})

	server, err := NewServer(*listenFlag, mux)
	if err != nil {
		log.Printf("[ERR] Error starting server: %s", err)
		os.Exit(127)
	}

	go server.Start()
	log.Printf("Server is listening on %s\n", *listenFlag)

	signalCh := make(chan os.Signal, syscall.SIGINT)
	signal.Notify(signalCh)

	for {
		select {
		case s := <-signalCh:
			switch s {
			case syscall.SIGINT:
				log.Printf("[INFO] Received interrupt")
				server.Stop()
				os.Exit(2)
			default:
				log.Printf("[ERR] Unknown signal %v", s)
			}
		}
	}
}

func printError(s string) {
	fmt.Fprintf(os.Stderr, "%s\n", s)
}
