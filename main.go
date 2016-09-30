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

var (
	listenFlag  = flag.String("listen", ":5678", "address and port to listen")
	textFlag    = flag.String("text", "", "text to put on the webpage")
	versionFlag = flag.Bool("version", false, "display version information")

	// stdoutW and stderrW are for overriding in test.
	stdoutW = os.Stdout
	stderrW = os.Stderr
)

func main() {
	flag.Parse()

	// Asking for the version?
	if *versionFlag {
		fmt.Fprintln(stderrW, humanVersion)
		os.Exit(0)
	}

	// Validation
	if *textFlag == "" {
		fmt.Fprintln(stderrW, "Missing -text option!")
		os.Exit(127)
	}

	args := flag.Args()
	if len(args) > 0 {
		fmt.Fprintln(stderrW, "Too many arguments!")
		os.Exit(127)
	}

	// Flag gets printed as a page
	mux := http.NewServeMux()
	mux.HandleFunc("/", httpLog(stdoutW, withAppHeaders(httpEcho(*textFlag))))

	// Health endpoint
	mux.HandleFunc("/health", withAppHeaders(httpHealth()))

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

func httpEcho(v string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, v)
	}
}

func httpHealth() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, `{"status":"ok"}`)
	}
}
