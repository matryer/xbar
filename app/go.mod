module github.com/matryer/xbar/app

go 1.16

require (
	github.com/go-ole/go-ole v1.2.5 // indirect
	github.com/google/btree v1.0.1 // indirect
	github.com/google/uuid v1.2.0 // indirect
	github.com/gorilla/websocket v1.4.2 // indirect
	github.com/gregjones/httpcache v0.0.0-20190611155906-901d90724c79
	github.com/klauspost/compress v1.13.1 // indirect
	github.com/leaanthony/go-ansi-parser v1.2.0
	github.com/leaanthony/webview2runtime v1.2.0 // indirect
	github.com/matryer/is v1.4.0
	github.com/matryer/xbar/pkg/metadata v0.0.0-20210701102621-61a690f92a94
	github.com/matryer/xbar/pkg/plugins v0.0.0-20210701102621-61a690f92a94
	github.com/matryer/xbar/pkg/update v0.0.0-20210701102621-61a690f92a94
	github.com/peterbourgon/diskv v2.0.1+incompatible // indirect
	github.com/pierrec/lz4 v2.6.1+incompatible // indirect
	github.com/pkg/errors v0.9.1
	github.com/wailsapp/wails/v2 v2.0.0-alpha.72
	golang.org/x/sys v0.1.0 // indirect
	nhooyr.io/websocket v1.8.7 // indirect
)

replace github.com/matryer/xbar/pkg/plugins => ../pkg/plugins

replace github.com/matryer/xbar/pkg/metadata => ../pkg/metadata

replace github.com/matryer/xbar/pkg/update => ../pkg/update

//replace github.com/wailsapp/wails/v2 => ../../wails/v2
