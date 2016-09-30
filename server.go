package main

import (
	"net"
	"net/http"
	"sync"
	"time"
)

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
