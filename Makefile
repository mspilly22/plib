all: txtmsg/message.proto
	protoc -I=txtmsg --go_out=txtmsg message.proto 
	mv txtmsg/github.com/mspilly22/plib/txtmsg/message.pb.go txtmsg
	rm -rf txtmsg/github.com
