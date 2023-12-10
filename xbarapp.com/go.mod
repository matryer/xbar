module github.com/matryer/xbar/xbarapp.com

go 1.19

require (
	github.com/matryer/is v1.4.0
	github.com/matryer/xbar/pkg/metadata v0.0.0-20210312151302-803da66ba9c6
)

require github.com/pkg/errors v0.9.1 // indirect

// replace github.com/matryer/xbar/pkg/metadata => ../pkg/metadata
