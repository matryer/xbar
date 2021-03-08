module github.com/matryer/xbar/pkg/plugins

go 1.15

require (
	github.com/matryer/is v1.4.0
	github.com/matryer/xbar/pkg/metadata v0.0.0-00010101000000-000000000000
	github.com/pkg/errors v0.9.1
)

replace github.com/matryer/xbar/pkg/metadata => ../metadata
