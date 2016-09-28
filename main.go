package main

import (
	"flag"
	"fmt"
	"html"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"sync"
	"syscall"
	"time"
)

const (
	version = "0.1.0"
)

var (
	listenFlag  = flag.String("listen", ":5678", "address and port to listen")
	versionFlag = flag.Bool("version", false, "display version information")
)

func main() {
	flag.Parse()

	// Asking for the version?
	if *versionFlag {
		log.Println(formattedVersion())
		os.Exit(0)
	}

	// Validation
	args := flag.Args()
	if len(args) < 1 {
		log.Printf("Missing server contents!")
		os.Exit(127)
	}

	// Extra args get printed to the HTML page
	mux := http.NewServeMux()
	data := strings.Join(flag.Args(), " ")
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, html.EscapeString(data))
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

type StoppableServer struct {
	wg sync.WaitGroup

	server   *http.Server
	listener *net.TCPListener
	stopCh   chan struct{}
}

func NewServer(addr string, handler http.Handler) (*StoppableServer, error) {
	listener, err := net.Listen("tcp", addr)
	if err != nil {
		return nil, err
	}

	handler = loggingMux(handler)

	var stoppableServer StoppableServer
	stoppableServer.server = &http.Server{Handler: handler}
	stoppableServer.listener = listener.(*net.TCPListener)
	stoppableServer.stopCh = make(chan struct{}, 1)

	return &stoppableServer, nil
}

func (s *StoppableServer) Start() {
	s.wg.Add(1)
	defer s.wg.Done()
	s.server.Serve(s.listener)
}

func (s *StoppableServer) Accept() (net.Conn, error) {
	for {
		s.listener.SetDeadline(time.Now().Add(time.Second))

		conn, err := s.listener.Accept()
		select {
		case <-s.stopCh:
			return nil, nil
		default:
		}

		if err != nil {
			netErr, ok := err.(net.Error)

			// If this is a timeout, then continue to wait for new connections
			if ok && netErr.Timeout() && netErr.Temporary() {
				continue
			}
		}

		return conn, err
	}
}

func (s *StoppableServer) Stop() {
	close(s.stopCh)
}

func (s *StoppableServer) Wait() {
	s.wg.Wait()
}

func loggingMux(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("[%s] %s\n", r.Method, r.URL)
		h.ServeHTTP(w, r)
	})
}
