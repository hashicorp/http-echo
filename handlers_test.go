// Copyright IBM Corp. 2016, 2026
// SPDX-License-Identifier: MPL-2.0

package main

import (
	"bytes"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestRequestBodyIsDrained(t *testing.T) {
	for _, test := range []struct {
		name string
		size int
	}{
		{name: "small", size: 1 << 10},
		{name: "20 MiB", size: 20 << 20},
	} {
		t.Run(test.name, func(t *testing.T) {
			body := &countingReader{reader: bytes.NewReader(make([]byte, test.size))}
			request := httptest.NewRequest(http.MethodPost, "/", io.NopCloser(body))
			response := httptest.NewRecorder()

			httpLog(io.Discard, withAppHeaders(http.StatusOK, httpEcho("hello")))(response, request)

			if body.read != test.size {
				t.Fatalf("read %d request-body bytes, want %d", body.read, test.size)
			}
			if response.Code != http.StatusOK {
				t.Fatalf("status = %d, want %d", response.Code, http.StatusOK)
			}
			if got, want := response.Body.String(), "hello\n"; got != want {
				t.Fatalf("body = %q, want %q", got, want)
			}
		})
	}
}

type countingReader struct {
	reader io.Reader
	read   int
}

func (r *countingReader) Read(p []byte) (int, error) {
	n, err := r.reader.Read(p)
	r.read += n
	return n, err
}
