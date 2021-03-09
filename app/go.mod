module github.com/matryer/xbar/app

go 1.16

require (
	github.com/frankban/quicktest v1.11.3 // indirect
	github.com/google/btree v1.0.0 // indirect
	github.com/gregjones/httpcache v0.0.0-20190611155906-901d90724c79
	github.com/matryer/is v1.4.0
	github.com/matryer/xbar/pkg/metadata v0.0.0-00010101000000-000000000000
	github.com/matryer/xbar/pkg/plugins v0.0.0-20210131002325-64faeb3b217b
	github.com/matryer/xbar/pkg/update v0.0.0-00010101000000-000000000000
	github.com/peterbourgon/diskv v2.0.1+incompatible // indirect
	github.com/pkg/errors v0.9.1
	github.com/wailsapp/wails/v2 v2.0.0-alpha.48
	golang.org/x/sys v0.0.0-20201207223542-d4d67f95c62d // indirect
)

replace github.com/matryer/xbar/pkg/plugins => ../pkg/plugins

replace github.com/matryer/xbar/pkg/metadata => ../pkg/metadata

replace github.com/matryer/xbar/pkg/update => ../pkg/update

//replace github.com/wailsapp/wails/v2 => ../../../wailsapp/wails/v2
